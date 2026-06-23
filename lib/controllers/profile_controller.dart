import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clune/controllers/analysis_controller.dart';
import 'package:clune/controllers/calendar_controller.dart';
import 'package:clune/controllers/daily_log_controller.dart';
import 'package:clune/controllers/home_controller.dart';
import 'package:clune/repositories/user_repository.dart';
import 'package:clune/services/data_backup_service.dart';
import 'package:clune/utils/enums.dart';

/// Controlador de la pantalla de perfil.
class ProfileController extends GetxController {
  final UserRepository _userRepo = Get.find();
  final DataBackupService _backupService = Get.find();

  final nameController = TextEditingController();
  final contraceptiveNotesController = TextEditingController();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final isExporting = false.obs;
  final isImporting = false.obs;
  final contraceptiveType = ContraceptiveType.none.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    contraceptiveNotesController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    final profile = await _userRepo.getProfile();
    if (profile != null) {
      nameController.text = profile.name;
      contraceptiveType.value = profile.contraceptiveType;
      contraceptiveNotesController.text = profile.contraceptiveNotes;
    }
    isLoading.value = false;
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    await _userRepo.updateName(nameController.text);
    await _userRepo.updateContraceptive(
      type: contraceptiveType.value,
      notes: contraceptiveNotesController.text.trim(),
    );
    isSaving.value = false;
    Get.snackbar('save'.tr, 'profile_saved'.tr);
  }

  void setContraceptive(ContraceptiveType type) {
    contraceptiveType.value = type;
  }

  bool get usesHormonalContraceptive => contraceptiveType.value.isHormonal;

  Future<void> exportData() async {
    isExporting.value = true;
    try {
      final json = await _backupService.exportToJson();
      final bytes = utf8.encode(json);
      final fileName =
          'clune_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'profile_export'.tr,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: bytes,
      );

      if (path == null) {
        await Share.shareXFiles(
          [XFile.fromData(bytes, name: fileName, mimeType: 'application/json')],
          text: 'profile_export'.tr,
        );
      }

      Get.snackbar('profile_export'.tr, 'profile_export_success'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) return;

    final replace = await Get.dialog<bool>(
      AlertDialog(
        title: Text('profile_import_replace_title'.tr),
        content: Text('profile_import_replace_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('profile_import_merge'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('profile_import_replace'.tr),
          ),
        ],
      ),
    );
    if (replace == null) return;

    isImporting.value = true;
    try {
      await _backupService.importFromJson(
        utf8.decode(bytes),
        replace: replace,
      );
      await _refreshAllControllers();
      await loadProfile();
      Get.snackbar('profile_import'.tr, 'profile_import_success'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isImporting.value = false;
    }
  }

  Future<void> _refreshAllControllers() async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().reloadData();
    }
    if (Get.isRegistered<CalendarController>()) {
      await Get.find<CalendarController>().loadMonthData();
    }
    if (Get.isRegistered<DailyLogController>()) {
      await Get.find<DailyLogController>().loadLogForDate(DateTime.now());
    }
    if (Get.isRegistered<AnalysisController>()) {
      await Get.find<AnalysisController>().loadAnalysis();
    }
  }
}

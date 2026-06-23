import 'package:get/get.dart';
import 'package:clune/repositories/user_repository.dart';
import 'package:clune/utils/log_section_ids.dart';
import 'package:clune/controllers/daily_log_controller.dart';

/// Controlador de personalización de secciones del registro diario.
class LogSectionsSettingsController extends GetxController {
  final UserRepository _userRepo = Get.find();

  final enabledSections = LogSectionIds.defaultEnabled().obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    enabledSections.value = await _userRepo.getEnabledLogSections();
  }

  bool isEnabled(String id) => enabledSections.contains(id);

  void toggle(String id) {
    if (enabledSections.contains(id)) {
      enabledSections.remove(id);
    } else {
      enabledSections.add(id);
      enabledSections.sort((a, b) {
        final ai = LogSectionIds.all.indexOf(a);
        final bi = LogSectionIds.all.indexOf(b);
        return ai.compareTo(bi);
      });
    }
  }

  Future<void> save() async {
    isSaving.value = true;
    await _userRepo.updateEnabledLogSections(enabledSections.toList());
    if (Get.isRegistered<DailyLogController>()) {
      await Get.find<DailyLogController>().reloadEnabledSections();
    }
    isSaving.value = false;
    Get.back();
  }
}

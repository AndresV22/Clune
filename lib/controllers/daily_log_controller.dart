import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/models/cycle_record.dart';
import 'package:clune/models/daily_log.dart';
import 'package:clune/repositories/daily_log_repository.dart';
import 'package:clune/repositories/cycle_repository.dart';
import 'package:clune/repositories/user_repository.dart';
import 'package:clune/services/prediction_service.dart';
import 'package:clune/services/cycle_sync_service.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/utils/pain_medications.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/utils/log_section_ids.dart';
import 'package:clune/controllers/home_controller.dart';
import 'package:clune/controllers/calendar_controller.dart';
import 'package:clune/controllers/main_nav_controller.dart';
import 'package:clune/controllers/analysis_controller.dart';

/// Controlador del formulario de registro diario.
class DailyLogController extends GetxController {
  final DailyLogRepository _logRepo = Get.find();
  final CycleRepository _cycleRepo = Get.find();
  final UserRepository _userRepo = Get.find();
  final PredictionService _predictionService = Get.find();
  final CycleSyncService _cycleSyncService = Get.find();

  final preferredPainMedication = ''.obs;
  final tookPainMedication = false.obs;
  final selectedDate = DateTime.now().obs;
  final enabledSections = LogSectionIds.defaultEnabled().obs;

  final bleeding = BleedingLevel.none.obs;
  final bleedingColor = BleedingColor.none.obs;
  final pain = PainLevel.none.obs;
  final cramps = false.obs;
  final discharge = DischargeType.none.obs;
  final sexDrive = SexDriveLevel.normal.obs;
  final mood = MoodType.calm.obs;
  final selectedSymptoms = <String>[].obs;
  final sexualActivity = false.obs;
  final hadOrgasm = false.obs;
  final hadSexualFantasies = false.obs;
  final energy = EnergyLevel.normal.obs;
  final hasPms = false.obs;
  final selectedCravings = <String>[].obs;
  final digestion = DigestionSymptom.normal.obs;
  final stool = StoolType.normal.obs;
  final selectedSleepQualities = <String>[].obs;
  final exercise = false.obs;
  final medications = ''.obs;
  final dailyNote = ''.obs;

  final periodHistory = <CycleRecord>[].obs;
  DailyLog? _existingLog;

  final dailyNoteController = TextEditingController();
  final medicationsController = TextEditingController();

  bool isSectionEnabled(String id) => enabledSections.contains(id);

  @override
  void onInit() {
    super.onInit();
    dailyNoteController.addListener(_syncDailyNote);
    medicationsController.addListener(_syncMedications);
    _loadEnabledSections();
    loadLogForDate(selectedDate.value);
    loadPeriodHistory();
    _loadPreferredMedication();
  }

  Future<void> _loadEnabledSections() async {
    enabledSections.value = await _userRepo.getEnabledLogSections();
  }

  Future<void> reloadEnabledSections() async {
    await _loadEnabledSections();
  }

  Future<void> _loadPreferredMedication() async {
    final profile = await _userRepo.getProfile();
    preferredPainMedication.value = profile?.preferredPainMedication ?? '';
  }

  void applyPreferredMedication() {
    final med = preferredPainMedication.value;
    if (med.isEmpty) return;
    tookPainMedication.value = true;
    medications.value = med;
    medicationsController.text = med;
  }

  Future<void> reloadPreferredMedication() async {
    await _loadPreferredMedication();
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().reloadPainAndMedication();
    }
  }

  void togglePainMedication(String med) {
    tookPainMedication.value = !tookPainMedication.value;
    if (tookPainMedication.value) {
      medications.value = med;
      medicationsController.text = med;
    } else if (medications.value == med) {
      medications.value = '';
      medicationsController.clear();
    }
  }

  void _syncDailyNote() => dailyNote.value = dailyNoteController.text;
  void _syncMedications() => medications.value = medicationsController.text;

  Future<void> changeDate(DateTime date) async {
    selectedDate.value = date;
    await loadLogForDate(date);
  }

  Future<void> loadLogForDate(DateTime date) async {
    _existingLog = await _logRepo.getLogForDate(date);
    if (_existingLog != null) {
      final log = _existingLog!..normalizeFields();
      bleeding.value = log.bleeding;
      bleedingColor.value = log.bleedingColor;
      pain.value = log.pain;
      cramps.value = log.cramps;
      discharge.value = log.discharge;
      sexDrive.value = log.sexDrive;
      mood.value = log.mood;
      selectedSymptoms.value = List.from(log.symptoms);
      sexualActivity.value = log.sexualActivity;
      hadOrgasm.value = log.hadOrgasm;
      hadSexualFantasies.value = log.hadSexualFantasies;
      energy.value = log.energy;
      hasPms.value = log.hasPms;
      selectedCravings.value = List.from(log.cravings);
      digestion.value = log.digestion;
      stool.value = log.stool;
      selectedSleepQualities.value = List.from(log.sleepQualities);
      exercise.value = log.exercise;
      medications.value = log.medications;
      dailyNote.value = log.effectiveDailyNote;
      dailyNoteController.text = log.effectiveDailyNote;
      medicationsController.text = log.medications;
      tookPainMedication.value = log.medications.isNotEmpty &&
          PainMedications.options.any((m) => log.medications.contains(m));
    } else {
      _resetForm();
    }
  }

  void _resetForm() {
    bleeding.value = BleedingLevel.none;
    bleedingColor.value = BleedingColor.none;
    pain.value = PainLevel.none;
    cramps.value = false;
    discharge.value = DischargeType.none;
    sexDrive.value = SexDriveLevel.normal;
    mood.value = MoodType.calm;
    selectedSymptoms.clear();
    sexualActivity.value = false;
    hadOrgasm.value = false;
    hadSexualFantasies.value = false;
    energy.value = EnergyLevel.normal;
    hasPms.value = false;
    selectedCravings.clear();
    digestion.value = DigestionSymptom.normal;
    stool.value = StoolType.normal;
    selectedSleepQualities.clear();
    exercise.value = false;
    medications.value = '';
    dailyNote.value = '';
    dailyNoteController.clear();
    medicationsController.clear();
    tookPainMedication.value = false;
    _existingLog = null;
  }

  void toggleSymptom(SymptomType symptom) => _toggleInList(selectedSymptoms, symptom.name);
  void toggleCraving(CravingType craving) => _toggleInList(selectedCravings, craving.name);
  void toggleSleepQuality(SleepQualitySymptom quality) =>
      _toggleInList(selectedSleepQualities, quality.name);

  void _toggleInList(RxList<String> list, String key) {
    if (list.contains(key)) {
      list.remove(key);
    } else {
      list.add(key);
    }
  }

  void setSexualActivity(bool value) {
    sexualActivity.value = value;
    if (!value) {
      hadOrgasm.value = false;
      hadSexualFantasies.value = false;
    }
  }

  void setBleeding(BleedingLevel level) {
    bleeding.value = level;
    if (level == BleedingLevel.none) {
      bleedingColor.value = BleedingColor.none;
    }
  }

  Future<void> saveLog() async {
    final log = _existingLog ?? DailyLog();
    log.date = AppDateUtils.normalizeDate(selectedDate.value);
    log.bleeding = bleeding.value;
    log.bleedingColor = bleedingColor.value;
    log.pain = pain.value;
    log.cramps = cramps.value;
    log.discharge = discharge.value;
    log.sexDrive = sexDrive.value;
    log.mood = mood.value;
    log.symptoms = selectedSymptoms.toList();
    log.sexualActivity = sexualActivity.value;
    log.hadOrgasm = hadOrgasm.value;
    log.hadSexualFantasies = hadSexualFantasies.value;
    log.energy = energy.value;
    log.hasPms = hasPms.value;
    log.cravings = selectedCravings.toList();
    log.digestion = digestion.value;
    log.stool = stool.value;
    log.sleepQualities = selectedSleepQualities.toList();
    log.exercise = exercise.value;
    log.medications = medications.value;
    log.dailyNote = dailyNote.value;
    log.notes = dailyNote.value;
    log.normalizeFields();

    await _logRepo.upsertLog(log);

    final cycleUpdated = await _cycleSyncService.syncBleedingToCycle(log);
    await _predictionService.calculateAverageCycle();
    await _refreshAllScreens();

    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().navigateAfterLogSave();
    }

    Get.snackbar(
      'log_saved'.tr,
      cycleUpdated != null
          ? 'cycle_updated_from_bleeding'.trParams({
              'date': AppDateUtils.formatShortDate(cycleUpdated),
            })
          : 'log_saved_message'.trParams({
              'date': AppDateUtils.formatShortDate(selectedDate.value),
            }),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> savePeriod({
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final cycle = CycleRecord()
      ..startDate = AppDateUtils.normalizeDate(startDate)
      ..endDate = endDate != null ? AppDateUtils.normalizeDate(endDate) : null
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _cycleRepo.saveCycle(cycle);
    await _refreshAfterPeriodChange();
  }

  Future<void> updatePeriod(CycleRecord cycle) async {
    cycle.updatedAt = DateTime.now();
    await _cycleRepo.saveCycle(cycle);
    await _refreshAfterPeriodChange();
  }

  Future<void> deletePeriod(int id) async {
    await _cycleRepo.deleteCycle(id);
    await _refreshAfterPeriodChange();
  }

  Future<void> _refreshAfterPeriodChange() async {
    await loadPeriodHistory();
    await _predictionService.calculateAverageCycle();
    await _refreshAllScreens();
  }

  Future<void> _refreshAllScreens() async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().reloadData();
    }
    if (Get.isRegistered<CalendarController>()) {
      await Get.find<CalendarController>().loadMonthData();
    }
    if (Get.isRegistered<AnalysisController>()) {
      await Get.find<AnalysisController>().loadAnalysis();
    }
  }

  Future<void> loadPeriodHistory() async {
    periodHistory.value = await _cycleRepo.getAllCycles();
  }

  Future<List<CycleRecord>> getPeriodHistory() => _cycleRepo.getAllCycles();

  @override
  void onClose() {
    dailyNoteController.removeListener(_syncDailyNote);
    medicationsController.removeListener(_syncMedications);
    dailyNoteController.dispose();
    medicationsController.dispose();
    super.onClose();
  }
}

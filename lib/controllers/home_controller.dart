import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/models/cycle_record.dart';
import 'package:clune/models/daily_log.dart';
import 'package:clune/repositories/cycle_repository.dart';
import 'package:clune/repositories/daily_log_repository.dart';
import 'package:clune/repositories/user_repository.dart';
import 'package:clune/services/cycle_phase_service.dart';
import 'package:clune/services/prediction_service.dart';
import 'package:clune/utils/constants.dart';
import 'package:clune/utils/cycle_calculator.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/utils/log_dot_mapper.dart';
import 'package:clune/widgets/cycle_ring/cycle_ring_painter.dart';
import 'package:clune/widgets/fertile_window_info_sheet.dart';
import 'package:clune/widgets/phase_info_sheet.dart';
import 'package:clune/models/article.dart';
import 'package:clune/repositories/article_repository.dart';
import 'package:clune/services/hormone_info_service.dart';
import 'package:clune/widgets/home_menu_sheet.dart';

/// Controlador de la pantalla Home con anillo de ciclo.
class HomeController extends GetxController {
  final CycleRepository _cycleRepo = Get.find();
  final DailyLogRepository _logRepo = Get.find();
  final UserRepository _userRepo = Get.find();
  final CyclePhaseService _phaseService = Get.find();
  final PredictionService _predictionService = Get.find();
  final HormoneInfoService _hormoneService = Get.find();
  final ArticleRepository _articleRepo = Get.find();

  /// Día real de hoy en el ciclo (1-indexed).
  final actualCycleDay = 1.obs;

  /// Día seleccionado por la usuaria en el anillo (exploración).
  final selectedCycleDay = 1.obs;

  /// Día mostrado en el anillo (alias de selectedCycleDay para compatibilidad).
  final cycleDay = 1.obs;

  /// Duración total del ciclo estimada.
  final cycleLength = AppConstants.defaultCycleLength.obs;

  /// Duración del periodo estimada.
  final periodLength = AppConstants.defaultPeriodLength.obs;

  /// Fase actual del ciclo.
  final currentPhase = CyclePhase.follicular.obs;

  /// Mensaje central dinámico.
  final centerMessage = ''.obs;

  /// Subtítulo con fecha de hoy.
  final todaySubtitle = ''.obs;

  /// Texto del enlace educativo bajo el anillo.
  final phaseLinkText = ''.obs;

  /// True si el día seleccionado está en la ventana fértil.
  final isSelectedDayFertile = false.obs;

  /// Días hasta próximo periodo.
  final daysUntilPeriod = 0.obs;

  /// Puntos de colores para el anillo.
  final dailyDots = <CycleDot>[].obs;

  /// Datos del anillo para el painter.
  final ringData = CycleRingData(
    cycleLength: 28,
    periodLength: 5,
    currentDay: 1,
    fertileStart: 9,
    fertileEnd: 15,
    ovulationDay: 14,
    dots: [],
  ).obs;

  /// Predicciones compactas para la home.
  final nextPeriodText = ''.obs;
  final nextFertileWindowText = ''.obs;
  final painPredictionText = RxnString();
  final moodPredictionText = RxnString();
  final trackingLogCount = 0.obs;
  final hasEnoughLogsForPersonalPredictions = false.obs;

  /// Predicciones de dolor y medicación.
  final painForecasts = <DailySymptomForecast>[].obs;
  final topPainSymptoms = <SymptomPrediction>[].obs;
  final medicationReminder = Rxn<MedicationReminder>();

  final currentSubPhase = CycleSubPhase.earlyFollicular.obs;
  final hormonePhaseInfo = Rxn<HormonePhaseInfo>();
  final suggestedArticles = <Article>[].obs;
  final usesHormonalContraceptive = false.obs;

  CycleRecord? _latestCycle;
  PhaseInfo? _phaseInfo;

  /// True si el día seleccionado coincide con hoy.
  bool get isViewingToday => selectedCycleDay.value == actualCycleDay.value;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Recarga todos los datos de la pantalla Home.
  Future<void> loadData() async {
    final profile = await _userRepo.getProfile();
    _latestCycle = await _cycleRepo.getLatestCycle();

    final avgCycle = await _predictionService.calculateAverageCycle();
    final avgPeriod = await _predictionService.calculateAveragePeriod();

    cycleLength.value = avgCycle.round();
    periodLength.value = avgPeriod.round();

    if (profile != null) {
      await _userRepo.updateAverages(
        cycleLength: avgCycle,
        periodLength: avgPeriod,
      );
    }

    final today = DateTime.now();

    if (_latestCycle != null) {
      final todayDay = CycleCalculator.getCycleDay(
        _latestCycle!.startDate,
        today,
        cycleLength.value,
      );
      actualCycleDay.value = todayDay;
      selectedCycleDay.value = todayDay;
      cycleDay.value = todayDay;
    }

    _updateDisplayForSelectedDay();
    await _loadDailyDots();
    _updateRingData();
    await _loadPredictions();
    await _loadPainPredictions();
    await _loadHormoneAndArticles();
  }

  Future<void> _loadHormoneAndArticles() async {
    final profile = await _userRepo.getProfile();
    usesHormonalContraceptive.value =
        profile?.contraceptiveType.isHormonal ?? false;

    final subPhase = _hormoneService.getSubPhase(
      cycleDay: actualCycleDay.value,
      periodLength: periodLength.value,
      cycleLength: cycleLength.value,
    );
    currentSubPhase.value = subPhase;
    hormonePhaseInfo.value = _hormoneService.getInfo(subPhase);

    suggestedArticles.value = await _articleRepo.getSuggestedArticles(
      subPhase: subPhase,
      phase: currentPhase.value,
      limit: 3,
    );
  }

  /// Recarga predicciones de dolor y recordatorio de medicación.
  Future<void> reloadPainAndMedication() async {
    await _loadPainPredictions();
  }

  Future<void> _loadPainPredictions() async {
    painForecasts.value = await _predictionService.predictPainForecast();
    topPainSymptoms.value = await _predictionService.predictUpcomingSymptoms();
    medicationReminder.value = await _predictionService.predictMedicationReminder();
  }

  /// Selecciona un día del ciclo en el anillo para previsualizar su fase.
  void selectCycleDay(int day) {
    final clamped = day.clamp(1, cycleLength.value);
    if (selectedCycleDay.value == clamped) return;
    selectedCycleDay.value = clamped;
    cycleDay.value = clamped;
    _updateDisplayForSelectedDay();
    _updateRingData();
  }

  /// Vuelve a mostrar el día actual real.
  void resetToToday() {
    selectCycleDay(actualCycleDay.value);
  }

  /// Actualiza fase, textos y enlace según el día seleccionado.
  void _updateDisplayForSelectedDay() {
    final day = selectedCycleDay.value;
    final cycleLen = cycleLength.value;
    final periodLen = periodLength.value;
    final ovulationDay = _phaseService.getOvulationDay(cycleLen);
    final inFertile = _phaseService.isInFertileWindow(
      cycleDay: day,
      cycleLength: cycleLen,
    );

    isSelectedDayFertile.value = inFertile;

    currentPhase.value = _phaseService.getCurrentPhase(
      cycleDay: day,
      periodLength: periodLen,
      cycleLength: cycleLen,
    );

    _phaseInfo = _phaseService.getPhaseInfo(currentPhase.value);

    if (inFertile) {
      phaseLinkText.value = 'home_possible_fertile_day'.tr;
    } else {
      phaseLinkText.value = 'home_about_phase_named'.trParams({
        'name': _phaseInfo!.name,
      });
    }

    _updateCenterMessage(inFertile: inFertile, ovulationDay: ovulationDay);
  }

  /// Fecha calendario correspondiente a un día del ciclo.
  DateTime? _dateForCycleDay(int day) {
    if (_latestCycle == null) return null;
    return AppDateUtils.normalizeDate(
      _latestCycle!.startDate.add(Duration(days: day - 1)),
    );
  }

  /// Actualiza el mensaje central según el día seleccionado y su fase.
  void _updateCenterMessage({
    bool? inFertile,
    int? ovulationDay,
  }) {
    final day = selectedCycleDay.value;
    final phase = currentPhase.value;
    final daysUntil = cycleLength.value - day;
    final selectedDate = _dateForCycleDay(day);
    final fertile = inFertile ??
        _phaseService.isInFertileWindow(
          cycleDay: day,
          cycleLength: cycleLength.value,
        );
    final ovulation = ovulationDay ??
        _phaseService.getOvulationDay(cycleLength.value);

    if (isViewingToday) {
      todaySubtitle.value = AppDateUtils.formatTodayOrDate(DateTime.now());
    } else if (selectedDate != null) {
      todaySubtitle.value = AppDateUtils.formatTodayOrDate(selectedDate);
    }

    if (fertile && day != ovulation) {
      centerMessage.value = 'home_possible_fertile_day'.tr;
      return;
    }

    switch (phase) {
      case CyclePhase.menstruation:
        final periodDay = day.clamp(1, periodLength.value);
        centerMessage.value = isViewingToday
            ? 'Hoy es el día $periodDay de tu menstruación'
            : 'Día $periodDay de menstruación';
        break;
      case CyclePhase.ovulation:
        centerMessage.value = isViewingToday
            ? 'home_ovulation_day'.tr
            : 'home_ovulation_day_selected'.tr;
        break;
      case CyclePhase.luteal:
        if (daysUntil > 0 && daysUntil <= 7) {
          centerMessage.value = daysUntil == 1
              ? '1 día para tu próximo periodo'
              : '$daysUntil días para tu próximo periodo';
        } else {
          centerMessage.value = 'Estás en tu fase lútea';
        }
        break;
      case CyclePhase.follicular:
        centerMessage.value = 'Estás en tu fase folicular';
        break;
    }
  }

  /// Carga puntos de colores desde logs del ciclo actual.
  Future<void> _loadDailyDots() async {
    if (_latestCycle == null) return;

    final logs = await _logRepo.getLogsForCurrentCycle(_latestCycle!.startDate);
    final dots = <CycleDot>[];

    for (final log in logs) {
      final day = AppDateUtils.daysBetween(_latestCycle!.startDate, log.date) + 1;
      dots.addAll(_logToDots(log, day));
    }

    dailyDots.value = dots;
  }

  /// Convierte un DailyLog en puntos de colores para el anillo.
  List<CycleDot> _logToDots(DailyLog log, int day) {
    return LogDotMapper.colorsForLog(log)
        .map((color) => CycleDot(day: day, color: color))
        .toList();
  }

  /// Actualiza datos del anillo circular.
  void _updateRingData() {
    final segments = _phaseService.getRingSegments(
      periodLength: periodLength.value,
      cycleLength: cycleLength.value,
    );
    ringData.value = CycleRingData(
      cycleLength: cycleLength.value,
      periodLength: segments.periodLength,
      currentDay: selectedCycleDay.value,
      isToday: isViewingToday,
      fertileStart: segments.fertileStart,
      fertileEnd: segments.fertileEnd,
      ovulationDay: _phaseService.getOvulationDay(cycleLength.value),
      dots: dailyDots.toList(),
    );
  }

  /// Carga textos de predicciones.
  Future<void> _loadPredictions() async {
    daysUntilPeriod.value = await _predictionService.daysUntilNextPeriod();
    _updateCenterMessage();

    final display = await _predictionService.buildCyclePredictionDisplay();
    nextPeriodText.value = display.nextPeriodText;
    nextFertileWindowText.value = display.nextFertileWindowText;
    trackingLogCount.value = display.trackingLogCount;
    hasEnoughLogsForPersonalPredictions.value =
        display.hasEnoughLogsForPersonalPredictions;
    painPredictionText.value = display.painPredictionText;
    moodPredictionText.value = display.moodPredictionText;
  }

  /// Muestra bottom sheet con info de la fase o ventana fértil del día seleccionado.
  void showPhaseInfo() {
    if (isSelectedDayFertile.value) {
      Get.bottomSheet(
        FertileWindowInfoSheet(
          info: _phaseService.getFertileWindowInfo(),
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
      return;
    }

    final info = _phaseService.getPhaseInfo(currentPhase.value);
    Get.bottomSheet(
      PhaseInfoSheet(phaseInfo: info),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Abre el menú de navegación rápida del Home.
  Future<void> openMenu() async {
    final profile = await _userRepo.getProfile();
    Get.bottomSheet(
      HomeMenuSheet(userName: profile?.name ?? 'Usuario'),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Recarga todos los datos de la pantalla Home.
  Future<void> reloadData() => loadData();
}

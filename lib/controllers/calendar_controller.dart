import 'package:get/get.dart';
import 'package:clune/models/cycle_record.dart';
import 'package:clune/models/daily_log.dart';
import 'package:clune/repositories/cycle_repository.dart';
import 'package:clune/repositories/daily_log_repository.dart';
import 'package:clune/services/prediction_service.dart';
import 'package:clune/services/cycle_phase_service.dart';
import 'package:clune/utils/constants.dart';
import 'package:clune/utils/cycle_calculator.dart';
import 'package:clune/utils/date_utils.dart';

/// Tipo de día en el calendario para coloreado.
enum DayType {
  normal,
  menstruation,
  menstruationPredicted,
  fertile,
  ovulation,
}

/// Información de un día en el calendario.
class CalendarDayInfo {
  final DateTime date;
  final DayType type;
  final List<DailyLog> logs;
  final bool isToday;

  const CalendarDayInfo({
    required this.date,
    this.type = DayType.normal,
    this.logs = const [],
    this.isToday = false,
  });
}

/// Controlador de la vista de calendario mensual.
class CalendarController extends GetxController {
  final CycleRepository _cycleRepo = Get.find();
  final DailyLogRepository _logRepo = Get.find();
  final PredictionService _predictionService = Get.find();
  final CyclePhaseService _phaseService = Get.find();

  /// Mes visible actualmente (siempre día 1 del mes).
  final focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;

  /// Mapa de info por día (fecha normalizada → info).
  final dayInfoMap = <String, CalendarDayInfo>{}.obs;

  /// True mientras se recalculan fases y predicciones del mes.
  final isLoading = false.obs;

  /// Log seleccionado al tocar un día.
  final selectedDayLog = Rxn<DailyLog>();

  /// Fecha seleccionada.
  final selectedDate = Rxn<DateTime>();

  int _cycleLength = AppConstants.defaultCycleLength;
  List<PredictedCycleWindow> _predictedCycles = [];

  @override
  void onInit() {
    super.onInit();
    loadMonthData();
  }

  @override
  void onReady() {
    super.onReady();
    // Segunda carga tras montar la UI (p. ej. datos recién guardados en onboarding).
    loadMonthData();
  }

  /// Carga datos del mes visible.
  Future<void> loadMonthData() async {
    isLoading.value = true;
    try {
      _cycleLength = await _predictionService.resolveCycleLength();

      final month = focusedMonth.value;
      final start = AppDateUtils.firstDayOfMonth(month);
      final end = AppDateUtils.lastDayOfMonth(month);

      _predictedCycles = await _predictionService.predictCyclesInRange(start, end);

      final logs = await _logRepo.getLogsInRange(start, end);
      final cycles = await _cycleRepo.getAllCycles();

      final map = <String, CalendarDayInfo>{};
      final today = AppDateUtils.normalizeDate(DateTime.now());

      for (var d = start.day; d <= end.day; d++) {
        final date = DateTime(month.year, month.month, d);
        final normalized = AppDateUtils.normalizeDate(date);
        final key = normalized.toIso8601String();

        final dayLogs = logs
            .where((l) => AppDateUtils.normalizeDate(l.date) == normalized)
            .toList();

        map[key] = CalendarDayInfo(
          date: normalized,
          type: _getDayType(normalized, cycles, today),
          logs: dayLogs,
          isToday: normalized == today,
        );
      }

      dayInfoMap
        ..clear()
        ..addAll(map);
    } finally {
      isLoading.value = false;
    }
  }

  /// Determina el tipo de día para coloreado.
  DayType _getDayType(DateTime date, List<CycleRecord> cycles, DateTime today) {
    // Menstruación registrada
    for (final cycle in cycles) {
      final end = cycle.endDate ?? today;
      if (AppDateUtils.isDateInRange(date, cycle.startDate, end)) {
        return DayType.menstruation;
      }
    }

    // Fases del ciclo actual o histórico (registrado)
    final context = CycleCalculator.getCycleContextForDate(
      date,
      cycles,
      defaultCycleLength: _cycleLength,
    );
    if (context != null) {
      final cycleDay = context.cycleDayFor(date);

      if (!context.isCurrentCycle || cycleDay <= context.cycleLength) {
        final ovulationDay = _phaseService.getOvulationDay(context.cycleLength);
        final fertile = _phaseService.getFertileWindowDays(context.cycleLength);

        if (cycleDay == ovulationDay) {
          return DayType.ovulation;
        }
        if (cycleDay >= fertile.start && cycleDay <= fertile.end) {
          return DayType.fertile;
        }
      }
    }

    // Predicciones futuras (todos los ciclos proyectados)
    if (!date.isBefore(today)) {
      for (final predicted in _predictedCycles) {
        if (AppDateUtils.isDateInRange(date, predicted.periodStart, predicted.periodEnd)) {
          return DayType.menstruationPredicted;
        }
      }

      for (final predicted in _predictedCycles) {
        if (AppDateUtils.normalizeDate(date) ==
            AppDateUtils.normalizeDate(predicted.ovulationDate)) {
          return DayType.ovulation;
        }
        if (AppDateUtils.isDateInRange(
          date,
          predicted.fertileStart,
          predicted.fertileEnd,
        )) {
          return DayType.fertile;
        }
      }
    }

    return DayType.normal;
  }

  /// Cambia al mes anterior.
  void previousMonth() {
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month - 1, 1);
    loadMonthData();
  }

  /// Cambia al mes siguiente.
  void nextMonth() {
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month + 1, 1);
    loadMonthData();
  }

  /// Selecciona un día y carga su log.
  Future<void> selectDay(DateTime date) async {
    selectedDate.value = date;
    selectedDayLog.value = await _logRepo.getLogForDate(date);
  }

  /// Obtiene info de un día del mapa.
  CalendarDayInfo? getDayInfo(DateTime date) {
    final key = AppDateUtils.normalizeDate(date).toIso8601String();
    return dayInfoMap[key];
  }
}

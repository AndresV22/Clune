import 'package:clune/models/cycle_record.dart';
import 'package:clune/models/daily_log.dart';
import 'package:clune/repositories/cycle_repository.dart';
import 'package:clune/repositories/daily_log_repository.dart';
import 'package:clune/repositories/user_repository.dart';
import 'package:clune/utils/constants.dart';
import 'package:clune/utils/cycle_calculator.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/utils/prediction_formatter.dart';
import 'package:clune/models/cycle_prediction_display.dart';

/// Predicción de un síntoma con probabilidad.
class SymptomPrediction {
  final String name;
  final String label;
  final double probability;
  final DateTime? date;

  const SymptomPrediction({
    required this.name,
    required this.label,
    required this.probability,
    this.date,
  });
}

/// Síntomas previstos para un día concreto.
class DailySymptomForecast {
  final DateTime date;
  final int cycleDay;
  final List<SymptomPrediction> symptoms;

  const DailySymptomForecast({
    required this.date,
    required this.cycleDay,
    required this.symptoms,
  });
}

/// Recordatorio para empezar medicación antiinflamatoria.
class MedicationReminder {
  final String medication;
  final DateTime recommendedStartDate;
  final DateTime predictedPainDate;
  final int daysUntilStart;
  final double painProbability;

  const MedicationReminder({
    required this.medication,
    required this.recommendedStartDate,
    required this.predictedPainDate,
    required this.daysUntilStart,
    required this.painProbability,
  });

  bool get shouldStartNow => daysUntilStart <= 0;
}

/// Resultado de predicción de ventana fértil.
class FertileWindowPrediction {
  final DateTime ovulationDate;
  final DateTime windowStart;
  final DateTime windowEnd;

  const FertileWindowPrediction({
    required this.ovulationDate,
    required this.windowStart,
    required this.windowEnd,
  });

  bool containsDate(DateTime date) {
    final normalized = AppDateUtils.normalizeDate(date);
    return !normalized.isBefore(windowStart) && !normalized.isAfter(windowEnd);
  }
}

/// Predicción de dolor en un día próximo.
class PainDayPrediction {
  final String label;
  final double probability;
  final DateTime date;
  final int daysUntil;

  const PainDayPrediction({
    required this.label,
    required this.probability,
    required this.date,
    required this.daysUntil,
  });
}

/// Predicción de estado de ánimo en un día próximo.
class MoodPrediction {
  final MoodType mood;
  final double probability;
  final DateTime date;
  final int daysUntil;

  const MoodPrediction({
    required this.mood,
    required this.probability,
    required this.date,
    required this.daysUntil,
  });
}

/// Ciclo menstrual predicho con sus fases para el calendario.
class PredictedCycleWindow {
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime ovulationDate;
  final DateTime fertileStart;
  final DateTime fertileEnd;

  const PredictedCycleWindow({
    required this.periodStart,
    required this.periodEnd,
    required this.ovulationDate,
    required this.fertileStart,
    required this.fertileEnd,
  });
}

/// Servicio de predicciones basado en historial de ciclos.
class PredictionService {
  final CycleRepository _cycleRepo;
  final DailyLogRepository _logRepo;
  final UserRepository _userRepo;

  PredictionService(this._cycleRepo, this._logRepo, this._userRepo);

  /// Duración de ciclo estimada (historial o perfil del onboarding).
  Future<int> resolveCycleLength() async {
    return (await _resolveAverageCycle()).round();
  }

  Future<double> _resolveAverageCycle() async {
    final cycles = await _cycleRepo.getAllCycles();
    final durations = CycleCalculator.getCycleDurations(cycles);
    if (durations.isNotEmpty) {
      return CycleCalculator.average(
        durations,
        defaultValue: AppConstants.defaultCycleLength.toDouble(),
      );
    }

    final profile = await _userRepo.getProfile();
    return profile?.averageCycleLength ?? AppConstants.defaultCycleLength.toDouble();
  }

  /// Calcula duración promedio del ciclo.
  Future<double> calculateAverageCycle() async {
    return _resolveAverageCycle();
  }

  /// Calcula duración promedio del periodo (últimos ciclos completados).
  Future<double> calculateAveragePeriod() async {
    final cycles = await _cycleRepo.getAllCycles();
    return CycleCalculator.averageRecentPeriod(
      cycles,
      defaultValue: AppConstants.defaultPeriodLength.toDouble(),
    );
  }

  /// Predice la fecha del próximo periodo.
  Future<DateTime> predictNextPeriod() async {
    final cycles = await _cycleRepo.getAllCycles();
    if (cycles.isEmpty) {
      return AppDateUtils.normalizeDate(
        DateTime.now().add(const Duration(days: AppConstants.defaultCycleLength)),
      );
    }

    final sorted = List<CycleRecord>.from(cycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final lastStart = AppDateUtils.normalizeDate(sorted.last.startDate);
    final durations = CycleCalculator.getCycleDurations(sorted);

    double avgCycle;
    if (durations.length >= 3) {
      final recent = durations.sublist(durations.length - 3);
      final recentAvg = CycleCalculator.average(recent);
      final overallAvg = CycleCalculator.average(durations);
      if ((recentAvg - overallAvg).abs() > 2) {
        avgCycle = CycleCalculator.weightedAverageCycle(durations);
      } else {
        avgCycle = overallAvg;
      }
    } else if (durations.isEmpty) {
      avgCycle = await _resolveAverageCycle();
    } else {
      avgCycle = CycleCalculator.average(durations);
    }

    return AppDateUtils.normalizeDate(
      lastStart.add(Duration(days: avgCycle.round())),
    );
  }

  /// Predice la fecha de ovulación.
  Future<DateTime> predictOvulation() async {
    final nextPeriod = await predictNextPeriod();
    return AppDateUtils.normalizeDate(
      nextPeriod.subtract(const Duration(days: AppConstants.lutealPhaseLength)),
    );
  }

  /// Predice la ventana fértil del ciclo proyectado desde el último periodo.
  /// Puede devolver una ventana ya pasada; preferir [predictNextFertileWindow].
  Future<FertileWindowPrediction> predictFertileWindow() async {
    final ovulation = await predictOvulation();
    return _fertileWindowForOvulation(ovulation);
  }

  /// Próxima ventana fértil que aún no ha terminado (incluye la actual si aplica).
  Future<FertileWindowPrediction> predictNextFertileWindow() async {
    final latest = await _cycleRepo.getLatestCycle();
    final today = AppDateUtils.normalizeDate(DateTime.now());
    final cycleLength = await resolveCycleLength();
    final periodLength = (await calculateAveragePeriod()).round();

    if (latest == null) {
      final fallback = await predictFertileWindow();
      if (!fallback.windowEnd.isBefore(today)) return fallback;
      return _fertileWindowForOvulation(
        fallback.ovulationDate.add(Duration(days: cycleLength)),
      );
    }

    var periodStart = AppDateUtils.normalizeDate(latest.startDate);
    for (var i = 0; i < 24; i++) {
      final window = _buildPredictedCycle(
        periodStart: periodStart,
        cycleLength: cycleLength,
        periodLength: periodLength,
      );
      if (!window.fertileEnd.isBefore(today)) {
        return FertileWindowPrediction(
          ovulationDate: window.ovulationDate,
          windowStart: window.fertileStart,
          windowEnd: window.fertileEnd,
        );
      }
      periodStart = AppDateUtils.normalizeDate(
        periodStart.add(Duration(days: cycleLength)),
      );
    }

    return predictFertileWindow();
  }

  /// Días hasta el inicio de la próxima ventana fértil (0 si ya estás en ella).
  Future<int> daysUntilNextFertileWindow() async {
    final window = await predictNextFertileWindow();
    final today = AppDateUtils.normalizeDate(DateTime.now());
    if (window.containsDate(today)) return 0;
    return AppDateUtils.daysBetween(today, window.windowStart);
  }

  /// Total de registros diarios guardados.
  Future<int> countTrackingLogs() async {
    final logs = await _logRepo.getAllLogs();
    return logs.length;
  }

  /// True si hay historial suficiente para predicciones personalizadas.
  Future<bool> hasEnoughDataForPersonalPredictions() async {
    return (await countTrackingLogs()) >= AppConstants.minimumLogsForPredictions;
  }

  /// Próximo día con dolor probable según patrones históricos.
  Future<PainDayPrediction?> predictNextPainDay() async {
    if (!await hasEnoughDataForPersonalPredictions()) return null;

    final forecasts = await predictPainForecast(daysAhead: 28);
    if (forecasts.isEmpty) return null;

    final today = AppDateUtils.normalizeDate(DateTime.now());
    for (final day in forecasts) {
      if (day.symptoms.isEmpty) continue;
      final daysUntil = AppDateUtils.daysBetween(today, day.date);
      if (daysUntil < 0) continue;
      final top = day.symptoms.first;
      return PainDayPrediction(
        label: top.label,
        probability: top.probability,
        date: day.date,
        daysUntil: daysUntil,
      );
    }
    return null;
  }

  /// Estado de ánimo más probable en los próximos días según el día del ciclo.
  Future<MoodPrediction?> predictUpcomingMood() async {
    if (!await hasEnoughDataForPersonalPredictions()) return null;

    final cycles = await _cycleRepo.getAllCycles();
    if (cycles.isEmpty) return null;

    final sorted = List<CycleRecord>.from(cycles)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final recent = sorted.take(AppConstants.symptomPredictionCycles).toList();
    final latest = recent.first;
    final cycleLength = await resolveCycleLength();
    final today = AppDateUtils.normalizeDate(DateTime.now());

    for (var offset = 0; offset <= 14; offset++) {
      final date = today.add(Duration(days: offset));
      final cycleDay = CycleCalculator.getCycleDay(
        latest.startDate,
        date,
        cycleLength,
      );

      final moodCounts = <MoodType, int>{};
      var samples = 0;

      for (final cycle in recent) {
        final length = _cycleLengthFor(cycle, sorted, cycleLength);
        if (cycleDay > length) continue;

        final logDate = AppDateUtils.normalizeDate(
          cycle.startDate.add(Duration(days: cycleDay - 1)),
        );
        final log = await _logRepo.getLogForDate(logDate);
        if (log == null) continue;

        moodCounts[log.mood] = (moodCounts[log.mood] ?? 0) + 1;
        samples++;
      }

      if (samples < 2) continue;

      final top = moodCounts.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      final probability = (top.value / samples) * 100;
      if (probability < 35) continue;

      return MoodPrediction(
        mood: top.key,
        probability: probability,
        date: date,
        daysUntil: offset,
      );
    }

    return null;
  }

  /// Predice todos los ciclos futuros que caen dentro de un rango de fechas.
  Future<List<PredictedCycleWindow>> predictCyclesInRange(
    DateTime rangeStart,
    DateTime rangeEnd,
  ) async {
    final recorded = await _cycleRepo.getAllCycles();
    if (recorded.isEmpty) return [];

    final cycleLength = await resolveCycleLength();
    final periodLength = (await calculateAveragePeriod()).round();
    final start = AppDateUtils.normalizeDate(rangeStart);
    final end = AppDateUtils.normalizeDate(rangeEnd);

    final sorted = List<CycleRecord>.from(recorded)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    var periodStart = AppDateUtils.normalizeDate(sorted.last.startDate);

    final cycles = <PredictedCycleWindow>[];
    var safety = 0;

    // Proyecta desde el último periodo registrado (incluye ciclo actual + futuros).
    while (
      periodStart.isBefore(end.add(Duration(days: cycleLength))) &&
      safety < 48
    ) {
      final window = _buildPredictedCycle(
        periodStart: periodStart,
        cycleLength: cycleLength,
        periodLength: periodLength,
      );

      if (_predictedWindowOverlapsRange(window, start, end)) {
        cycles.add(window);
      }

      periodStart = AppDateUtils.normalizeDate(
        periodStart.add(Duration(days: cycleLength)),
      );
      safety++;
    }

    return cycles;
  }

  bool _predictedWindowOverlapsRange(
    PredictedCycleWindow window,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final windowStart = window.fertileStart.isBefore(window.periodStart)
        ? window.fertileStart
        : window.periodStart;
    final windowEnd = window.periodEnd.isAfter(window.fertileEnd)
        ? window.periodEnd
        : window.fertileEnd;

    return !windowEnd.isBefore(rangeStart) && !windowStart.isAfter(rangeEnd);
  }

  PredictedCycleWindow _buildPredictedCycle({
    required DateTime periodStart,
    required int cycleLength,
    required int periodLength,
  }) {
    final normalizedStart = AppDateUtils.normalizeDate(periodStart);
    final periodEnd = normalizedStart.add(Duration(days: periodLength - 1));
    final ovulationDay = cycleLength - AppConstants.lutealPhaseLength;
    final ovulationDate = normalizedStart.add(Duration(days: ovulationDay - 1));
    final fertile = _fertileWindowForOvulation(ovulationDate);

    return PredictedCycleWindow(
      periodStart: normalizedStart,
      periodEnd: periodEnd,
      ovulationDate: ovulationDate,
      fertileStart: fertile.windowStart,
      fertileEnd: fertile.windowEnd,
    );
  }

  FertileWindowPrediction _fertileWindowForOvulation(DateTime ovulation) {
    final normalized = AppDateUtils.normalizeDate(ovulation);
    return FertileWindowPrediction(
      ovulationDate: normalized,
      windowStart: normalized.subtract(
        const Duration(days: AppConstants.fertileDaysBefore),
      ),
      windowEnd: normalized.add(
        const Duration(days: AppConstants.fertileDaysAfter),
      ),
    );
  }

  /// Predice probabilidad de un síntoma para una fecha según el día de ciclo histórico.
  Future<double> predictSymptomProbability({
    required String symptomKey,
    required bool Function(DailyLog) matcher,
    DateTime? targetDate,
  }) async {
    final cycles = await _cycleRepo.getAllCycles();
    if (cycles.isEmpty) return 0;

    final sorted = List<CycleRecord>.from(cycles)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final recentCycles = sorted.take(AppConstants.symptomPredictionCycles).toList();
    final latest = recentCycles.first;
    final cycleLength = await resolveCycleLength();

    final target = AppDateUtils.normalizeDate(targetDate ?? DateTime.now().add(const Duration(days: 1)));
    final targetCycleDay = CycleCalculator.getCycleDay(
      latest.startDate,
      target,
      cycleLength,
    );

    var matchCount = 0;
    var analyzedCycles = 0;

    for (final cycle in recentCycles) {
      final length = _cycleLengthFor(cycle, sorted, cycleLength);
      if (targetCycleDay > length) continue;

      analyzedCycles++;
      final logDate = AppDateUtils.normalizeDate(
        cycle.startDate.add(Duration(days: targetCycleDay - 1)),
      );
      final log = await _logRepo.getLogForDate(logDate);
      if (log != null && matcher(log)) matchCount++;
    }

    if (analyzedCycles == 0) return 0;
    return (matchCount / analyzedCycles) * 100;
  }

  int _cycleLengthFor(
    CycleRecord cycle,
    List<CycleRecord> sorted,
    int defaultLength,
  ) {
    final index = sorted.indexOf(cycle);
    if (index <= 0) return defaultLength;
    final previous = sorted[index - 1];
    return AppDateUtils.daysBetween(previous.startDate, cycle.startDate);
  }

  static const _symptomDefinitions = [
    ('cramps', 'Cólicos', _isCrampDay),
    ('bleeding', 'Sangrado', _hasBleeding),
    ('heavy_bleeding', 'Sangrado fuerte', _hasHeavyBleeding),
    ('headache', 'Dolor de cabeza', _hasHeadache),
    ('bloating', 'Hinchazón', _hasBloating),
    ('breast_tenderness', 'Sensibilidad mamaria', _hasBreastTenderness),
  ];

  static bool _isCrampDay(DailyLog log) =>
      log.cramps || log.pain.index >= PainLevel.moderate.index;

  static bool _hasBleeding(DailyLog log) =>
      log.bleeding.index >= BleedingLevel.light.index;

  static bool _hasHeavyBleeding(DailyLog log) =>
      log.bleeding == BleedingLevel.heavy;

  static bool _hasHeadache(DailyLog log) =>
      log.symptoms.contains(SymptomType.headache.name);

  static bool _hasBloating(DailyLog log) =>
      log.symptoms.contains(SymptomType.bloating.name);

  static bool _hasBreastTenderness(DailyLog log) =>
      log.symptoms.contains(SymptomType.breastTenderness.name);

  /// Pronóstico de síntomas de dolor para los próximos [daysAhead] días.
  Future<List<DailySymptomForecast>> predictPainForecast({int daysAhead = 14}) async {
    final latest = await _cycleRepo.getLatestCycle();
    if (latest == null) return [];

    final cycleLength = await resolveCycleLength();
    final today = AppDateUtils.normalizeDate(DateTime.now());
    final forecasts = <DailySymptomForecast>[];

    for (var i = 0; i <= daysAhead; i++) {
      final date = today.add(Duration(days: i));
      final cycleDay = CycleCalculator.getCycleDay(
        latest.startDate,
        date,
        cycleLength,
      );

      final symptoms = <SymptomPrediction>[];
      for (final (name, label, matcher) in _symptomDefinitions) {
        final prob = await predictSymptomProbability(
          symptomKey: name,
          matcher: matcher,
          targetDate: date,
        );
        if (prob >= 25) {
          symptoms.add(SymptomPrediction(
            name: name,
            label: label,
            probability: prob,
            date: date,
          ));
        }
      }

      symptoms.sort((a, b) => b.probability.compareTo(a.probability));
      if (symptoms.isNotEmpty) {
        forecasts.add(DailySymptomForecast(
          date: date,
          cycleDay: cycleDay,
          symptoms: symptoms,
        ));
      }
    }

    return forecasts;
  }

  /// Resumen de síntomas más probables en los próximos días (para tarjetas).
  Future<List<SymptomPrediction>> predictUpcomingSymptoms() async {
    final forecast = await predictPainForecast(daysAhead: 7);
    final aggregated = <String, SymptomPrediction>{};

    for (final day in forecast) {
      for (final symptom in day.symptoms) {
        final existing = aggregated[symptom.name];
        if (existing == null || symptom.probability > existing.probability) {
          aggregated[symptom.name] = SymptomPrediction(
            name: symptom.name,
            label: symptom.label,
            probability: symptom.probability,
            date: day.date,
          );
        }
      }
    }

    final list = aggregated.values.toList()
      ..sort((a, b) => b.probability.compareTo(a.probability));
    return list;
  }

  /// Calcula cuándo empezar la medicación preferida según patrones de dolor.
  Future<MedicationReminder?> predictMedicationReminder() async {
    final profile = await _userRepo.getProfile();
    if (profile == null || profile.preferredPainMedication.isEmpty) return null;

    final latest = await _cycleRepo.getLatestCycle();
    if (latest == null) return null;

    final cycleLength = await resolveCycleLength();
    final firstPainDay = await _averageFirstPainCycleDay(cycleLength);
    final painDate = await _nextDateForCycleDay(firstPainDay);
    final leadDays = profile.safePainMedicationLeadDays;
    final startDate = AppDateUtils.normalizeDate(
      painDate.subtract(Duration(days: leadDays)),
    );
    final today = AppDateUtils.normalizeDate(DateTime.now());
    final painProb = await predictSymptomProbability(
      symptomKey: 'cramps',
      matcher: _isCrampDay,
      targetDate: painDate,
    );

    return MedicationReminder(
      medication: profile.preferredPainMedication,
      recommendedStartDate: startDate,
      predictedPainDate: painDate,
      daysUntilStart: AppDateUtils.daysBetween(today, startDate),
      painProbability: painProb,
    );
  }

  Future<int> _averageFirstPainCycleDay(int defaultCycleLength) async {
    final cycles = await _cycleRepo.getAllCycles();
    if (cycles.isEmpty) return defaultCycleLength;

    final sorted = List<CycleRecord>.from(cycles)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final recent = sorted.take(AppConstants.symptomPredictionCycles).toList();
    final firstDays = <int>[];

    for (final cycle in recent) {
      final length = _cycleLengthFor(cycle, sorted, defaultCycleLength);
      for (var day = 1; day <= length; day++) {
        final logDate = AppDateUtils.normalizeDate(
          cycle.startDate.add(Duration(days: day - 1)),
        );
        final log = await _logRepo.getLogForDate(logDate);
        if (log != null && _isCrampDay(log)) {
          firstDays.add(day);
          break;
        }
      }
    }

    if (firstDays.isEmpty) {
      return (defaultCycleLength - 1).clamp(1, defaultCycleLength);
    }

    return (firstDays.reduce((a, b) => a + b) / firstDays.length).round();
  }

  Future<DateTime> _nextDateForCycleDay(int cycleDay) async {
    final latest = await _cycleRepo.getLatestCycle();
    if (latest == null) return AppDateUtils.normalizeDate(DateTime.now());

    final cycleLength = await resolveCycleLength();
    var candidate = AppDateUtils.normalizeDate(
      latest.startDate.add(Duration(days: cycleDay - 1)),
    );
    final today = AppDateUtils.normalizeDate(DateTime.now());

    while (candidate.isBefore(today)) {
      candidate = AppDateUtils.normalizeDate(
        candidate.add(Duration(days: cycleLength)),
      );
    }

    return candidate;
  }

  /// Predice probabilidad de cólicos.
  Future<double> predictPainProbability({DateTime? targetDate}) {
    return predictSymptomProbability(
      symptomKey: 'cramps',
      matcher: _isCrampDay,
      targetDate: targetDate,
    );
  }

  /// Obtiene la medicación preferida configurada.
  Future<String?> getPreferredPainMedication() async {
    final profile = await _userRepo.getProfile();
    final med = profile?.preferredPainMedication ?? '';
    return med.isEmpty ? null : med;
  }
  Future<int> daysUntilNextPeriod() async {
    final next = await predictNextPeriod();
    return AppDateUtils.daysBetween(DateTime.now(), next);
  }

  /// Días restantes hasta ovulación del ciclo proyectado (puede ser negativo).
  Future<int> daysUntilOvulation() async {
    final ovulation = await predictOvulation();
    return AppDateUtils.daysBetween(DateTime.now(), ovulation);
  }

  /// Construye los textos de predicción para Home y Análisis.
  Future<CyclePredictionDisplay> buildCyclePredictionDisplay() async {
    final daysPeriod = await daysUntilNextPeriod();
    final fertileWindow = await predictNextFertileWindow();
    final daysFertile = await daysUntilNextFertileWindow();
    final inFertileWindow = fertileWindow.containsDate(DateTime.now());
    final logCount = await countTrackingLogs();
    final hasEnoughLogs = logCount >= AppConstants.minimumLogsForPredictions;

    String? painText;
    String? moodText;
    if (hasEnoughLogs) {
      final pain = await predictNextPainDay();
      if (pain != null) {
        painText = PredictionFormatter.painValue(pain);
      }
      final mood = await predictUpcomingMood();
      if (mood != null) {
        moodText = PredictionFormatter.moodValue(mood);
      }
    }

    return CyclePredictionDisplay(
      nextPeriodText: PredictionFormatter.daysUntil(daysPeriod),
      nextFertileWindowText: PredictionFormatter.daysUntil(
        daysFertile,
        inProgress: inFertileWindow,
      ),
      trackingLogCount: logCount,
      hasEnoughLogsForPersonalPredictions: hasEnoughLogs,
      painPredictionText: painText,
      moodPredictionText: moodText,
    );
  }
}

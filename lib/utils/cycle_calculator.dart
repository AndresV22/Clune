import 'package:clune/models/cycle_record.dart';
import 'package:clune/utils/constants.dart';
import 'package:clune/utils/date_utils.dart';

/// Cálculos auxiliares sobre duraciones de ciclo.
class CycleCalculator {
  CycleCalculator._();

  /// Calcula duraciones de ciclo a partir de registros ordenados por fecha.
  static List<int> getCycleDurations(List<CycleRecord> cycles) {
    if (cycles.length < 2) return [];
    final sorted = List<CycleRecord>.from(cycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final durations = <int>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      durations.add(
        AppDateUtils.daysBetween(sorted[i].startDate, sorted[i + 1].startDate),
      );
    }
    return durations;
  }

  /// Calcula duraciones de periodo (menstruación).
  static List<int> getPeriodDurations(List<CycleRecord> cycles) {
    return cycles
        .where((c) => c.endDate != null)
        .map((c) => AppDateUtils.daysBetween(c.startDate, c.endDate!) + 1)
        .where((d) => d >= 2 && d <= 10)
        .toList();
  }

  /// Promedio de duración de periodo usando los ciclos completados más recientes.
  static double averageRecentPeriod(
    List<CycleRecord> cycles, {
    int recentCount = 3,
    double defaultValue = 5.0,
  }) {
    final durations = getPeriodDurations(cycles);
    if (durations.isEmpty) return defaultValue;
    if (durations.length <= recentCount) {
      return average(durations, defaultValue: defaultValue);
    }
    final recent = durations.sublist(durations.length - recentCount);
    return average(recent, defaultValue: defaultValue);
  }

  /// Promedio de una lista de enteros; retorna default si está vacía.
  static double average(List<int> values, {double defaultValue = 0}) {
    if (values.isEmpty) return defaultValue;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Desviación estándar de duraciones de ciclo.
  static double standardDeviation(List<int> values) {
    if (values.length < 2) return 0;
    final mean = average(values);
    final variance = values
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
        values.length;
    return variance > 0 ? variance : 0;
  }

  /// Media móvil ponderada (ciclos recientes peso 2x).
  static double weightedAverageCycle(List<int> durations) {
    if (durations.isEmpty) return AppConstants.defaultCycleLength.toDouble();
    if (durations.length <= 3) return average(durations, defaultValue: AppConstants.defaultCycleLength.toDouble());

    final recent = durations.sublist(durations.length - 3);
    final older = durations.sublist(0, durations.length - 3);
    final recentAvg = average(recent);
    final olderAvg = older.isEmpty ? recentAvg : average(older);
    return (recentAvg * 2 + olderAvg) / 3;
  }

  /// Día del ciclo actual (1-indexed) respecto al inicio del último periodo.
  static int getCycleDay(DateTime cycleStart, DateTime today, int cycleLength) {
    final days = AppDateUtils.daysBetween(cycleStart, today) + 1;
    if (days <= 0) return 1;
    if (days > cycleLength) return ((days - 1) % cycleLength) + 1;
    return days;
  }

  /// Contexto de ciclo al que pertenece una fecha (para fases históricas).
  static CycleContext? getCycleContextForDate(
    DateTime date,
    List<CycleRecord> cycles, {
    required int defaultCycleLength,
  }) {
    if (cycles.isEmpty) return null;

    final sorted = List<CycleRecord>.from(cycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final d = AppDateUtils.normalizeDate(date);

    for (var i = sorted.length - 1; i >= 0; i--) {
      final start = AppDateUtils.normalizeDate(sorted[i].startDate);
      if (start.isAfter(d)) continue;

      final next = i + 1 < sorted.length ? sorted[i + 1] : null;
      if (next != null) {
        final nextStart = AppDateUtils.normalizeDate(next.startDate);
        if (!d.isBefore(nextStart)) continue;
        return CycleContext(
          cycleStart: start,
          cycleLength: AppDateUtils.daysBetween(start, nextStart),
          isCurrentCycle: false,
        );
      }

      return CycleContext(
        cycleStart: start,
        cycleLength: defaultCycleLength,
        isCurrentCycle: true,
      );
    }

    return null;
  }
}

/// Ciclo menstrual que contiene una fecha concreta.
class CycleContext {
  final DateTime cycleStart;
  final int cycleLength;
  final bool isCurrentCycle;

  const CycleContext({
    required this.cycleStart,
    required this.cycleLength,
    required this.isCurrentCycle,
  });

  int cycleDayFor(DateTime date) {
    return AppDateUtils.daysBetween(cycleStart, date) + 1;
  }
}

import 'dart:math' as math;
import 'package:clune/repositories/cycle_repository.dart';
import 'package:clune/repositories/daily_log_repository.dart';
import 'package:clune/utils/constants.dart';
import 'package:clune/utils/cycle_calculator.dart';
import 'package:clune/utils/enums.dart';

/// Punto de datos para gráficos de historial.
class ChartDataPoint {
  final int index;
  final double value;
  final String label;

  const ChartDataPoint({
    required this.index,
    required this.value,
    required this.label,
  });
}

/// Frecuencia de un síntoma.
class SymptomFrequency {
  final String name;
  final String label;
  final int count;
  final double percentage;

  const SymptomFrequency({
    required this.name,
    required this.label,
    required this.count,
    required this.percentage,
  });
}

/// Servicio de estadísticas y análisis del ciclo.
class StatisticsService {
  final CycleRepository _cycleRepo;
  final DailyLogRepository _logRepo;

  StatisticsService(this._cycleRepo, this._logRepo);

  /// Calcula desviación estándar de duraciones de ciclo.
  Future<double> calculateStandardDeviation() async {
    final cycles = await _cycleRepo.getAllCycles();
    final durations = CycleCalculator.getCycleDurations(cycles);
    if (durations.length < 2) return 0;
    final mean = CycleCalculator.average(durations);
    final variance = durations
            .map((v) => math.pow(v - mean, 2))
            .reduce((a, b) => a + b) /
        durations.length;
    return math.sqrt(variance);
  }

  /// Clasifica la regularidad del ciclo.
  Future<CycleRegularity> calculateRegularity() async {
    final stdDev = await calculateStandardDeviation();
    if (stdDev <= AppConstants.veryRegularStdDev) return CycleRegularity.veryRegular;
    if (stdDev <= AppConstants.regularStdDev) return CycleRegularity.regular;
    return CycleRegularity.irregular;
  }

  /// Historial de duración de ciclos para gráfico de línea.
  Future<List<ChartDataPoint>> getCycleDurationHistory() async {
    final cycles = await _cycleRepo.getAllCycles();
    final durations = CycleCalculator.getCycleDurations(cycles);
    return List.generate(
      durations.length,
      (i) => ChartDataPoint(
        index: i + 1,
        value: durations[i].toDouble(),
        label: 'C${i + 1}',
      ),
    );
  }

  /// Historial de duración de periodos para gráfico de barras.
  Future<List<ChartDataPoint>> getPeriodDurationHistory() async {
    final cycles = await _cycleRepo.getAllCycles();
    final durations = CycleCalculator.getPeriodDurations(cycles);
    return List.generate(
      durations.length,
      (i) => ChartDataPoint(
        index: i + 1,
        value: durations[i].toDouble(),
        label: 'P${i + 1}',
      ),
    );
  }

  /// Intensidad promedio de dolor por ciclo.
  Future<List<ChartDataPoint>> getPainIntensityByCycle() async {
    final cycles = await _cycleRepo.getAllCycles();
    final points = <ChartDataPoint>[];

    for (var i = 0; i < cycles.length; i++) {
      final cycle = cycles[i];
      final end = cycle.endDate ?? DateTime.now();
      final logs = await _logRepo.getLogsInRange(cycle.startDate, end);
      if (logs.isEmpty) continue;

      final avgPain = logs.map((l) => l.pain.index).reduce((a, b) => a + b) / logs.length;
      points.add(ChartDataPoint(
        index: i + 1,
        value: avgPain,
        label: 'C${i + 1}',
      ));
    }
    return points;
  }

  /// Frecuencia de síntomas en todos los registros.
  Future<List<SymptomFrequency>> calculateSymptomFrequency() async {
    final logs = await _logRepo.getAllLogs();
    if (logs.isEmpty) return [];

    final symptomLabels = {
      SymptomType.headache.name: 'Dolor de cabeza',
      SymptomType.breastTenderness.name: 'Sensibilidad mamaria',
      SymptomType.bloating.name: 'Hinchazón',
      SymptomType.acne.name: 'Acné',
      SymptomType.fatigue.name: 'Cansancio',
      SymptomType.nausea.name: 'Náuseas',
      SymptomType.insomnia.name: 'Insomnio',
    };

    final counts = <String, int>{};
    for (final log in logs) {
      for (final symptom in log.symptoms) {
        counts[symptom] = (counts[symptom] ?? 0) + 1;
      }
      if (log.cramps) counts['cramps'] = (counts['cramps'] ?? 0) + 1;
    }

    final total = logs.length;
    return counts.entries.map((e) {
      return SymptomFrequency(
        name: e.key,
        label: symptomLabels[e.key] ?? (e.key == 'cramps' ? 'Cólicos' : e.key),
        count: e.value,
        percentage: (e.value / total) * 100,
      );
    }).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  /// Distribución de estados de ánimo.
  Future<Map<MoodType, int>> getMoodDistribution() async {
    final logs = await _logRepo.getAllLogs();
    final distribution = <MoodType, int>{};
    for (final mood in MoodType.values) {
      distribution[mood] = 0;
    }
    for (final log in logs) {
      distribution[log.mood] = (distribution[log.mood] ?? 0) + 1;
    }
    return distribution;
  }
}

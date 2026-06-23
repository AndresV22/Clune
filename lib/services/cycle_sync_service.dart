import 'package:clune/models/cycle_record.dart';
import 'package:clune/models/daily_log.dart';
import 'package:clune/repositories/cycle_repository.dart';
import 'package:clune/repositories/daily_log_repository.dart';
import 'package:clune/services/prediction_service.dart';
import 'package:clune/utils/constants.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/utils/enums.dart';

/// Sincroniza registros de sangrado con el historial de periodos.
class CycleSyncService {
  final CycleRepository _cycleRepo;
  final DailyLogRepository _logRepo;
  final PredictionService _predictionService;

  CycleSyncService(
    this._cycleRepo,
    this._logRepo,
    this._predictionService,
  );

  /// Si el sangrado indica inicio de periodo antes de lo predicho, actualiza el ciclo.
  /// Devuelve la fecha de inicio actualizada o null si no hubo cambios.
  Future<DateTime?> syncBleedingToCycle(DailyLog log) async {
    if (log.bleeding.index < BleedingLevel.light.index) return null;

    final logDate = AppDateUtils.normalizeDate(log.date);
    final daysUntil = await _predictionService.daysUntilNextPeriod();
    final latest = await _cycleRepo.getLatestCycle();
    final avgPeriod = (await _predictionService.calculateAveragePeriod()).round();

    if (latest != null) {
      final start = AppDateUtils.normalizeDate(latest.startDate);
      final daysSinceStart = AppDateUtils.daysBetween(start, logDate);

      if (daysSinceStart >= 0 && daysSinceStart < avgPeriod) {
        return null;
      }

      if (daysSinceStart >= avgPeriod && daysSinceStart < AppConstants.defaultCycleLength) {
        if (latest.endDate == null || latest.endDate!.isBefore(logDate)) {
          latest.endDate = logDate.subtract(const Duration(days: 1));
          latest.updatedAt = DateTime.now();
          await _cycleRepo.saveCycle(latest);
        }
      }
    }

    if (daysUntil <= 0) return null;

    final existing = await _findCycleCoveringDate(logDate);
    if (existing != null) return null;

    final cycle = CycleRecord()
      ..startDate = logDate
      ..endDate = await _estimatePeriodEnd(logDate, avgPeriod)
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _cycleRepo.saveCycle(cycle);
    return logDate;
  }

  Future<CycleRecord?> _findCycleCoveringDate(DateTime date) async {
    final cycles = await _cycleRepo.getAllCycles();
    for (final cycle in cycles) {
      final start = AppDateUtils.normalizeDate(cycle.startDate);
      final end = cycle.endDate != null
          ? AppDateUtils.normalizeDate(cycle.endDate!)
          : start.add(Duration(days: AppConstants.defaultPeriodLength - 1));
      if (AppDateUtils.isDateInRange(date, start, end)) {
        return cycle;
      }
    }
    return null;
  }

  Future<DateTime?> _estimatePeriodEnd(DateTime start, int avgPeriod) async {
    var end = start;
    for (var i = 0; i < avgPeriod; i++) {
      final date = start.add(Duration(days: i));
      final log = await _logRepo.getLogForDate(date);
      if (log != null && log.bleeding.index >= BleedingLevel.light.index) {
        end = date;
      } else if (i > 0) {
        break;
      }
    }
    if (end == start) {
      return start.add(Duration(days: avgPeriod - 1));
    }
    return end;
  }
}

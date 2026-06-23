import 'package:clune/models/daily_log.dart';
import 'package:clune/services/database_service.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:isar/isar.dart';

/// Repositorio de registros diarios de síntomas.
class DailyLogRepository {
  final DatabaseService _db;

  DailyLogRepository(this._db);

  /// Obtiene el log de un día específico.
  Future<DailyLog?> getLogForDate(DateTime date) async {
    final normalized = AppDateUtils.normalizeDate(date);
    return _db.isar.dailyLogs.filter().dateEqualTo(normalized).findFirst();
  }

  /// Obtiene logs en un rango de fechas.
  Future<List<DailyLog>> getLogsInRange(DateTime start, DateTime end) async {
    return _db.isar.dailyLogs
        .filter()
        .dateBetween(
          AppDateUtils.normalizeDate(start),
          AppDateUtils.normalizeDate(end),
        )
        .sortByDate()
        .findAll();
  }

  /// Obtiene todos los logs ordenados por fecha.
  Future<List<DailyLog>> getAllLogs() async {
    return _db.isar.dailyLogs.where().sortByDate().findAll();
  }

  /// Crea o actualiza un log diario (upsert por fecha única).
  Future<DailyLog> upsertLog(DailyLog log) async {
    log.date = AppDateUtils.normalizeDate(log.date);
    log.updatedAt = DateTime.now();
    await _db.isar.writeTxn(() async {
      await _db.isar.dailyLogs.put(log);
    });
    return log;
  }

  /// Elimina un log por id.
  Future<void> deleteLog(int id) async {
    await _db.isar.writeTxn(() async {
      await _db.isar.dailyLogs.delete(id);
    });
  }

  /// Obtiene logs del ciclo actual (desde inicio del último periodo).
  Future<List<DailyLog>> getLogsForCurrentCycle(DateTime cycleStart) async {
    return getLogsInRange(cycleStart, DateTime.now());
  }
}

import 'package:clune/models/cycle_record.dart';
import 'package:clune/services/database_service.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:isar/isar.dart';

/// Repositorio de registros de periodo menstrual.
class CycleRepository {
  final DatabaseService _db;

  CycleRepository(this._db);

  /// Obtiene todos los ciclos ordenados por fecha de inicio.
  Future<List<CycleRecord>> getAllCycles() async {
    return _db.isar.cycleRecords.where().sortByStartDate().findAll();
  }

  /// Obtiene el ciclo más reciente.
  Future<CycleRecord?> getLatestCycle() async {
    return _db.isar.cycleRecords.where().sortByStartDateDesc().findFirst();
  }

  /// Obtiene ciclos en un rango de fechas.
  Future<List<CycleRecord>> getCyclesInRange(DateTime start, DateTime end) async {
    return _db.isar.cycleRecords
        .filter()
        .startDateBetween(start, end)
        .sortByStartDate()
        .findAll();
  }

  /// Guarda o actualiza un registro de ciclo.
  Future<CycleRecord> saveCycle(CycleRecord cycle) async {
    cycle.updatedAt = DateTime.now();
    if (cycle.createdAt.millisecondsSinceEpoch == 0) {
      cycle.createdAt = DateTime.now();
    }
    await _db.isar.writeTxn(() async {
      await _db.isar.cycleRecords.put(cycle);
    });
    return cycle;
  }

  /// Elimina un registro de ciclo por id.
  Future<void> deleteCycle(int id) async {
    await _db.isar.writeTxn(() async {
      await _db.isar.cycleRecords.delete(id);
    });
  }

  /// Obtiene el ciclo activo (sin fecha de fin).
  Future<CycleRecord?> getActiveCycle() async {
    return _db.isar.cycleRecords.filter().endDateIsNull().findFirst();
  }

  /// Verifica si una fecha cae dentro de algún periodo registrado.
  Future<CycleRecord?> getCycleForDate(DateTime date) async {
    final normalized = AppDateUtils.normalizeDate(date);
    final cycles = await getAllCycles();
    for (final cycle in cycles) {
      final end = cycle.endDate ?? DateTime.now();
      if (AppDateUtils.isDateInRange(normalized, cycle.startDate, end)) {
        return cycle;
      }
    }
    return null;
  }
}

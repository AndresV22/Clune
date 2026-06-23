import 'package:isar/isar.dart';

part 'cycle_record.g.dart';

/// Registro de un periodo menstrual (inicio y fin).
@collection
class CycleRecord {
  Id id = Isar.autoIncrement;

  /// Fecha de inicio del periodo.
  @Index()
  late DateTime startDate;

  /// Fecha de fin del periodo (null si aún activo).
  DateTime? endDate;

  /// Fecha de creación del registro.
  late DateTime createdAt;

  /// Fecha de última modificación.
  late DateTime updatedAt;

  /// Timestamp de sincronización futura.
  DateTime? syncedAt;

  /// Duración del periodo en días (null si activo).
  int? get periodDurationDays {
    if (endDate == null) return null;
    return endDate!.difference(startDate).inDays + 1;
  }
}

import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:clune/models/user_profile.dart';
import 'package:clune/models/cycle_record.dart';
import 'package:clune/models/daily_log.dart';

/// Servicio singleton para inicialización y acceso a Isar.
class DatabaseService extends GetxService {
  late Isar isar;

  /// Inicializa la base de datos Isar en el directorio de documentos.
  Future<DatabaseService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [UserProfileSchema, CycleRecordSchema, DailyLogSchema],
      directory: dir.path,
      name: 'clune_db',
    );
    return this;
  }

  /// Cierra la conexión a la base de datos.
  Future<void> close() async {
    await isar.close();
  }
}

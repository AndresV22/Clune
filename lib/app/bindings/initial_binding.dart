import 'package:get/get.dart';
import 'package:clune/controllers/theme_controller.dart';
import 'package:clune/services/database_service.dart';
import 'package:clune/services/cycle_phase_service.dart';
import 'package:clune/services/prediction_service.dart';
import 'package:clune/services/statistics_service.dart';
import 'package:clune/services/notification_service.dart';
import 'package:clune/services/sync_service.dart';
import 'package:clune/services/cycle_sync_service.dart';
import 'package:clune/services/data_backup_service.dart';
import 'package:clune/services/hormone_info_service.dart';
import 'package:clune/repositories/user_repository.dart';
import 'package:clune/repositories/cycle_repository.dart';
import 'package:clune/repositories/daily_log_repository.dart';
import 'package:clune/repositories/article_repository.dart';

/// Binding inicial: registra servicios y repositorios como singletons.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);

    // Servicios core
    Get.lazyPut<CyclePhaseService>(() => CyclePhaseService(), fenix: true);
    Get.lazyPut<HormoneInfoService>(() => HormoneInfoService(), fenix: true);
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    Get.lazyPut<SyncService>(() => LocalSyncService(), fenix: true);
    Get.lazyPut<ArticleRepository>(() => ArticleRepository(), fenix: true);

    // Repositorios (requieren DatabaseService ya inicializado)
    Get.lazyPut<UserRepository>(
      () => UserRepository(Get.find<DatabaseService>()),
      fenix: true,
    );
    Get.lazyPut<CycleRepository>(
      () => CycleRepository(Get.find<DatabaseService>()),
      fenix: true,
    );
    Get.lazyPut<DailyLogRepository>(
      () => DailyLogRepository(Get.find<DatabaseService>()),
      fenix: true,
    );

    // Servicios que dependen de repositorios
    Get.lazyPut<PredictionService>(
      () => PredictionService(
        Get.find<CycleRepository>(),
        Get.find<DailyLogRepository>(),
        Get.find<UserRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<StatisticsService>(
      () => StatisticsService(
        Get.find<CycleRepository>(),
        Get.find<DailyLogRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CycleSyncService>(
      () => CycleSyncService(
        Get.find<CycleRepository>(),
        Get.find<DailyLogRepository>(),
        Get.find<PredictionService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<DataBackupService>(
      () => DataBackupService(
        Get.find<DatabaseService>(),
        Get.find<UserRepository>(),
        Get.find<CycleRepository>(),
        Get.find<DailyLogRepository>(),
        Get.find<ThemeController>(),
      ),
      fenix: true,
    );
  }
}

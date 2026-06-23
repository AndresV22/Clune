import 'package:get/get.dart';
import 'package:clune/controllers/main_nav_controller.dart';
import 'package:clune/controllers/home_controller.dart';
import 'package:clune/controllers/calendar_controller.dart';
import 'package:clune/controllers/daily_log_controller.dart';
import 'package:clune/controllers/analysis_controller.dart';
import 'package:clune/controllers/articles_controller.dart';

/// Binding para la pantalla principal con navegación inferior.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavController>(() => MainNavController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CalendarController>(() => CalendarController());
    Get.lazyPut<DailyLogController>(() => DailyLogController());
    Get.lazyPut<AnalysisController>(() => AnalysisController());
    Get.lazyPut<ArticlesController>(() => ArticlesController());
  }
}

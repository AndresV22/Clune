import 'package:get/get.dart';
import 'package:clune/controllers/home_controller.dart';
import 'package:clune/controllers/calendar_controller.dart';
import 'package:clune/controllers/analysis_controller.dart';
import 'package:clune/controllers/daily_log_controller.dart';

/// Refresca datos de todas las pestañas tras onboarding o cambios globales.
Future<void> refreshMainAppData() async {
  if (Get.isRegistered<HomeController>()) {
    await Get.find<HomeController>().reloadData();
  }
  if (Get.isRegistered<CalendarController>()) {
    await Get.find<CalendarController>().loadMonthData();
  }
  if (Get.isRegistered<DailyLogController>()) {
    await Get.find<DailyLogController>().loadPeriodHistory();
  }
  if (Get.isRegistered<AnalysisController>()) {
    await Get.find<AnalysisController>().loadAnalysis();
  }
}

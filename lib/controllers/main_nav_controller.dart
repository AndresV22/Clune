import 'package:get/get.dart';
import 'package:clune/controllers/home_controller.dart';
import 'package:clune/controllers/calendar_controller.dart';
import 'package:clune/controllers/analysis_controller.dart';
import 'package:clune/utils/main_data_refresh.dart';

/// Controlador de navegación inferior entre tabs.
class MainNavController extends GetxController {
  /// Índice del tab activo (0-4).
  final currentIndex = 0.obs;

  /// Tab desde el que se abrió Seguimiento (para volver al guardar).
  int _tabBeforeLog = 0;

  @override
  void onReady() {
    super.onReady();
    // Asegura datos frescos al entrar al shell principal (p. ej. tras onboarding).
    Future.microtask(refreshMainAppData);
  }

  /// Cambia al tab indicado y refresca datos si hace falta.
  void changeTab(int index) {
    if (index == 2 && currentIndex.value != 2) {
      _tabBeforeLog = currentIndex.value;
    }
    if (index == currentIndex.value) return;
    currentIndex.value = index;
    _refreshTabData(index);
  }

  /// Vuelve al tab desde el que se abrió el registro diario.
  void navigateAfterLogSave() {
    changeTab(_tabBeforeLog);
  }

  /// Recarga datos al entrar a una pestaña (IndexedStack mantiene vistas vivas).
  void _refreshTabData(int index) {
    switch (index) {
      case 0:
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().reloadData();
        }
        break;
      case 1:
        if (Get.isRegistered<CalendarController>()) {
          Get.find<CalendarController>().loadMonthData();
        }
        break;
      case 3:
        if (Get.isRegistered<AnalysisController>()) {
          Get.find<AnalysisController>().loadAnalysis();
        }
        break;
    }
  }
}

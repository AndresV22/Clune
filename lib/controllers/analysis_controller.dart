import 'package:get/get.dart';
import 'package:clune/services/prediction_service.dart';
import 'package:clune/services/statistics_service.dart';
import 'package:clune/utils/enums.dart';

/// Controlador de la pantalla de análisis y estadísticas.
class AnalysisController extends GetxController {
  final PredictionService _predictionService = Get.find();
  final StatisticsService _statisticsService = Get.find();

  /// Estadísticas principales.
  final avgCycleLength = 0.0.obs;
  final avgPeriodLength = 0.0.obs;
  final regularity = CycleRegularity.regular.obs;

  /// Datos para gráficos.
  final cycleHistory = <ChartDataPoint>[].obs;
  final periodHistory = <ChartDataPoint>[].obs;
  final painHistory = <ChartDataPoint>[].obs;
  final symptomFrequencies = <SymptomFrequency>[].obs;
  final moodDistribution = <MoodType, int>{}.obs;

  /// Predicciones.
  final nextPeriodText = ''.obs;
  final nextFertileWindowText = ''.obs;
  final painPredictionText = RxnString();
  final moodPredictionText = RxnString();
  final trackingLogCount = 0.obs;
  final hasEnoughLogsForPersonalPredictions = false.obs;
  final symptomPredictions = <SymptomPrediction>[].obs;

  /// Indica si los datos están cargando.
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalysis();
  }

  /// Carga todos los datos de análisis.
  Future<void> loadAnalysis() async {
    isLoading.value = true;

    avgCycleLength.value = await _predictionService.calculateAverageCycle();
    avgPeriodLength.value = await _predictionService.calculateAveragePeriod();
    regularity.value = await _statisticsService.calculateRegularity();

    cycleHistory.value = await _statisticsService.getCycleDurationHistory();
    periodHistory.value = await _statisticsService.getPeriodDurationHistory();
    painHistory.value = await _statisticsService.getPainIntensityByCycle();
    symptomFrequencies.value = await _statisticsService.calculateSymptomFrequency();
    moodDistribution.value = await _statisticsService.getMoodDistribution();

    final display = await _predictionService.buildCyclePredictionDisplay();
    nextPeriodText.value = display.nextPeriodText;
    nextFertileWindowText.value = display.nextFertileWindowText;
    trackingLogCount.value = display.trackingLogCount;
    hasEnoughLogsForPersonalPredictions.value =
        display.hasEnoughLogsForPersonalPredictions;
    painPredictionText.value = display.painPredictionText;
    moodPredictionText.value = display.moodPredictionText;

    symptomPredictions.value = await _predictionService.predictUpcomingSymptoms();

    isLoading.value = false;
  }

  /// Texto legible de regularidad.
  String get regularityText {
    switch (regularity.value) {
      case CycleRegularity.veryRegular:
        return 'Muy regular';
      case CycleRegularity.regular:
        return 'Regular';
      case CycleRegularity.irregular:
        return 'Irregular';
    }
  }
}

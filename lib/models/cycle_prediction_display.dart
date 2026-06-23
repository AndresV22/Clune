/// Textos de predicciones listos para mostrar en Home y Análisis.
class CyclePredictionDisplay {
  final String nextPeriodText;
  final String nextFertileWindowText;
  final int trackingLogCount;
  final bool hasEnoughLogsForPersonalPredictions;
  final String? painPredictionText;
  final String? moodPredictionText;

  const CyclePredictionDisplay({
    required this.nextPeriodText,
    required this.nextFertileWindowText,
    required this.trackingLogCount,
    required this.hasEnoughLogsForPersonalPredictions,
    this.painPredictionText,
    this.moodPredictionText,
  });
}

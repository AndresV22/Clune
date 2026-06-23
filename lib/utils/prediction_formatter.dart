import 'package:get/get.dart';
import 'package:clune/services/prediction_service.dart';
import 'package:clune/utils/enums.dart';

/// Formatea textos de predicciones para la UI.
class PredictionFormatter {
  PredictionFormatter._();

  static String daysUntil(int days, {bool inProgress = false}) {
    if (inProgress) return 'prediction_fertile_in_progress'.tr;
    if (days <= 0) return 'prediction_today'.tr;
    if (days == 1) return 'prediction_in_one_day'.tr;
    return 'prediction_in_days'.trParams({'days': '$days'});
  }

  static String painValue(PainDayPrediction prediction) {
    return 'prediction_pain_value'.trParams({
      'timing': daysUntil(prediction.daysUntil),
      'symptom': prediction.label,
      'prob': '${prediction.probability.round()}',
    });
  }

  static String moodValue(MoodPrediction prediction) {
    return 'prediction_mood_value'.trParams({
      'timing': daysUntil(prediction.daysUntil),
      'mood': prediction.mood.labelKey.tr,
      'prob': '${prediction.probability.round()}',
    });
  }
}

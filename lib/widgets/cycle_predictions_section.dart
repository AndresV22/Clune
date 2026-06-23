import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/widgets/prediction_card.dart';

/// Sección de predicciones de ciclo compartida entre Home y Análisis.
class CyclePredictionsSection extends StatelessWidget {
  final String nextPeriodText;
  final String nextFertileWindowText;
  final String? painPredictionText;
  final String? moodPredictionText;
  final bool hasEnoughLogsForPersonalPredictions;
  final int trackingLogCount;

  const CyclePredictionsSection({
    super.key,
    required this.nextPeriodText,
    required this.nextFertileWindowText,
    required this.hasEnoughLogsForPersonalPredictions,
    required this.trackingLogCount,
    this.painPredictionText,
    this.moodPredictionText,
  });

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PredictionCard(
          title: 'analysis_next_period'.tr,
          value: nextPeriodText,
          icon: Icons.water_drop_outlined,
          iconColor: AppColors.primaryRed,
        ),
        const SizedBox(height: 8),
        PredictionCard(
          title: 'analysis_next_fertile_window'.tr,
          value: nextFertileWindowText,
          icon: Icons.eco_outlined,
          iconColor: AppColors.primaryTeal,
        ),
        if (painPredictionText != null) ...[
          const SizedBox(height: 8),
          PredictionCard(
            title: 'prediction_next_pain'.tr,
            value: painPredictionText!,
            icon: Icons.healing_outlined,
            iconColor: AppColors.orange,
          ),
        ],
        if (moodPredictionText != null) ...[
          const SizedBox(height: 8),
          PredictionCard(
            title: 'prediction_next_mood'.tr,
            value: moodPredictionText!,
            icon: Icons.sentiment_satisfied_alt_outlined,
            iconColor: AppColors.purple,
          ),
        ],
        if (!hasEnoughLogsForPersonalPredictions) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: clune.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: clune.divider),
            ),
            child: Text(
              'prediction_insufficient_logs'.trParams({'count': '$trackingLogCount'}),
              style: clune.bodySmall,
            ),
          ),
        ],
      ],
    );
  }
}

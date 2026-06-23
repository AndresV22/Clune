import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/services/prediction_service.dart';
import 'package:clune/utils/date_utils.dart';

/// Sección de predicciones de dolor basadas en ciclos anteriores.
class PainPredictionSection extends StatelessWidget {
  final List<DailySymptomForecast> forecasts;
  final List<SymptomPrediction> topSymptoms;

  const PainPredictionSection({
    super.key,
    required this.forecasts,
    required this.topSymptoms,
  });

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    if (forecasts.isEmpty && topSymptoms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: clune.inputFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'pain_prediction_empty'.tr,
          style: clune.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topSymptoms.isNotEmpty) ...topSymptoms.take(4).map((s) => _buildSymptomRow(context, s)),
        if (forecasts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'pain_prediction_upcoming'.tr,
            style: clune.bodySmall,
          ),
          const SizedBox(height: 8),
          ...forecasts.take(5).map((d) => _buildDayRow(context, d)),
        ],
      ],
    );
  }

  Widget _buildSymptomRow(BuildContext context, SymptomPrediction s) {
    final clune = context.clune;
    final dateLabel = s.date != null ? AppDateUtils.formatShortDate(s.date!) : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _iconFor(s.name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.label, style: clune.bodyLarge),
                if (dateLabel.isNotEmpty)
                  Text(dateLabel, style: clune.bodySmall),
              ],
            ),
          ),
          Text(
            '${s.probability.round()}%',
            style: AppTextStyles.label.copyWith(color: AppColors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, DailySymptomForecast day) {
    final clune = context.clune;
    final labels = day.symptoms.take(2).map((s) => s.label).join(', ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              AppDateUtils.formatShortDate(day.date),
              style: clune.bodySmallPrimary.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              labels,
              style: clune.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconFor(String name) {
    final icon = switch (name) {
      'cramps' => Icons.spa_outlined,
      'bleeding' || 'heavy_bleeding' => Icons.water_drop_outlined,
      'headache' => Icons.psychology_outlined,
      _ => Icons.healing_outlined,
    };
    return Icon(icon, size: 18, color: AppColors.orange);
  }
}

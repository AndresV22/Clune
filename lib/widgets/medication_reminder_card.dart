import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/services/prediction_service.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/widgets/pain_medication_sheet.dart';

/// Tarjeta con recomendación de cuándo empezar la medicación preferida.
class MedicationReminderCard extends StatelessWidget {
  final MedicationReminder? reminder;
  final VoidCallback? onUpdated;

  const MedicationReminderCard({
    super.key,
    required this.reminder,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (reminder == null) {
      return _buildSetupCard(context);
    }

    final r = reminder!;
    final message = _buildMessage(r);
    final clune = context.clune;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: clune.warmAccentBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: clune.warmAccentBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication_outlined, color: AppColors.orange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'medication_reminder_title'.tr,
                  style: clune.label,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 18, color: clune.textSecondary),
                onPressed: () async {
                  await PainMedicationSheet.show();
                  onUpdated?.call();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: clune.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'medication_pain_predicted'.trParams({
              'date': AppDateUtils.formatShortDate(r.predictedPainDate),
              'prob': '${r.painProbability.round()}',
            }),
            style: clune.bodySmall,
          ),
        ],
      ),
    );
  }

  String _buildMessage(MedicationReminder r) {
    if (r.shouldStartNow) {
      return 'medication_start_now'.trParams({'med': r.medication});
    }
    if (r.daysUntilStart == 1) {
      return 'medication_start_tomorrow'.trParams({'med': r.medication});
    }
    return 'medication_start_on'.trParams({
      'med': r.medication,
      'date': AppDateUtils.formatShortDate(r.recommendedStartDate),
    });
  }

  Widget _buildSetupCard(BuildContext context) {
    final clune = context.clune;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: clune.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'medication_setup_title'.tr,
            style: clune.label,
          ),
          const SizedBox(height: 4),
          Text(
            'medication_setup_subtitle'.tr,
            style: clune.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await PainMedicationSheet.show();
              onUpdated?.call();
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text('medication_setup_action'.tr),
          ),
        ],
      ),
    );
  }
}

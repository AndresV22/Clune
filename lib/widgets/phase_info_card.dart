import 'package:flutter/material.dart';
import 'package:clune/services/cycle_phase_service.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';

/// Tarjeta informativa de la fase actual del ciclo.
class PhaseInfoCard extends StatelessWidget {
  final PhaseInfo phaseInfo;
  final VoidCallback? onTap;

  const PhaseInfoCard({
    super.key,
    required this.phaseInfo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightTeal.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(phaseInfo.name, style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(phaseInfo.shortDescription, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

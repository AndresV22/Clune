import 'package:flutter/material.dart';
import 'package:clune/services/cycle_phase_service.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';

/// Bottom sheet con información educativa de una fase del ciclo.
class PhaseInfoSheet extends StatelessWidget {
  final PhaseInfo phaseInfo;

  const PhaseInfoSheet({super.key, required this.phaseInfo});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: clune.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: clune.cardBorder,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: clune.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                phaseInfo.name,
                style: AppTextStyles.headingMedium.copyWith(color: clune.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                phaseInfo.shortDescription,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                phaseInfo.educationalText,
                style: AppTextStyles.bodyLarge.copyWith(
                  height: 1.55,
                  color: clune.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

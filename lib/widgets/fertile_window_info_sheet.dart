import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/services/cycle_phase_service.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';

/// Bottom sheet con información educativa sobre la ventana fértil.
class FertileWindowInfoSheet extends StatelessWidget {
  final FertileWindowInfo info;

  const FertileWindowInfoSheet({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
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
        child: SingleChildScrollView(
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
                info.titleKey.tr,
                style: AppTextStyles.headingMedium.copyWith(color: clune.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                info.shortDescriptionKey.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                info.educationalTextKey.tr,
                style: AppTextStyles.bodyLarge.copyWith(
                  height: 1.55,
                  color: clune.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text('fertile_window_indicators_title'.tr, style: clune.label),
              const SizedBox(height: 12),
              ...info.indicatorKeys.map(
                (key) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          key.tr,
                          style: clune.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'fertile_window_disclaimer'.tr,
                style: clune.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

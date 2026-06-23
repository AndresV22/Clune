import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/services/hormone_info_service.dart';

/// Tarjeta con resumen hormonal de la sub-fase actual.
class HormoneInfoCard extends StatelessWidget {
  final HormonePhaseInfo info;

  const HormoneInfoCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    final service = HormoneInfoService();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: clune.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: clune.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(info.titleKey.tr, style: clune.label),
          const SizedBox(height: 8),
          Text(info.descriptionKey.tr, style: clune.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HormoneChip(
                label: 'hormone_estrogen'.tr,
                level: service.levelLabelKey(info.estrogen).tr,
                color: AppColors.primaryPink,
              ),
              _HormoneChip(
                label: 'hormone_progesterone'.tr,
                level: service.levelLabelKey(info.progesterone).tr,
                color: AppColors.purple,
              ),
              _HormoneChip(
                label: 'hormone_fsh'.tr,
                level: service.levelLabelKey(info.fsh).tr,
                color: AppColors.primaryTeal,
              ),
            ],
          ),
          if (info.experienceKeys.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              info.experienceKeys.map((k) => k.tr).join(' · '),
              style: clune.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _HormoneChip extends StatelessWidget {
  final String label;
  final String level;
  final Color color;

  const _HormoneChip({
    required this.label,
    required this.level,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $level',
        style: clune.bodySmall.copyWith(color: clune.textPrimary),
      ),
    );
  }
}

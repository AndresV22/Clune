import 'package:flutter/material.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';

/// Tarjeta compacta de predicción para Home y Análisis.
class PredictionCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const PredictionCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: clune.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: clune.divider),
        boxShadow: [
          BoxShadow(
            color: clune.cardBorder,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primaryTeal).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primaryTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: clune.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: clune.label,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';

/// Banner "¿Cómo te sientes hoy?" estilo Clue.
class DailyLogPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const DailyLogPrompt({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: clune.warmAccentBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: clune.warmAccentBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sentiment_satisfied_alt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'home_how_feel'.tr,
                style: clune.bodyLarge.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.orange),
          ],
        ),
      ),
    );
  }
}

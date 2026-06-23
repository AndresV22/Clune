import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/widgets/cycle_ring/cycle_ring_painter.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';

/// Widget interactivo del anillo de ciclo con texto central.
class CycleRingWidget extends StatelessWidget {
  final CycleRingData data;
  final String centerMessage;
  final String todaySubtitle;
  final VoidCallback? onPhaseTap;
  final String phaseLinkText;
  final ValueChanged<int>? onDaySelected;
  final bool isViewingToday;
  final VoidCallback? onResetToToday;

  const CycleRingWidget({
    super.key,
    required this.data,
    required this.centerMessage,
    required this.todaySubtitle,
    this.onPhaseTap,
    this.phaseLinkText = '',
    this.onDaySelected,
    this.isViewingToday = true,
    this.onResetToToday,
  });

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final ringSize = size.width * 0.82;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) => _handleInteraction(
                  details.localPosition,
                  Size(ringSize, ringSize),
                ),
                onTapDown: (details) => _handleInteraction(
                  details.localPosition,
                  Size(ringSize, ringSize),
                ),
                child: CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: CycleRingPainter(
                    data: data,
                    isDark: isDark,
                    ringTrackColor: clune.cycleRingTrack,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IgnorePointer(
                      child: Text(
                        todaySubtitle,
                        style: clune.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IgnorePointer(
                      child: Text(
                        centerMessage,
                        style: clune.centerMessage,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (onPhaseTap != null && phaseLinkText.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: onPhaseTap,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              phaseLinkText,
                              style: AppTextStyles.phaseLink,
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.primaryTeal,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isViewingToday && onResetToToday != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onResetToToday,
            icon: const Icon(Icons.today_outlined, size: 18),
            label: Text('home_back_to_today'.tr),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryTeal,
            ),
          ),
        ] else ...[
          const SizedBox(height: 4),
          Text(
            'home_explore_ring'.tr,
            style: clune.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ],
    );
  }

  void _handleInteraction(Offset position, Size size) {
    if (onDaySelected == null) return;
    final day = CycleRingPainter.positionToCycleDay(
      position: position,
      size: size,
      cycleLength: data.cycleLength,
    );
    if (day != null) onDaySelected!(day);
  }
}

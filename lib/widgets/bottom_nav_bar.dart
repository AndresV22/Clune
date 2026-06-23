import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/controllers/main_nav_controller.dart';

/// Estilo compartido para etiquetas del bottom nav.
TextStyle _navLabelStyle({required Color color, required bool isActive}) {
  return AppTextStyles.bodySmall.copyWith(
    color: color,
    fontSize: 10,
    height: 1.2,
    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
  );
}

/// Barra de navegación inferior estilo Clue con 5 tabs.
class CluneBottomNavBar extends StatelessWidget {
  const CluneBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainNavController>();

    return Obx(() {
      final index = controller.currentIndex.value;
      final clune = context.clune;
      return Container(
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          color: clune.navBarBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _NavItem(
                  icon: Icons.radio_button_checked_outlined,
                  label: 'nav_cycle'.tr,
                  isActive: index == 0,
                  onTap: () => controller.changeTab(0),
                ),
                _NavItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'nav_calendar'.tr,
                  isActive: index == 1,
                  onTap: () => controller.changeTab(1),
                ),
                _CenterFab(
                  label: 'nav_log'.tr,
                  isActive: index == 2,
                  onTap: () => controller.changeTab(2),
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'nav_analysis'.tr,
                  isActive: index == 3,
                  onTap: () => controller.changeTab(3),
                ),
                _NavItem(
                  icon: Icons.menu_book_outlined,
                  label: 'nav_articles'.tr,
                  isActive: index == 4,
                  onTap: () => controller.changeTab(4),
                  showBadge: true,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showBadge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    final color = isActive ? AppColors.primaryTeal : clune.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (isActive)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Icon(icon, color: color, size: 22),
                  if (showBadge)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: _navLabelStyle(color: color, isActive: isActive),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón central de añadir seguimiento, alineado con el resto del bottom nav.
class _CenterFab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const double _fabSize = 48;

  const _CenterFab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    final labelColor = isActive ? AppColors.primaryTeal : clune.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mismo slot de icono (36 px) que los demás tabs; el FAB sobresale hacia arriba.
            SizedBox(
              width: 36,
              height: 36,
              child: OverflowBox(
                alignment: Alignment.center,
                maxWidth: _fabSize,
                maxHeight: _fabSize,
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    width: _fabSize,
                    height: _fabSize,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: _navLabelStyle(color: labelColor, isActive: isActive),
            ),
          ],
        ),
      ),
    );
  }
}

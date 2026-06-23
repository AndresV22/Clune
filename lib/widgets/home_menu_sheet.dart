import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/app/theme/app_theme.dart';
import 'package:clune/app/routes/app_routes.dart';
import 'package:clune/controllers/theme_controller.dart';
import 'package:clune/widgets/clune_logo.dart';

/// Menú lateral desplegable desde el botón hamburguesa del Home.
class HomeMenuSheet extends StatelessWidget {
  final String userName;

  const HomeMenuSheet({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(() {
      final theme = themeController.isDarkMode.value ? AppTheme.dark : AppTheme.light;
      return Theme(
        data: theme,
        child: Builder(builder: _buildSheet),
      );
    });
  }

  Widget _buildSheet(BuildContext context) {
    final clune = context.clune;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: maxHeight),
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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
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
              Center(child: CluneLogo(size: 72)),
              const SizedBox(height: 16),
              Text(
                'menu_greeting'.trParams({'name': userName}),
                style: clune.headingMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'menu_subtitle'.tr,
                style: clune.bodyLarge,
              ),
              const SizedBox(height: 16),
              _DarkModeTile(),
              const SizedBox(height: 8),
              _MenuTile(
                icon: Icons.person_outline,
                label: 'menu_profile'.tr,
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoutes.profile);
                },
              ),
              _MenuTile(
                icon: Icons.tune_outlined,
                label: 'menu_customize_log'.tr,
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoutes.logSectionsSettings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkModeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(
      () {
        final clune = context.clune;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: clune.chipBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            themeController.isDarkMode.value
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            color: AppColors.primaryTeal,
            size: 22,
          ),
        ),
        title: Text(
          'menu_dark_mode'.tr,
          style: clune.bodyLarge,
        ),
        trailing: Switch(
          value: themeController.isDarkMode.value,
          onChanged: themeController.toggleTheme,
        ),
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: clune.chipBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryTeal, size: 22),
      ),
      title: Text(
        label,
        style: clune.bodyLarge,
      ),
      trailing: Icon(Icons.chevron_right, color: clune.textSecondary),
      onTap: onTap,
    );
  }
}

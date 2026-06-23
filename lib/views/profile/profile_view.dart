import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/routes/app_routes.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/controllers/profile_controller.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/widgets/pain_medication_sheet.dart';

/// Pantalla de perfil con anticonceptivos y respaldo de datos.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Scaffold(
      appBar: AppBar(
        title: Text('profile_title'.tr),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isSaving.value ? null : controller.saveProfile,
                child: Text('save'.tr),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryTeal),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('profile_name'.tr, style: clune.label),
            const SizedBox(height: 8),
            TextField(
              controller: controller.nameController,
              style: clune.bodyLarge,
              decoration: InputDecoration(
                hintText: 'profile_name'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Text('profile_contraceptive'.tr, style: clune.label),
            const SizedBox(height: 8),
            ...ContraceptiveType.values.map((type) {
              return Obx(() => RadioListTile<ContraceptiveType>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(type.labelKey.tr, style: clune.bodyLarge),
                    value: type,
                    groupValue: controller.contraceptiveType.value,
                    activeColor: AppColors.primaryTeal,
                    onChanged: (v) {
                      if (v != null) controller.setContraceptive(v);
                    },
                  ));
            }),
            Obx(() {
              if (controller.contraceptiveType.value != ContraceptiveType.other) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('profile_contraceptive_notes'.tr, style: clune.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.contraceptiveNotesController,
                    style: clune.bodyLarge,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.medication_outlined,
              label: 'medication_title'.tr,
              onTap: () => PainMedicationSheet.show(),
            ),
            _ActionTile(
              icon: Icons.tune_outlined,
              label: 'menu_customize_log'.tr,
              onTap: () => Get.toNamed(AppRoutes.logSectionsSettings),
            ),
            const SizedBox(height: 24),
            Text('profile_data'.tr, style: clune.label),
            const SizedBox(height: 8),
            Obx(() => _ActionTile(
                  icon: Icons.upload_outlined,
                  label: 'profile_export'.tr,
                  loading: controller.isExporting.value,
                  onTap: controller.exportData,
                )),
            Obx(() => _ActionTile(
                  icon: Icons.download_outlined,
                  label: 'profile_import'.tr,
                  loading: controller.isImporting.value,
                  onTap: controller.importData,
                )),
          ],
        );
      }),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.loading = false,
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
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: AppColors.primaryTeal, size: 22),
      ),
      title: Text(label, style: clune.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: clune.textSecondary),
      onTap: loading ? null : onTap,
    );
  }
}

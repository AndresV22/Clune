import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/controllers/log_sections_settings_controller.dart';
import 'package:clune/utils/log_section_ids.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';

/// Pantalla para activar/desactivar secciones del registro diario.
class LogSectionsSettingsView extends GetView<LogSectionsSettingsController> {
  const LogSectionsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Scaffold(
      appBar: AppBar(
        title: Text('log_sections_title'.tr),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isSaving.value ? null : controller.save,
                child: Text('save'.tr),
              )),
        ],
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('log_sections_subtitle'.tr, style: clune.bodyMedium),
              const SizedBox(height: 16),
              ...LogSectionIds.all.map((id) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(LogSectionIds.labelKey(id).tr, style: clune.bodyLarge),
                  value: controller.isEnabled(id),
                  activeTrackColor: clune.chipBackground,
                  onChanged: (_) => controller.toggle(id),
                );
              }),
            ],
          )),
    );
  }
}

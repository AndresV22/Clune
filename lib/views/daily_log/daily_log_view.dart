import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:clune/controllers/daily_log_controller.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/utils/log_section_ids.dart';
import 'package:clune/widgets/symptom_chip.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/utils/pain_medications.dart';
import 'package:clune/widgets/pain_medication_sheet.dart';
import 'package:clune/widgets/period_history_sheet.dart';

/// Pantalla de registro diario de síntomas y periodo.
class DailyLogView extends GetView<DailyLogController> {
  const DailyLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Obx(() {
                  controller.enabledSections.length;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateSelector(context),
                        const SizedBox(height: 8),
                        ..._buildEnabledSections(context),
                        if (controller.isSectionEnabled(LogSectionIds.periodHistory))
                          _buildPeriodSection(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: _buildFloatingSaveButton(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEnabledSections(BuildContext context) {
    final widgets = <Widget>[];
    void add(String id, Widget Function() builder) {
      if (controller.isSectionEnabled(id)) {
        widgets.add(builder());
      }
    }

    add(LogSectionIds.bleeding, _buildBleedingSection);
    add(LogSectionIds.bleedingColor, () => _buildBleedingColorSection(context));
    add(LogSectionIds.pain, _buildPainSection);
    add(LogSectionIds.cramps, _buildCrampsSection);
    add(LogSectionIds.discharge, _buildDischargeSection);
    add(LogSectionIds.sexualActivity, () => _buildSexualActivitySection(context));
    add(LogSectionIds.sexDrive, _buildSexDriveSection);
    add(LogSectionIds.mood, _buildMoodSection);
    add(LogSectionIds.energy, _buildEnergySection);
    add(LogSectionIds.pms, () => _buildPmsSection(context));
    add(LogSectionIds.symptoms, _buildSymptomsSection);
    add(LogSectionIds.cravings, _buildCravingsSection);
    add(LogSectionIds.digestion, _buildDigestionSection);
    add(LogSectionIds.stool, _buildStoolSection);
    add(LogSectionIds.sleepQuality, _buildSleepQualitySection);
    add(LogSectionIds.dailyNote, () => _buildDailyNoteSection(context));
    add(LogSectionIds.painMedication, () => _buildPainMedicationSection(context));
    add(LogSectionIds.exercise, () => _buildExerciseSection(context));
    return widgets;
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text('log_title'.tr, style: context.clune.headingMedium),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Obx(() {
      final date = controller.selectedDate.value;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          AppDateUtils.formatTodayOrDate(date),
          style: context.clune.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.calendar_today, color: AppColors.primaryTeal),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (picked != null) controller.changeDate(picked);
        },
      );
    });
  }

  Widget _buildBleedingSection() {
    return Obx(() => LogSection(
          title: 'log_bleeding'.tr,
          children: BleedingLevel.values.map((level) {
            return SymptomChip(
              label: level.labelKey.tr,
              isSelected: controller.bleeding.value == level,
              selectedColor: AppColors.primaryRed,
              onTap: () => controller.setBleeding(level),
            );
          }).toList(),
        ));
  }

  Widget _buildBleedingColorSection(BuildContext context) {
    return Obx(() {
      if (controller.bleeding.value == BleedingLevel.none) {
        return const SizedBox.shrink();
      }
      return LogSection(
        title: 'log_section_bleedingColor'.tr,
        children: BleedingColor.values
            .where((c) => c != BleedingColor.none)
            .map((color) {
          return SymptomChip(
            label: color.labelKey.tr,
            isSelected: controller.bleedingColor.value == color,
            selectedColor: AppColors.primaryRed,
            onTap: () => controller.bleedingColor.value = color,
          );
        }).toList(),
      );
    });
  }

  Widget _buildPainSection() {
    return Obx(() => LogSection(
          title: 'log_pain'.tr,
          children: PainLevel.values.map((level) {
            return SymptomChip(
              label: level.labelKey.tr,
              isSelected: controller.pain.value == level,
              selectedColor: AppColors.orange,
              onTap: () => controller.pain.value = level,
            );
          }).toList(),
        ));
  }

  Widget _buildCrampsSection() {
    return Obx(() => LogSection(
          title: 'log_cramps'.tr,
          children: [
            SymptomChip(
              label: 'log_yes'.tr,
              isSelected: controller.cramps.value,
              selectedColor: AppColors.orange,
              onTap: () => controller.cramps.value = true,
            ),
            SymptomChip(
              label: 'log_no'.tr,
              isSelected: !controller.cramps.value,
              onTap: () => controller.cramps.value = false,
            ),
          ],
        ));
  }

  Widget _buildDischargeSection() {
    return Obx(() => LogSection(
          title: 'log_discharge'.tr,
          children: DischargeType.values.map((type) {
            return SymptomChip(
              label: type.labelKey.tr,
              isSelected: controller.discharge.value == type,
              selectedColor: AppColors.blue,
              onTap: () => controller.discharge.value = type,
            );
          }).toList(),
        ));
  }

  Widget _buildSexualActivitySection(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LogSection(
              title: 'log_sexual_activity'.tr,
              children: [
                SymptomChip(
                  label: 'log_yes'.tr,
                  isSelected: controller.sexualActivity.value,
                  selectedColor: AppColors.purple,
                  onTap: () => controller.setSexualActivity(true),
                ),
                SymptomChip(
                  label: 'log_no'.tr,
                  isSelected: !controller.sexualActivity.value,
                  onTap: () => controller.setSexualActivity(false),
                ),
              ],
            ),
            if (controller.sexualActivity.value) ...[
              LogSection(
                title: 'log_orgasm'.tr,
                children: [
                  SymptomChip(
                    label: 'log_yes'.tr,
                    isSelected: controller.hadOrgasm.value,
                    selectedColor: AppColors.purple,
                    onTap: () => controller.hadOrgasm.value = true,
                  ),
                  SymptomChip(
                    label: 'log_no'.tr,
                    isSelected: !controller.hadOrgasm.value,
                    onTap: () => controller.hadOrgasm.value = false,
                  ),
                ],
              ),
              LogSection(
                title: 'log_sexual_fantasies'.tr,
                children: [
                  SymptomChip(
                    label: 'log_yes'.tr,
                    isSelected: controller.hadSexualFantasies.value,
                    selectedColor: AppColors.purple,
                    onTap: () => controller.hadSexualFantasies.value = true,
                  ),
                  SymptomChip(
                    label: 'log_no'.tr,
                    isSelected: !controller.hadSexualFantasies.value,
                    onTap: () => controller.hadSexualFantasies.value = false,
                  ),
                ],
              ),
            ],
          ],
        ));
  }

  Widget _buildSexDriveSection() {
    return Obx(() => LogSection(
          title: 'log_sex_drive'.tr,
          children: SexDriveLevel.values.map((level) {
            return SymptomChip(
              label: level.labelKey.tr,
              isSelected: controller.sexDrive.value == level,
              selectedColor: AppColors.purple,
              onTap: () => controller.sexDrive.value = level,
            );
          }).toList(),
        ));
  }

  Widget _buildMoodSection() {
    return Obx(() => LogSection(
          title: 'log_mood'.tr,
          children: MoodType.values.map((mood) {
            return SymptomChip(
              label: mood.labelKey.tr,
              isSelected: controller.mood.value == mood,
              selectedColor: AppColors.yellow,
              onTap: () => controller.mood.value = mood,
            );
          }).toList(),
        ));
  }

  Widget _buildEnergySection() {
    return Obx(() => LogSection(
          title: 'log_energy'.tr,
          children: EnergyLevel.values.map((level) {
            return SymptomChip(
              label: level.labelKey.tr,
              isSelected: controller.energy.value == level,
              selectedColor: AppColors.primaryTeal,
              onTap: () => controller.energy.value = level,
            );
          }).toList(),
        ));
  }

  Widget _buildPmsSection(BuildContext context) {
    return Obx(() => LogSection(
          title: 'log_pms'.tr,
          children: [
            SymptomChip(
              label: 'log_pms_yes'.tr,
              isSelected: controller.hasPms.value,
              selectedColor: AppColors.orange,
              onTap: () => controller.hasPms.value = true,
            ),
            SymptomChip(
              label: 'log_pms_no'.tr,
              isSelected: !controller.hasPms.value,
              onTap: () => controller.hasPms.value = false,
            ),
          ],
        ));
  }

  Widget _buildSymptomsSection() {
    return Obx(() => LogSection(
          title: 'log_symptoms'.tr,
          children: SymptomType.values.map((symptom) {
            return SymptomChip(
              label: symptom.labelKey.tr,
              isSelected: controller.selectedSymptoms.contains(symptom.name),
              selectedColor: AppColors.green,
              onTap: () => controller.toggleSymptom(symptom),
            );
          }).toList(),
        ));
  }

  Widget _buildCravingsSection() {
    return Obx(() => LogSection(
          title: 'log_cravings'.tr,
          children: CravingType.values.map((craving) {
            return SymptomChip(
              label: craving.labelKey.tr,
              isSelected: controller.selectedCravings.contains(craving.name),
              selectedColor: AppColors.orange,
              onTap: () => controller.toggleCraving(craving),
            );
          }).toList(),
        ));
  }

  Widget _buildDigestionSection() {
    return Obx(() => LogSection(
          title: 'log_digestion'.tr,
          children: DigestionSymptom.values.map((symptom) {
            return SymptomChip(
              label: symptom.labelKey.tr,
              isSelected: controller.digestion.value == symptom,
              selectedColor: AppColors.green,
              onTap: () => controller.digestion.value = symptom,
            );
          }).toList(),
        ));
  }

  Widget _buildStoolSection() {
    return Obx(() => LogSection(
          title: 'log_stool'.tr,
          children: StoolType.values.map((type) {
            return SymptomChip(
              label: type.labelKey.tr,
              isSelected: controller.stool.value == type,
              selectedColor: AppColors.green,
              onTap: () => controller.stool.value = type,
            );
          }).toList(),
        ));
  }

  Widget _buildSleepQualitySection() {
    return Obx(() => LogSection(
          title: 'log_sleep_quality'.tr,
          children: SleepQualitySymptom.values.map((quality) {
            return SymptomChip(
              label: quality.labelKey.tr,
              isSelected: controller.selectedSleepQualities.contains(quality.name),
              selectedColor: AppColors.blue,
              onTap: () => controller.toggleSleepQuality(quality),
            );
          }).toList(),
        ));
  }

  Widget _buildDailyNoteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('log_daily_note'.tr, style: context.clune.label),
        const SizedBox(height: 10),
        TextField(
          controller: controller.dailyNoteController,
          maxLines: 3,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9áéíóúÁÉÍÓÚñÑüÜ\s]')),
          ],
          decoration: InputDecoration(hintText: 'log_daily_note_hint'.tr),
          onChanged: (value) => controller.dailyNote.value = value,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPainMedicationSection(BuildContext context) {
    final clune = context.clune;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('log_pain_medication'.tr, style: clune.label),
            TextButton(
              onPressed: () async {
                await PainMedicationSheet.show();
                await controller.reloadPreferredMedication();
              },
              child: Text('medication_configure'.tr),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final preferred = controller.preferredPainMedication.value;
          if (preferred.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilterChip(
                label: Text('${'medication_preferred_short'.tr}: $preferred'),
                selected: controller.tookPainMedication.value &&
                    controller.medications.value == preferred,
                onSelected: (_) => controller.applyPreferredMedication(),
                selectedColor: AppColors.lightTeal,
                checkmarkColor: AppColors.primaryTeal,
              ),
            );
          }
          return Text('medication_setup_subtitle'.tr, style: clune.bodySmall);
        }),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PainMedications.options.map((med) {
                final isSelected = controller.medications.value == med;
                return FilterChip(
                  label: Text(med),
                  selected: isSelected,
                  onSelected: (_) => controller.togglePainMedication(med),
                  selectedColor: AppColors.lightOrange,
                  checkmarkColor: AppColors.orange,
                );
              }).toList(),
            )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildExerciseSection(BuildContext context) {
    return Obx(() => LogSection(
          title: 'log_exercise'.tr,
          children: [
            SymptomChip(
              label: 'log_yes'.tr,
              isSelected: controller.exercise.value,
              selectedColor: AppColors.primaryTeal,
              onTap: () => controller.exercise.value = true,
            ),
            SymptomChip(
              label: 'log_no'.tr,
              isSelected: !controller.exercise.value,
              onTap: () => controller.exercise.value = false,
            ),
          ],
        ));
  }

  Widget _buildFloatingSaveButton(BuildContext context) {
    final clune = context.clune;
    return Material(
      elevation: 8,
      shadowColor: clune.cardBorder,
      borderRadius: BorderRadius.circular(16),
      color: AppColors.primaryTeal,
      child: InkWell(
        onTap: controller.saveLog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            'log_save'.tr,
            style: clune.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSection(BuildContext context) {
    final clune = context.clune;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('period_history'.tr, style: clune.label),
            TextButton.icon(
              onPressed: openPeriodHistorySheet,
              icon: const Icon(Icons.water_drop_outlined, size: 18),
              label: Text('period_add'.tr),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final cycles = controller.periodHistory;
          if (cycles.isEmpty) {
            return Text('period_history_empty'.tr, style: clune.bodyMedium);
          }
          return Column(
            children: cycles.reversed.take(3).map((cycle) {
              final end = cycle.endDate;
              final label = end != null
                  ? '${AppDateUtils.formatShortDate(cycle.startDate)} - ${AppDateUtils.formatShortDate(end)}'
                  : '${AppDateUtils.formatShortDate(cycle.startDate)} (${'period_active'.tr})';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(label, style: clune.bodyLarge),
                trailing: Icon(Icons.chevron_right, size: 18, color: clune.textSecondary),
                onTap: openPeriodHistorySheet,
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

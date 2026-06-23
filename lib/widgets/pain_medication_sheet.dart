import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/repositories/user_repository.dart';
import 'package:clune/utils/pain_medications.dart';

/// Sheet para configurar medicamento preferido contra el dolor.
class PainMedicationSheet extends StatefulWidget {
  const PainMedicationSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const PainMedicationSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<PainMedicationSheet> createState() => _PainMedicationSheetState();
}

class _PainMedicationSheetState extends State<PainMedicationSheet> {
  final _userRepo = Get.find<UserRepository>();
  String _selected = PainMedications.options.first;
  int _leadDays = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _userRepo.getProfile();
    if (profile != null) {
      if (profile.preferredPainMedication.isNotEmpty) {
        _selected = profile.preferredPainMedication;
      }
      _leadDays = profile.safePainMedicationLeadDays;
      profile.normalizeMedicationFields();
      await _userRepo.saveProfile(profile);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    await _userRepo.updatePainMedication(
      medication: _selected,
      leadDays: _leadDays,
    );
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Container(
      decoration: BoxDecoration(
        color: clune.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: _loading
              ? const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: clune.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'medication_title'.tr,
                      style: AppTextStyles.headingMedium.copyWith(color: clune.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'medication_subtitle'.tr,
                      style: AppTextStyles.bodySmall.copyWith(color: clune.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'medication_preferred'.tr,
                      style: AppTextStyles.label.copyWith(color: clune.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PainMedications.options.map((med) {
                        final isSelected = _selected == med;
                        return ChoiceChip(
                          label: Text(med),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selected = med),
                          selectedColor: AppColors.lightTeal,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryTeal : clune.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'medication_lead_days'.tr,
                      style: AppTextStyles.label.copyWith(color: clune.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _leadDays.toDouble(),
                            min: 0,
                            max: 3,
                            divisions: 3,
                            label: '$_leadDays',
                            activeColor: AppColors.primaryTeal,
                            onChanged: (v) => setState(() => _leadDays = v.round()),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            _leadDays == 0
                                ? 'medication_lead_same_day'.tr
                                : 'medication_lead_before'.trParams({'days': '$_leadDays'}),
                            style: AppTextStyles.bodySmall.copyWith(color: clune.textSecondary),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text('save'.tr),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

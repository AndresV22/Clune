import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/controllers/onboarding_controller.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/widgets/clune_logo.dart';

/// Vista de onboarding con 4 pasos.
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildStepContent(),
                ),
              ),
              _buildNavigationButtons(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Obx(() {
        final progress = (controller.currentStep.value + 1) / OnboardingController.totalSteps;
        final clune = Get.context!.clune;
        return LinearProgressIndicator(
          value: progress,
          backgroundColor: clune.divider,
          color: AppColors.primaryTeal,
          borderRadius: BorderRadius.circular(4),
          minHeight: 4,
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (controller.currentStep.value) {
      case 0:
        return _WelcomeStep(controller: controller);
      case 1:
        return _BirthDateStep(controller: controller);
      case 2:
        return _PeriodStep(controller: controller);
      case 3:
        return _ConfirmStep(controller: controller);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Obx(() => controller.currentStep.value > 0
              ? TextButton(
                  onPressed: controller.previousStep,
                  child: Text('cancel'.tr, style: const TextStyle(color: AppColors.mediumGray)),
                )
              : const SizedBox(width: 80)),
          const Spacer(),
          Obx(() {
            final step = controller.currentStep.value;
            // Dependencias reactivas de todos los campos del onboarding.
            controller.nameInput.value;
            controller.birthDate.value;
            controller.lastPeriodStart.value;
            final canProceed = controller.canProceedForStep(step);

            return ElevatedButton(
              onPressed: canProceed ? controller.nextStep : null,
              child: Text(
                step == OnboardingController.totalSteps - 1
                    ? 'onboarding_start'.tr
                    : 'onboarding_next'.tr,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final OnboardingController controller;

  const _WelcomeStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        const Center(child: CluneLogo(size: 140)),
        const SizedBox(height: 32),
        Text('onboarding_welcome'.tr, style: AppTextStyles.headingLarge),
        const SizedBox(height: 8),
        Text('onboarding_welcome_sub'.tr, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 40),
        Text('onboarding_name'.tr, style: AppTextStyles.label),
        const SizedBox(height: 12),
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(hintText: 'onboarding_name_hint'.tr),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => controller.nameInput.value = value,
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _BirthDateStep extends StatelessWidget {
  final OnboardingController controller;

  const _BirthDateStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text('onboarding_birth'.tr, style: AppTextStyles.headingLarge),
        const SizedBox(height: 40),
        Obx(() {
          final date = controller.birthDate.value;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Selecciona tu fecha de nacimiento',
              style: AppTextStyles.bodyLarge,
            ),
            trailing: const Icon(Icons.calendar_today, color: AppColors.primaryTeal),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) controller.setBirthDate(picked);
            },
          );
        }),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _PeriodStep extends StatelessWidget {
  final OnboardingController controller;

  const _PeriodStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text('onboarding_last_period'.tr, style: AppTextStyles.headingLarge),
        const SizedBox(height: 40),
        Obx(() {
          final date = controller.lastPeriodStart.value;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Selecciona la fecha',
              style: AppTextStyles.bodyLarge,
            ),
            trailing: const Icon(Icons.calendar_today, color: AppColors.primaryRed),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 14)),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (picked != null) controller.setLastPeriodStart(picked);
            },
          );
        }),
        const SizedBox(height: 24),
        Text('onboarding_period_length'.tr, style: AppTextStyles.label),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: [3, 4, 5, 6, 7].map((days) {
                final selected = controller.estimatedPeriodLength.value == days;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$days'),
                    selected: selected,
                    onSelected: (_) => controller.estimatedPeriodLength.value = days,
                    selectedColor: AppColors.primaryRed.withValues(alpha: 0.2),
                  ),
                );
              }).toList(),
            )),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  final OnboardingController controller;

  const _ConfirmStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        const Icon(Icons.check_circle, color: AppColors.primaryTeal, size: 64),
        const SizedBox(height: 24),
        Text('onboarding_confirm'.tr, style: AppTextStyles.headingLarge),
        const SizedBox(height: 8),
        Text('onboarding_confirm_sub'.tr, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 32),
        Obx(() => _SummaryRow(
              label: 'Nombre',
              value: controller.nameInput.value.trim(),
            )),
        Obx(() => _SummaryRow(
              label: 'Nacimiento',
              value: controller.birthDate.value != null
                  ? '${controller.birthDate.value!.day}/${controller.birthDate.value!.month}/${controller.birthDate.value!.year}'
                  : '-',
            )),
        Obx(() => _SummaryRow(
              label: 'Último periodo',
              value: controller.lastPeriodStart.value != null
                  ? '${controller.lastPeriodStart.value!.day}/${controller.lastPeriodStart.value!.month}/${controller.lastPeriodStart.value!.year}'
                  : '-',
            )),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/models/user_profile.dart';
import 'package:clune/models/cycle_record.dart';
import 'package:clune/repositories/user_repository.dart';
import 'package:clune/repositories/cycle_repository.dart';
import 'package:clune/app/routes/app_routes.dart';
import 'package:clune/utils/date_utils.dart';

/// Controlador del flujo de onboarding (4 pasos).
class OnboardingController extends GetxController {
  final UserRepository _userRepo = Get.find();
  final CycleRepository _cycleRepo = Get.find();

  /// Paso actual del onboarding (0-3).
  final currentStep = 0.obs;

  /// Datos recolectados durante el onboarding.
  final nameController = TextEditingController();

  /// Nombre reactivo para habilitar el botón "Siguiente" (Obx no observa TextEditingController).
  final nameInput = ''.obs;

  final birthDate = Rxn<DateTime>();
  final lastPeriodStart = Rxn<DateTime>();
  final estimatedPeriodLength = 5.obs;

  /// Total de pasos.
  static const int totalSteps = 4;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_syncNameInput);
  }

  void _syncNameInput() => nameInput.value = nameController.text;

  /// Valida si el paso actual puede avanzar (usa solo .obs).
  bool canProceedForStep(int step) {
    switch (step) {
      case 0:
        return nameInput.value.trim().isNotEmpty;
      case 1:
        return birthDate.value != null;
      case 2:
        return lastPeriodStart.value != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  /// Valida si el paso actual puede avanzar.
  bool get canProceed => canProceedForStep(currentStep.value);

  /// Avanza al siguiente paso o completa el onboarding.
  Future<void> nextStep() async {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    } else {
      await _completeOnboarding();
    }
  }

  /// Retrocede un paso.
  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  /// Selecciona fecha de nacimiento.
  void setBirthDate(DateTime date) => birthDate.value = date;

  /// Selecciona fecha del último periodo.
  void setLastPeriodStart(DateTime date) => lastPeriodStart.value = date;

  /// Completa onboarding: crea perfil y primer ciclo.
  Future<void> _completeOnboarding() async {
    final profile = UserProfile()
      ..name = nameController.text.trim()
      ..birthDate = birthDate.value!
      ..averageCycleLength = 28
      ..averagePeriodLength = estimatedPeriodLength.value.toDouble()
      ..onboardingCompleted = true;

    await _userRepo.saveProfile(profile);

    final periodStart = AppDateUtils.normalizeDate(lastPeriodStart.value!);
    final cycle = CycleRecord()
      ..startDate = periodStart
      ..endDate = periodStart.add(
        Duration(days: estimatedPeriodLength.value - 1),
      )
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _cycleRepo.saveCycle(cycle);

    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    nameController.removeListener(_syncNameInput);
    nameController.dispose();
    super.onClose();
  }
}

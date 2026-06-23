import 'package:get/get.dart';
import 'package:clune/controllers/onboarding_controller.dart';

/// Binding para el flujo de onboarding.
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}

import 'package:get/get.dart';
import 'package:clune/app/routes/app_routes.dart';
import 'package:clune/app/bindings/main_binding.dart';
import 'package:clune/app/bindings/onboarding_binding.dart';
import 'package:clune/views/onboarding/onboarding_view.dart';
import 'package:clune/views/main/main_view.dart';
import 'package:clune/views/articles/article_detail_view.dart';
import 'package:clune/views/profile/profile_view.dart';
import 'package:clune/views/daily_log/log_sections_settings_view.dart';
import 'package:clune/controllers/profile_controller.dart';
import 'package:clune/controllers/log_sections_settings_controller.dart';

/// Definición de páginas y bindings de GetX.
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.articleDetail,
      page: () => const ArticleDetailView(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.logSectionsSettings,
      page: () => const LogSectionsSettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LogSectionsSettingsController>(
          () => LogSectionsSettingsController(),
        );
      }),
    ),
  ];
}

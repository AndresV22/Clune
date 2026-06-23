import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_theme.dart';
import 'package:clune/app/routes/app_pages.dart';
import 'package:clune/controllers/theme_controller.dart';
import 'package:clune/translations/app_translations.dart';

/// Widget raíz de la aplicación con GetMaterialApp.
class CluneApp extends StatelessWidget {
  /// Ruta inicial determinada en main() según onboarding.
  final String initialRoute;

  const CluneApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        title: 'Clune',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode,
        translations: AppTranslations(),
        locale: const Locale('es', 'ES'),
        fallbackLocale: const Locale('es', 'ES'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        initialRoute: initialRoute,
        getPages: AppPages.routes,
      ),
    );
  }
}

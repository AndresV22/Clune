import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:clune/app/app.dart';
import 'package:clune/app/bindings/initial_binding.dart';
import 'package:clune/app/routes/app_routes.dart';
import 'package:clune/services/database_service.dart';
import 'package:clune/repositories/user_repository.dart';

/// Punto de entrada: inicializa Isar y determina ruta según onboarding.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Requerido por DateFormat con locale (es_ES, en_US).
  await initializeDateFormatting('es_ES');
  await initializeDateFormatting('en_US');

  // Inicializar base de datos Isar
  await Get.putAsync(() => DatabaseService().init());
  InitialBinding().dependencies();

  // Determinar ruta inicial
  final userRepo = Get.find<UserRepository>();
  final onboardingCompleted = await userRepo.isOnboardingCompleted();
  final initialRoute = onboardingCompleted ? AppRoutes.main : AppRoutes.onboarding;

  runApp(CluneApp(initialRoute: initialRoute));
}

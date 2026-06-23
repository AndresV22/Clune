import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';

import 'package:clune/app/theme/clune_theme_colors.dart';

/// Tema suave para date pickers (rojo pastel en lugar del rojo intenso del tema).
ThemeData _datePickerTheme(BuildContext context) {
  final base = Theme.of(context);
  final clune = context.clune;
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.softRed,
      onPrimary: Colors.white,
      primaryContainer: AppColors.softRedLight,
      onPrimaryContainer: clune.textPrimary,
      secondary: AppColors.softRed,
      onSecondary: Colors.white,
    ),
    datePickerTheme: DatePickerThemeData(
      rangeSelectionBackgroundColor: AppColors.softRedLight,
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.softRed;
        }
        return null;
      }),
      todayBackgroundColor: WidgetStateProperty.all(
        AppColors.softRedLight.withValues(alpha: 0.6),
      ),
    ),
  );
}

/// Muestra un date picker con el contexto raíz de la app (compatible con Get.dialog/sheets).
Future<DateTime?> showAppDatePicker({
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final context = Get.context;
  if (context == null) return Future.value(null);

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    locale: const Locale('es', 'ES'),
    builder: (context, child) => Theme(
      data: _datePickerTheme(context),
      child: child!,
    ),
  );
}

/// Muestra un selector de rango de fechas con el contexto raíz de la app.
Future<DateTimeRange?> showAppDateRangePicker({
  DateTimeRange? initialDateRange,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final context = Get.context;
  if (context == null) return Future.value(null);

  final now = DateTime.now();
  final defaultRange = initialDateRange ??
      DateTimeRange(
        start: now,
        end: now,
      );

  return showDateRangePicker(
    context: context,
    initialDateRange: defaultRange,
    firstDate: firstDate,
    lastDate: lastDate,
    locale: const Locale('es', 'ES'),
    helpText: 'period_range_help'.tr,
    saveText: 'period_range_save'.tr,
    cancelText: 'cancel'.tr,
    builder: (context, child) => Theme(
      data: _datePickerTheme(context),
      child: child!,
    ),
  );
}

/// Muestra un diálogo Material usando el navigator raíz de GetMaterialApp.
Future<T?> showAppDialog<T>(Widget dialog) {
  final context = Get.context;
  if (context == null) return Future.value(null);

  return showDialog<T>(
    context: context,
    builder: (_) => dialog,
  );
}

import 'package:flutter/material.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';

/// Temas claro y oscuro de la aplicación.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        clune: CluneThemeColors.light,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        clune: CluneThemeColors.dark,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required CluneThemeColors clune,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: clune.background,
      extensions: [clune],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primaryTeal,
        onPrimary: Colors.white,
        secondary: AppColors.primaryRed,
        onSecondary: Colors.white,
        error: AppColors.primaryRed,
        onError: Colors.white,
        surface: clune.surface,
        onSurface: clune.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: clune.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingMedium.copyWith(
          color: clune.textPrimary,
        ),
        iconTheme: IconThemeData(color: clune.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: clune.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppTextStyles.label.copyWith(color: Colors.white),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: clune.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: clune.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(color: clune.divider),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryTeal;
          }
          return isDark ? clune.textSecondary : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryTeal.withValues(alpha: 0.4);
          }
          return clune.divider;
        }),
      ),
    );
  }
}

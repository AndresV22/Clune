import 'package:flutter/material.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';

/// Colores semánticos que cambian entre tema claro y oscuro.
@immutable
class CluneThemeColors extends ThemeExtension<CluneThemeColors> {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color inputFill;
  final Color chipBackground;
  final Color navBarBackground;
  final Color cardBorder;
  final Color warmAccentBackground;
  final Color warmAccentBorder;
  final Color cycleRingTrack;

  const CluneThemeColors({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.inputFill,
    required this.chipBackground,
    required this.navBarBackground,
    required this.cardBorder,
    required this.warmAccentBackground,
    required this.warmAccentBorder,
    required this.cycleRingTrack,
  });

  static const light = CluneThemeColors(
    background: AppColors.background,
    surface: AppColors.background,
    textPrimary: AppColors.darkText,
    textSecondary: AppColors.mediumGray,
    divider: AppColors.lightGray,
    inputFill: Color(0x66ECECEC),
    chipBackground: Color(0x80E0F4F7),
    navBarBackground: AppColors.background,
    cardBorder: Color(0x1A000000),
    warmAccentBackground: AppColors.lightOrange,
    warmAccentBorder: Color(0x4DF5A623),
    cycleRingTrack: AppColors.lightGray,
  );

  static const dark = CluneThemeColors(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFAAAAAA),
    divider: Color(0xFF333333),
    inputFill: Color(0xFF2A2A2A),
    chipBackground: Color(0xFF1A3A40),
    navBarBackground: Color(0xFF1A1A1A),
    cardBorder: Color(0x33FFFFFF),
    warmAccentBackground: Color(0xFF2A2218),
    warmAccentBorder: Color(0x33F5A623),
    cycleRingTrack: Color(0xFF3A3A3A),
  );

  @override
  CluneThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? inputFill,
    Color? chipBackground,
    Color? navBarBackground,
    Color? cardBorder,
    Color? warmAccentBackground,
    Color? warmAccentBorder,
    Color? cycleRingTrack,
  }) {
    return CluneThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      inputFill: inputFill ?? this.inputFill,
      chipBackground: chipBackground ?? this.chipBackground,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      warmAccentBackground: warmAccentBackground ?? this.warmAccentBackground,
      warmAccentBorder: warmAccentBorder ?? this.warmAccentBorder,
      cycleRingTrack: cycleRingTrack ?? this.cycleRingTrack,
    );
  }

  @override
  CluneThemeColors lerp(ThemeExtension<CluneThemeColors>? other, double t) {
    if (other is! CluneThemeColors) return this;
    return CluneThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      navBarBackground: Color.lerp(navBarBackground, other.navBarBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      warmAccentBackground:
          Color.lerp(warmAccentBackground, other.warmAccentBackground, t)!,
      warmAccentBorder: Color.lerp(warmAccentBorder, other.warmAccentBorder, t)!,
      cycleRingTrack: Color.lerp(cycleRingTrack, other.cycleRingTrack, t)!,
    );
  }
}

extension CluneThemeContext on BuildContext {
  CluneThemeColors get clune =>
      Theme.of(this).extension<CluneThemeColors>() ?? CluneThemeColors.light;
}

/// Estilos tipográficos con colores del tema activo.
/// Limpia [TextStyle.foreground] para que Google Fonts respete el color.
extension CluneThemeTextStyles on CluneThemeColors {
  TextStyle _themed(TextStyle base, Color color) => base.copyWith(
        color: color,
        foreground: null,
        background: null,
        decorationColor: color,
      );

  TextStyle get headingLarge => _themed(AppTextStyles.headingLarge, textPrimary);
  TextStyle get headingMedium => _themed(AppTextStyles.headingMedium, textPrimary);
  TextStyle get label => _themed(AppTextStyles.label, textPrimary);
  TextStyle get bodyLarge => _themed(AppTextStyles.bodyLarge, textPrimary);
  TextStyle get bodyMedium => _themed(AppTextStyles.bodyMedium, textSecondary);
  TextStyle get bodySmall => _themed(AppTextStyles.bodySmall, textSecondary);
  TextStyle get bodySmallPrimary => _themed(AppTextStyles.bodySmall, textPrimary);
  TextStyle get centerMessage => _themed(AppTextStyles.centerMessage, textPrimary);
}

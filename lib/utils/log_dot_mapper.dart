import 'package:flutter/material.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/models/daily_log.dart';
import 'package:clune/utils/enums.dart';

/// Mapea anotaciones diarias a colores para el calendario y el anillo.
class LogDotMapper {
  LogDotMapper._();

  /// Colores de indicadores para un registro diario (orden de prioridad visual).
  static List<Color> colorsForLog(DailyLog log) {
    final colors = <Color>[];

    if (log.bleeding != BleedingLevel.none) {
      colors.add(AppColors.primaryRed);
    }
    if (log.cramps) {
      colors.add(AppColors.orange);
    }
    if (log.discharge != DischargeType.none) {
      colors.add(AppColors.blue);
    }
    if (log.sexDrive == SexDriveLevel.high) {
      colors.add(AppColors.purple);
    }
    if (log.symptoms.contains(SymptomType.headache.name)) {
      colors.add(AppColors.green);
    }
    if (log.mood == MoodType.irritable ||
        log.mood == MoodType.anxious ||
        log.mood == MoodType.sad) {
      colors.add(AppColors.yellow);
    }
    if (log.pain != PainLevel.none && !log.cramps) {
      colors.add(AppColors.orange.withValues(alpha: 0.7));
    }
    if (log.sexualActivity) {
      colors.add(AppColors.purple.withValues(alpha: 0.6));
    }
    if (log.exercise) {
      colors.add(AppColors.primaryTeal);
    }
    if (log.notes.isNotEmpty && colors.length < 4) {
      colors.add(AppColors.mediumGray);
    }

    return colors;
  }
}

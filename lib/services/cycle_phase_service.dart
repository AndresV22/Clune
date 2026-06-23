import 'package:clune/models/cycle_record.dart';
import 'package:clune/utils/constants.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/utils/enums.dart';

/// Información descriptiva de una fase del ciclo.
class PhaseInfo {
  final CyclePhase phase;
  final String name;
  final String shortDescription;
  final String educationalText;

  const PhaseInfo({
    required this.phase,
    required this.name,
    required this.shortDescription,
    required this.educationalText,
  });
}

/// Información educativa de la ventana fértil.
class FertileWindowInfo {
  final String titleKey;
  final String shortDescriptionKey;
  final String educationalTextKey;
  final List<String> indicatorKeys;

  const FertileWindowInfo({
    required this.titleKey,
    required this.shortDescriptionKey,
    required this.educationalTextKey,
    required this.indicatorKeys,
  });
}

/// Servicio para detectar la fase actual del ciclo menstrual.
class CyclePhaseService {
  /// Textos educativos por fase (preparados para i18n).
  static const Map<CyclePhase, PhaseInfo> _phaseInfo = {
    CyclePhase.menstruation: PhaseInfo(
      phase: CyclePhase.menstruation,
      name: 'Menstruación',
      shortDescription: 'Tu cuerpo está eliminando el revestimiento uterino.',
      educationalText:
          'La menstruación marca el inicio de tu ciclo. Durante estos días, '
          'puedes experimentar sangrado, cólicos y cambios de humor. '
          'Descansa, hidrátate y escucha las señales de tu cuerpo.',
    ),
    CyclePhase.follicular: PhaseInfo(
      phase: CyclePhase.follicular,
      name: 'Fase folicular',
      shortDescription: 'Tus niveles de energía suelen aumentar gradualmente.',
      educationalText:
          'Después de la menstruación, los folículos en los ovarios comienzan '
          'a madurar. El estrógeno aumenta, lo que puede mejorar tu estado de '
          'ánimo y energía. Es una buena fase para actividades físicas.',
    ),
    CyclePhase.ovulation: PhaseInfo(
      phase: CyclePhase.ovulation,
      name: 'Ovulación',
      shortDescription: 'Es tu ventana de máxima fertilidad.',
      educationalText:
          'Durante la ovulación, un óvulo es liberado del ovario. '
          'Puedes notar cambios en el flujo vaginal (tipo clara de huevo) '
          'y un ligero aumento en la temperatura basal.',
    ),
    CyclePhase.luteal: PhaseInfo(
      phase: CyclePhase.luteal,
      name: 'Fase lútea',
      shortDescription: 'Tu cuerpo se prepara para un posible embarazo.',
      educationalText:
          'Después de la ovulación, la progesterona aumenta. Es común '
          'experimentar síntomas de SPM como hinchazón, sensibilidad '
          'en los pechos, cambios de humor y antojos.',
    ),
  };

  static const fertileWindowInfo = FertileWindowInfo(
    titleKey: 'fertile_window_title',
    shortDescriptionKey: 'fertile_window_short',
    educationalTextKey: 'fertile_window_educational',
    indicatorKeys: [
      'fertile_indicator_mucus',
      'fertile_indicator_temperature',
      'fertile_indicator_calendar',
      'fertile_indicator_tests',
    ],
  );

  /// True si el día cae dentro de la ventana fértil estimada.
  bool isInFertileWindow({
    required int cycleDay,
    required int cycleLength,
  }) {
    final window = getFertileWindowDays(cycleLength);
    return cycleDay >= window.start && cycleDay <= window.end;
  }

  /// Segmentos del anillo sin solapamiento entre menstruación y ventana fértil.
  ({
    int periodLength,
    int fertileStart,
    int fertileEnd,
  }) getRingSegments({
    required int periodLength,
    required int cycleLength,
  }) {
    final window = getFertileWindowDays(cycleLength);
    final clampedPeriod = periodLength.clamp(1, cycleLength);
    final maxPeriodEnd = (window.start - 1).clamp(1, cycleLength);
    final effectivePeriod = clampedPeriod.clamp(1, maxPeriodEnd);
    final effectiveFertileStart = window.start.clamp(effectivePeriod + 1, cycleLength);
    final effectiveFertileEnd = window.end.clamp(effectiveFertileStart, cycleLength);

    return (
      periodLength: effectivePeriod,
      fertileStart: effectiveFertileStart,
      fertileEnd: effectiveFertileEnd,
    );
  }

  FertileWindowInfo getFertileWindowInfo() => fertileWindowInfo;

  /// Determina la fase actual del ciclo.
  CyclePhase getCurrentPhase({
    required int cycleDay,
    required int periodLength,
    required int cycleLength,
  }) {
    if (cycleDay <= periodLength) return CyclePhase.menstruation;

    final ovulationDay = cycleLength - AppConstants.lutealPhaseLength;
    if (cycleDay == ovulationDay) return CyclePhase.ovulation;
    if (cycleDay < ovulationDay) return CyclePhase.follicular;
    return CyclePhase.luteal;
  }

  /// Obtiene información educativa de una fase.
  PhaseInfo getPhaseInfo(CyclePhase phase) => _phaseInfo[phase]!;

  /// Calcula el día de ovulación estimado en el ciclo.
  int getOvulationDay(int cycleLength) {
    return cycleLength - AppConstants.lutealPhaseLength;
  }

  /// Calcula rango de días de ventana fértil (1-indexed).
  ({int start, int end}) getFertileWindowDays(int cycleLength) {
    final ovulationDay = getOvulationDay(cycleLength);
    return (
      start: ovulationDay - AppConstants.fertileDaysBefore,
      end: ovulationDay + AppConstants.fertileDaysAfter,
    );
  }

  /// Día del periodo actual (1-indexed) si está en menstruación.
  int? getPeriodDay({
    required CycleRecord? activeCycle,
    required DateTime today,
  }) {
    if (activeCycle == null) return null;
    final days = AppDateUtils.daysBetween(activeCycle.startDate, today) + 1;
    if (days < 1) return null;
    return days;
  }
}

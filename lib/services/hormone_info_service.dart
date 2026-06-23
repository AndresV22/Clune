import 'package:clune/utils/constants.dart';
import 'package:clune/utils/enums.dart';

/// Nivel hormonal simplificado para la UI.
enum HormoneLevel {
  low,
  rising,
  high,
  peak,
}

/// Información hormonal de una sub-fase del ciclo.
class HormonePhaseInfo {
  final CycleSubPhase subPhase;
  final String titleKey;
  final String descriptionKey;
  final HormoneLevel estrogen;
  final HormoneLevel progesterone;
  final HormoneLevel fsh;
  final List<String> experienceKeys;

  const HormonePhaseInfo({
    required this.subPhase,
    required this.titleKey,
    required this.descriptionKey,
    required this.estrogen,
    required this.progesterone,
    required this.fsh,
    required this.experienceKeys,
  });
}

/// Servicio educativo de hormonas por sub-fase del ciclo.
class HormoneInfoService {
  static const _infos = {
    CycleSubPhase.earlyMenstruation: HormonePhaseInfo(
      subPhase: CycleSubPhase.earlyMenstruation,
      titleKey: 'subPhase_earlyMenstruation',
      descriptionKey: 'hormone_desc_earlyMenstruation',
      estrogen: HormoneLevel.low,
      progesterone: HormoneLevel.low,
      fsh: HormoneLevel.rising,
      experienceKeys: ['hormone_exp_cramps', 'hormone_exp_fatigue'],
    ),
    CycleSubPhase.earlyFollicular: HormonePhaseInfo(
      subPhase: CycleSubPhase.earlyFollicular,
      titleKey: 'subPhase_earlyFollicular',
      descriptionKey: 'hormone_desc_earlyFollicular',
      estrogen: HormoneLevel.low,
      progesterone: HormoneLevel.low,
      fsh: HormoneLevel.high,
      experienceKeys: ['hormone_exp_recovery', 'hormone_exp_calm'],
    ),
    CycleSubPhase.lateFollicular: HormonePhaseInfo(
      subPhase: CycleSubPhase.lateFollicular,
      titleKey: 'subPhase_lateFollicular',
      descriptionKey: 'hormone_desc_lateFollicular',
      estrogen: HormoneLevel.rising,
      progesterone: HormoneLevel.low,
      fsh: HormoneLevel.low,
      experienceKeys: ['hormone_exp_energy', 'hormone_exp_mood_up'],
    ),
    CycleSubPhase.ovulation: HormonePhaseInfo(
      subPhase: CycleSubPhase.ovulation,
      titleKey: 'subPhase_ovulation',
      descriptionKey: 'hormone_desc_ovulation',
      estrogen: HormoneLevel.peak,
      progesterone: HormoneLevel.low,
      fsh: HormoneLevel.peak,
      experienceKeys: ['hormone_exp_fertility', 'hormone_exp_libido'],
    ),
    CycleSubPhase.earlyLuteal: HormonePhaseInfo(
      subPhase: CycleSubPhase.earlyLuteal,
      titleKey: 'subPhase_earlyLuteal',
      descriptionKey: 'hormone_desc_earlyLuteal',
      estrogen: HormoneLevel.high,
      progesterone: HormoneLevel.rising,
      fsh: HormoneLevel.low,
      experienceKeys: ['hormone_exp_calm', 'hormone_exp_breast'],
    ),
    CycleSubPhase.lateLuteal: HormonePhaseInfo(
      subPhase: CycleSubPhase.lateLuteal,
      titleKey: 'subPhase_lateLuteal',
      descriptionKey: 'hormone_desc_lateLuteal',
      estrogen: HormoneLevel.low,
      progesterone: HormoneLevel.high,
      fsh: HormoneLevel.low,
      experienceKeys: ['hormone_exp_pms', 'hormone_exp_cravings'],
    ),
  };

  CycleSubPhase getSubPhase({
    required int cycleDay,
    required int periodLength,
    required int cycleLength,
  }) {
    final ovulationDay = cycleLength - AppConstants.lutealPhaseLength;

    if (cycleDay <= periodLength) {
      return CycleSubPhase.earlyMenstruation;
    }
    if (cycleDay < ovulationDay - 3) {
      return CycleSubPhase.earlyFollicular;
    }
    if (cycleDay < ovulationDay) {
      return CycleSubPhase.lateFollicular;
    }
    if (cycleDay <= ovulationDay + 1) {
      return CycleSubPhase.ovulation;
    }
    final lutealMid = ovulationDay + ((cycleLength - ovulationDay) / 2).round();
    if (cycleDay <= lutealMid) {
      return CycleSubPhase.earlyLuteal;
    }
    return CycleSubPhase.lateLuteal;
  }

  HormonePhaseInfo getInfo(CycleSubPhase subPhase) => _infos[subPhase]!;

  String levelLabelKey(HormoneLevel level) {
    switch (level) {
      case HormoneLevel.low:
        return 'hormone_level_low';
      case HormoneLevel.rising:
        return 'hormone_level_rising';
      case HormoneLevel.high:
        return 'hormone_level_high';
      case HormoneLevel.peak:
        return 'hormone_level_peak';
    }
  }
}

/// Nivel de sangrado registrado en el día.
enum BleedingLevel {
  none,
  light,
  moderate,
  heavy,
}

/// Color del sangrado menstrual.
enum BleedingColor {
  none,
  brown,
  red,
}

/// Nivel de dolor registrado en el día.
enum PainLevel {
  none,
  light,
  moderate,
  strong,
  intense,
  unbearable,
}

/// Tipo de flujo vaginal.
enum DischargeType {
  none,
  sticky,
  creamy,
  watery,
  eggWhite,
}

/// Nivel de deseo sexual.
enum SexDriveLevel {
  low,
  normal,
  high,
}

/// Estado de ánimo del día.
enum MoodType {
  happy,
  calm,
  irritable,
  anxious,
  sad,
  angry,
}

/// Síntomas registrables.
enum SymptomType {
  headache,
  breastTenderness,
  bloating,
  acne,
  fatigue,
  nausea,
  insomnia,
  poorSleep,
  bodyDiscomfort,
}

/// Nivel de energía del día.
enum EnergyLevel {
  exhausted,
  tired,
  normal,
  energetic,
}

/// Antojos alimentarios.
enum CravingType {
  sushi,
  instantNoodles,
  sweet,
  fatty,
}

/// Síntomas digestivos.
enum DigestionSymptom {
  normal,
  bloating,
  gas,
  nausea,
  heartburn,
  vomiting,
}

/// Tipo de heces.
enum StoolType {
  normal,
  constipation,
  diarrhea,
}

/// Calidad del sueño (multi-select).
enum SleepQualitySymptom {
  difficultyFallingAsleep,
  restedOnWake,
  tiredOnWake,
  unrestedSleep,
  vividDreams,
  nightmare,
  nightSweats,
}

/// Fases del ciclo menstrual.
enum CyclePhase {
  menstruation,
  follicular,
  ovulation,
  luteal,
}

/// Sub-fases del ciclo para información hormonal.
enum CycleSubPhase {
  earlyMenstruation,
  earlyFollicular,
  lateFollicular,
  ovulation,
  earlyLuteal,
  lateLuteal,
}

/// Clasificación de regularidad del ciclo.
enum CycleRegularity {
  veryRegular,
  regular,
  irregular,
}

/// Tipo de anticonceptivo.
enum ContraceptiveType {
  none,
  combinedPill,
  miniPill,
  injection,
  patch,
  vaginalRing,
  implant,
  hormonalIud,
  copperIud,
  condoms,
  fertilityAwareness,
  other,
}

/// Extensión para obtener claves de traducción de enums.
extension BleedingLevelExt on BleedingLevel {
  String get labelKey => 'bleeding_$name';
}

extension BleedingColorExt on BleedingColor {
  String get labelKey => 'bleedingColor_$name';
}

extension PainLevelExt on PainLevel {
  String get labelKey => 'pain_$name';
}

extension DischargeTypeExt on DischargeType {
  String get labelKey => 'discharge_$name';
}

extension SexDriveLevelExt on SexDriveLevel {
  String get labelKey => 'sexDrive_$name';
}

extension MoodTypeExt on MoodType {
  String get labelKey => 'mood_$name';
}

extension SymptomTypeExt on SymptomType {
  String get labelKey => 'symptom_$name';
}

extension EnergyLevelExt on EnergyLevel {
  String get labelKey => 'energy_$name';
}

extension CravingTypeExt on CravingType {
  String get labelKey => 'craving_$name';
}

extension DigestionSymptomExt on DigestionSymptom {
  String get labelKey => 'digestion_$name';
}

extension StoolTypeExt on StoolType {
  String get labelKey => 'stool_$name';
}

extension SleepQualitySymptomExt on SleepQualitySymptom {
  String get labelKey => 'sleepQuality_$name';
}

extension CyclePhaseExt on CyclePhase {
  String get labelKey => 'phase_$name';
}

extension CycleSubPhaseExt on CycleSubPhase {
  String get labelKey => 'subPhase_$name';
}

extension CycleRegularityExt on CycleRegularity {
  String get labelKey => 'regularity_$name';
}

extension ContraceptiveTypeExt on ContraceptiveType {
  String get labelKey => 'contraceptive_$name';

  bool get isHormonal {
    switch (this) {
      case ContraceptiveType.combinedPill:
      case ContraceptiveType.miniPill:
      case ContraceptiveType.injection:
      case ContraceptiveType.patch:
      case ContraceptiveType.vaginalRing:
      case ContraceptiveType.implant:
      case ContraceptiveType.hormonalIud:
        return true;
      default:
        return false;
    }
  }
}

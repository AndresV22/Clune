/// IDs estables de secciones del registro diario.
class LogSectionIds {
  LogSectionIds._();

  static const bleeding = 'bleeding';
  static const bleedingColor = 'bleedingColor';
  static const pain = 'pain';
  static const cramps = 'cramps';
  static const discharge = 'discharge';
  static const sexualActivity = 'sexualActivity';
  static const sexDrive = 'sexDrive';
  static const mood = 'mood';
  static const energy = 'energy';
  static const pms = 'pms';
  static const symptoms = 'symptoms';
  static const cravings = 'cravings';
  static const digestion = 'digestion';
  static const stool = 'stool';
  static const sleepQuality = 'sleepQuality';
  static const dailyNote = 'dailyNote';
  static const painMedication = 'painMedication';
  static const exercise = 'exercise';
  static const periodHistory = 'periodHistory';

  /// Todas las secciones personalizables (orden de visualización).
  static const all = [
    bleeding,
    bleedingColor,
    pain,
    cramps,
    discharge,
    sexualActivity,
    sexDrive,
    mood,
    energy,
    pms,
    symptoms,
    cravings,
    digestion,
    stool,
    sleepQuality,
    dailyNote,
    painMedication,
    exercise,
    periodHistory,
  ];

  static List<String> defaultEnabled() => List<String>.from(all);

  static String labelKey(String id) => 'log_section_$id';
}

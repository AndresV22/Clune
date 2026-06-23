import 'package:isar/isar.dart';
import 'package:clune/utils/enums.dart';

part 'daily_log.g.dart';

/// Registro diario de síntomas, flujo y estado de ánimo.
@collection
class DailyLog {
  Id id = Isar.autoIncrement;

  /// Fecha del registro (normalizada a medianoche).
  @Index(unique: true, replace: true)
  late DateTime date;

  @enumerated
  BleedingLevel bleeding = BleedingLevel.none;

  @enumerated
  BleedingColor bleedingColor = BleedingColor.none;

  @enumerated
  PainLevel pain = PainLevel.none;

  bool cramps = false;

  @enumerated
  DischargeType discharge = DischargeType.none;

  @enumerated
  SexDriveLevel sexDrive = SexDriveLevel.normal;

  @enumerated
  MoodType mood = MoodType.calm;

  List<String> symptoms = [];

  bool sexualActivity = false;
  bool hadOrgasm = false;
  bool hadSexualFantasies = false;

  @enumerated
  EnergyLevel energy = EnergyLevel.normal;

  bool hasPms = false;

  List<String> cravings = [];

  @enumerated
  DigestionSymptom digestion = DigestionSymptom.normal;

  @enumerated
  StoolType stool = StoolType.normal;

  List<String> sleepQualities = [];

  /// Nota diaria (solo letras y números).
  String dailyNote = '';

  bool exercise = false;

  String medications = '';

  /// Campo legado; se migra a [dailyNote] al leer.
  String notes = '';

  DateTime? updatedAt;
  DateTime? syncedAt;

  /// Nota efectiva (migra desde [notes] si hace falta).
  String get effectiveDailyNote =>
      dailyNote.isNotEmpty ? dailyNote : notes;

  void normalizeFields() {
    if (bleeding == BleedingLevel.none) {
      bleedingColor = BleedingColor.none;
    }
    if (!sexualActivity) {
      hadOrgasm = false;
      hadSexualFantasies = false;
    }
    if (dailyNote.isEmpty && notes.isNotEmpty) {
      dailyNote = notes;
    }
  }
}

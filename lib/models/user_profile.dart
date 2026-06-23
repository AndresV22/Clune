import 'package:isar/isar.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/utils/log_section_ids.dart';

part 'user_profile.g.dart';

/// Perfil de la usuaria con datos básicos y promedios cacheados.
@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  late String name;
  late DateTime birthDate;
  double averageCycleLength = 28;
  double averagePeriodLength = 5;
  bool onboardingCompleted = false;
  String preferredPainMedication = '';
  int painMedicationLeadDays = 1;

  @enumerated
  ContraceptiveType contraceptiveType = ContraceptiveType.none;

  String contraceptiveNotes = '';

  /// IDs de secciones visibles en el registro diario.
  List<String> enabledLogSectionIds = LogSectionIds.defaultEnabled();

  void normalizeMedicationFields() {
    if (painMedicationLeadDays < 0 || painMedicationLeadDays > 7) {
      painMedicationLeadDays = 1;
    }
    if (enabledLogSectionIds.isEmpty) {
      enabledLogSectionIds = LogSectionIds.defaultEnabled();
    }
  }

  int get safePainMedicationLeadDays => UserProfile.normalizeLeadDays(painMedicationLeadDays);

  static int normalizeLeadDays(int value) {
    if (value < 0 || value > 7) return 1;
    return value;
  }

  bool isSectionEnabled(String sectionId) =>
      enabledLogSectionIds.contains(sectionId);

  DateTime? updatedAt;
  DateTime? syncedAt;
}

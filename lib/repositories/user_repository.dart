import 'package:isar/isar.dart';
import 'package:clune/models/user_profile.dart';
import 'package:clune/services/database_service.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/utils/log_section_ids.dart';

/// Repositorio de acceso a datos del perfil de usuario.
class UserRepository {
  final DatabaseService _db;

  UserRepository(this._db);

  /// Obtiene el perfil de usuario (solo hay uno).
  Future<UserProfile?> getProfile() async {
    return _db.isar.userProfiles.filter().nameIsNotEmpty().findFirst();
  }

  /// Guarda o actualiza el perfil de usuario.
  Future<UserProfile> saveProfile(UserProfile profile) async {
    profile.updatedAt = DateTime.now();
    await _db.isar.writeTxn(() async {
      await _db.isar.userProfiles.put(profile);
    });
    return profile;
  }

  /// Verifica si el onboarding fue completado.
  Future<bool> isOnboardingCompleted() async {
    final profile = await getProfile();
    return profile?.onboardingCompleted ?? false;
  }

  /// Actualiza los promedios cacheados en el perfil.
  Future<void> updateAverages({
    required double cycleLength,
    required double periodLength,
  }) async {
    final profile = await getProfile();
    if (profile == null) return;
    profile.averageCycleLength = cycleLength;
    profile.averagePeriodLength = periodLength;
    await saveProfile(profile);
  }

  /// Guarda la medicación preferida para dolor y días de anticipación.
  Future<void> updatePainMedication({
    required String medication,
    required int leadDays,
  }) async {
    final profile = await getProfile();
    if (profile == null) return;
    profile.preferredPainMedication = medication;
    profile.painMedicationLeadDays = leadDays.clamp(0, 7);
    await saveProfile(profile);
  }

  /// Actualiza anticonceptivo y notas opcionales.
  Future<void> updateContraceptive({
    required ContraceptiveType type,
    String notes = '',
  }) async {
    final profile = await getProfile();
    if (profile == null) return;
    profile.contraceptiveType = type;
    profile.contraceptiveNotes = notes;
    await saveProfile(profile);
  }

  /// Actualiza nombre de la usuaria.
  Future<void> updateName(String name) async {
    final profile = await getProfile();
    if (profile == null) return;
    profile.name = name.trim();
    await saveProfile(profile);
  }

  /// Guarda secciones habilitadas del registro diario.
  Future<void> updateEnabledLogSections(List<String> sectionIds) async {
    final profile = await getProfile();
    if (profile == null) return;
    profile.enabledLogSectionIds = List<String>.from(sectionIds);
    await saveProfile(profile);
  }

  /// IDs de secciones habilitadas (o default si no hay perfil).
  Future<List<String>> getEnabledLogSections() async {
    final profile = await getProfile();
    profile?.normalizeMedicationFields();
    return profile?.enabledLogSectionIds ?? LogSectionIds.defaultEnabled();
  }
}

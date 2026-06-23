import 'dart:convert';

import 'package:clune/models/cycle_record.dart';
import 'package:clune/models/daily_log.dart';
import 'package:clune/models/user_profile.dart';
import 'package:clune/repositories/cycle_repository.dart';
import 'package:clune/repositories/daily_log_repository.dart';
import 'package:clune/repositories/user_repository.dart';
import 'package:clune/controllers/theme_controller.dart';
import 'package:clune/services/database_service.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/utils/log_section_ids.dart';

/// Exporta e importa datos en formato JSON `clune_backup_v1`.
class DataBackupService {
  static const backupVersion = 1;

  final DatabaseService _db;
  final UserRepository _userRepo;
  final CycleRepository _cycleRepo;
  final DailyLogRepository _logRepo;
  final ThemeController _themeController;

  DataBackupService(
    this._db,
    this._userRepo,
    this._cycleRepo,
    this._logRepo,
    this._themeController,
  );

  Future<String> exportToJson() async {
    final profile = await _userRepo.getProfile();
    final cycles = await _cycleRepo.getAllCycles();
    final logs = await _logRepo.getAllLogs();

    final data = {
      'version': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile != null ? _profileToJson(profile) : null,
      'cycles': cycles.map(_cycleToJson).toList(),
      'dailyLogs': logs.map(_logToJson).toList(),
      'logSectionPreferences': {
        'enabledSectionIds':
            profile?.enabledLogSectionIds ?? LogSectionIds.defaultEnabled(),
      },
      'settings': {
        'darkMode': _themeController.isDarkMode.value,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importFromJson(String jsonString, {required bool replace}) async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final version = decoded['version'] as int? ?? 0;
    if (version != backupVersion) {
      throw FormatException('Versión de respaldo no compatible: $version');
    }

    if (replace) {
      await _db.isar.writeTxn(() async {
        await _db.isar.clear();
      });
    }

    final profileJson = decoded['profile'] as Map<String, dynamic>?;
    if (profileJson != null) {
      final imported = _profileFromJson(profileJson);
      if (replace) {
        await _userRepo.saveProfile(imported);
      } else {
        final existing = await _userRepo.getProfile();
        if (existing == null) {
          await _userRepo.saveProfile(imported);
        } else {
          existing.name = imported.name;
          existing.birthDate = imported.birthDate;
          existing.averageCycleLength = imported.averageCycleLength;
          existing.averagePeriodLength = imported.averagePeriodLength;
          existing.onboardingCompleted = imported.onboardingCompleted;
          existing.preferredPainMedication = imported.preferredPainMedication;
          existing.painMedicationLeadDays = imported.painMedicationLeadDays;
          existing.contraceptiveType = imported.contraceptiveType;
          existing.contraceptiveNotes = imported.contraceptiveNotes;
          existing.enabledLogSectionIds = imported.enabledLogSectionIds;
          await _userRepo.saveProfile(existing);
        }
      }
    }

    final prefs = decoded['logSectionPreferences'] as Map<String, dynamic>?;
    if (prefs != null) {
      final ids = (prefs['enabledSectionIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          LogSectionIds.defaultEnabled();
      await _userRepo.updateEnabledLogSections(ids);
    }

    final settings = decoded['settings'] as Map<String, dynamic>?;
    if (settings != null && settings.containsKey('darkMode')) {
      await _themeController.toggleTheme(settings['darkMode'] as bool? ?? false);
    }

    final cyclesJson = decoded['cycles'] as List<dynamic>? ?? [];
    for (final item in cyclesJson) {
      final cycle = _cycleFromJson(item as Map<String, dynamic>);
      if (replace) {
        await _cycleRepo.saveCycle(cycle);
      } else {
        final all = await _cycleRepo.getAllCycles();
        CycleRecord? existing;
        for (final c in all) {
          if (AppDateUtils.normalizeDate(c.startDate) ==
              AppDateUtils.normalizeDate(cycle.startDate)) {
            existing = c;
            break;
          }
        }
        if (existing != null) cycle.id = existing.id;
        await _cycleRepo.saveCycle(cycle);
      }
    }

    final logsJson = decoded['dailyLogs'] as List<dynamic>? ?? [];
    for (final item in logsJson) {
      final log = _logFromJson(item as Map<String, dynamic>);
      if (!replace) {
        final existing = await _logRepo.getLogForDate(log.date);
        if (existing != null) log.id = existing.id;
      }
      log.normalizeFields();
      await _logRepo.upsertLog(log);
    }
  }

  Map<String, dynamic> _profileToJson(UserProfile p) => {
        'name': p.name,
        'birthDate': p.birthDate.toIso8601String(),
        'averageCycleLength': p.averageCycleLength,
        'averagePeriodLength': p.averagePeriodLength,
        'onboardingCompleted': p.onboardingCompleted,
        'preferredPainMedication': p.preferredPainMedication,
        'painMedicationLeadDays': p.painMedicationLeadDays,
        'contraceptiveType': p.contraceptiveType.name,
        'contraceptiveNotes': p.contraceptiveNotes,
        'enabledLogSectionIds': p.enabledLogSectionIds,
      };

  UserProfile _profileFromJson(Map<String, dynamic> json) {
    return UserProfile()
      ..name = json['name'] as String? ?? ''
      ..birthDate = DateTime.parse(json['birthDate'] as String)
      ..averageCycleLength =
          (json['averageCycleLength'] as num?)?.toDouble() ?? 28
      ..averagePeriodLength =
          (json['averagePeriodLength'] as num?)?.toDouble() ?? 5
      ..onboardingCompleted = json['onboardingCompleted'] as bool? ?? false
      ..preferredPainMedication =
          json['preferredPainMedication'] as String? ?? ''
      ..painMedicationLeadDays = json['painMedicationLeadDays'] as int? ?? 1
      ..contraceptiveType = _enumFromName(
        ContraceptiveType.values,
        json['contraceptiveType'] as String?,
        ContraceptiveType.none,
      )
      ..contraceptiveNotes = json['contraceptiveNotes'] as String? ?? ''
      ..enabledLogSectionIds =
          (json['enabledLogSectionIds'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              LogSectionIds.defaultEnabled();
  }

  Map<String, dynamic> _cycleToJson(CycleRecord c) => {
        'startDate': c.startDate.toIso8601String(),
        'endDate': c.endDate?.toIso8601String(),
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
      };

  CycleRecord _cycleFromJson(Map<String, dynamic> json) {
    return CycleRecord()
      ..startDate = DateTime.parse(json['startDate'] as String)
      ..endDate = json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(json['updatedAt'] as String);
  }

  Map<String, dynamic> _logToJson(DailyLog log) => {
        'date': log.date.toIso8601String(),
        'bleeding': log.bleeding.name,
        'bleedingColor': log.bleedingColor.name,
        'pain': log.pain.name,
        'cramps': log.cramps,
        'discharge': log.discharge.name,
        'sexDrive': log.sexDrive.name,
        'mood': log.mood.name,
        'symptoms': log.symptoms,
        'sexualActivity': log.sexualActivity,
        'hadOrgasm': log.hadOrgasm,
        'hadSexualFantasies': log.hadSexualFantasies,
        'energy': log.energy.name,
        'hasPms': log.hasPms,
        'cravings': log.cravings,
        'digestion': log.digestion.name,
        'stool': log.stool.name,
        'sleepQualities': log.sleepQualities,
        'dailyNote': log.effectiveDailyNote,
        'exercise': log.exercise,
        'medications': log.medications,
      };

  DailyLog _logFromJson(Map<String, dynamic> json) {
    return DailyLog()
      ..date = DateTime.parse(json['date'] as String)
      ..bleeding = _enumFromName(
        BleedingLevel.values,
        json['bleeding'] as String?,
        BleedingLevel.none,
      )
      ..bleedingColor = _enumFromName(
        BleedingColor.values,
        json['bleedingColor'] as String?,
        BleedingColor.none,
      )
      ..pain = _enumFromName(
        PainLevel.values,
        json['pain'] as String?,
        PainLevel.none,
      )
      ..cramps = json['cramps'] as bool? ?? false
      ..discharge = _enumFromName(
        DischargeType.values,
        json['discharge'] as String?,
        DischargeType.none,
      )
      ..sexDrive = _enumFromName(
        SexDriveLevel.values,
        json['sexDrive'] as String?,
        SexDriveLevel.normal,
      )
      ..mood = _enumFromName(
        MoodType.values,
        json['mood'] as String?,
        MoodType.calm,
      )
      ..symptoms =
          (json['symptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              []
      ..sexualActivity = json['sexualActivity'] as bool? ?? false
      ..hadOrgasm = json['hadOrgasm'] as bool? ?? false
      ..hadSexualFantasies = json['hadSexualFantasies'] as bool? ?? false
      ..energy = _enumFromName(
        EnergyLevel.values,
        json['energy'] as String?,
        EnergyLevel.normal,
      )
      ..hasPms = json['hasPms'] as bool? ?? false
      ..cravings =
          (json['cravings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              []
      ..digestion = _enumFromName(
        DigestionSymptom.values,
        json['digestion'] as String?,
        DigestionSymptom.normal,
      )
      ..stool = _enumFromName(
        StoolType.values,
        json['stool'] as String?,
        StoolType.normal,
      )
      ..sleepQualities = (json['sleepQualities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          []
      ..dailyNote = json['dailyNote'] as String? ?? json['notes'] as String? ?? ''
      ..exercise = json['exercise'] as bool? ?? false
      ..medications = json['medications'] as String? ?? '';
  }

  T _enumFromName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    if (name == null) return fallback;
    return values.firstWhere((e) => e.name == name, orElse: () => fallback);
  }
}

import 'dart:convert';

import '../../../../core/db/app_database.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/medication_entity.dart';
import 'package:yelima/features/medications/domain/models/create_medication_model.dart';
import 'package:yelima/features/medications/domain/models/dosing_schedule_model.dart';
import 'package:yelima/features/medications/domain/models/medication_detail_model.dart';
import 'package:yelima/features/medications/domain/models/update_medication_model.dart';
import 'package:yelima/features/medications/domain/models/seeded_medication_model.dart';
import '../models/medication_model.dart';
import 'package:clock/clock.dart';
import '../../domain/dose_window.dart';

class MedicationMapper {
  /// Maps a Drift [Medication] model to a Domain [MedicationEntity].
  static MedicationEntity toEntity(Medication med) {
    return MedicationEntity(
      id: med.id,
      name: med.name,
      dosage: med.dosage,
      purpose: med.purpose ?? '',
      toBeTakenAt: med.toBeTakenAt ?? clock.now(),
      // Taken only counts on the day it was confirmed (MED-EC-11).
      taken: med.taken && DoseWindow.takenToday(med.takenOn, clock.now()),
    );
  }

  /// Maps a Drift [Medication] model to a [MedicationDetailModel].
  static MedicationDetailModel toDetailModel(Medication med) {
    return MedicationDetailModel(
      id: med.id,
      name: med.name,
      dosage: med.dosage,
      notes: med.notes,
      morning: decodeSchedule(med.morningJson),
      afternoon: decodeSchedule(med.afternoonJson),
      evening: decodeSchedule(med.eveningJson),
      createdAt: med.toBeTakenAt ?? clock.now(),
      updatedAt: med.toBeTakenAt ?? clock.now(),
    );
  }

  /// Converts a [CreateMedicationModel] into a list of local Drift [Medication] rows.
  static List<Medication> fromCreateModel(
    CreateMedicationModel data,
    String localId,
  ) {
    final mJson = encodeSchedule(data.morning);
    final aJson = encodeSchedule(data.afternoon);
    final eJson = encodeSchedule(data.evening);

    final medsToInsert = <Medication>[];

    void addIfPresent(DosingScheduleModel? schedule, String section) {
      if (schedule != null) {
        medsToInsert.add(
          Medication(
            id: localId,
            name: data.name,
            dosage: data.dosage,
            purpose: null,
            notes: data.notes,
            toBeTakenAt: DateTimeUtils.deriveTime(
              schedule.time.hour,
              schedule.time.minutes,
              schedule.time.timeDesignators,
            ),
            taken: false,
            section: section,
            morningJson: mJson,
            afternoonJson: aJson,
            eveningJson: eJson,
          ),
        );
      }
    }

    addIfPresent(data.morning, 'MORNING');
    addIfPresent(data.afternoon, 'AFTERNOON');
    addIfPresent(data.evening, 'EVENING');

    // No schedule means no rows and no alarm, never a made-up "due now" dose.
    return medsToInsert;
  }

  /// Converts an [UpdateMedicationModel] into a list of local Drift [Medication] rows,
  /// preserving existing taken statuses from the [targetMeds] base.
  static List<Medication> fromUpdateModel(
    UpdateMedicationModel data,
    String id,
    List<Medication> targetMeds,
  ) {
    if (targetMeds.isEmpty) return [];

    final base = targetMeds.first;
    final mJson = encodeSchedule(data.morning);
    final aJson = encodeSchedule(data.afternoon);
    final eJson = encodeSchedule(data.evening);

    final newMeds = <Medication>[];

    void addIfPresent(DosingScheduleModel? schedule, String section) {
      if (schedule != null) {
        final previous =
            targetMeds.where((m) => m.section == section).firstOrNull;

        newMeds.add(Medication(
          id: id,
          name: base.name,
          dosage: data.dosage ?? base.dosage,
          purpose: base.purpose,
          notes: data.notes ?? base.notes,
          toBeTakenAt: DateTimeUtils.deriveTime(
            schedule.time.hour,
            schedule.time.minutes,
            schedule.time.timeDesignators,
          ),
          taken: previous?.taken ?? false,
          takenOn: previous?.takenOn,
          section: section,
          morningJson: mJson,
          afternoonJson: aJson,
          eveningJson: eJson,
        ));
      }
    }

    addIfPresent(data.morning, 'MORNING');
    addIfPresent(data.afternoon, 'AFTERNOON');
    addIfPresent(data.evening, 'EVENING');

    if (newMeds.isEmpty) {
      newMeds.add(Medication(
        id: id,
        name: base.name,
        dosage: data.dosage ?? base.dosage,
        purpose: base.purpose,
        notes: data.notes ?? base.notes,
        toBeTakenAt: base.toBeTakenAt,
        taken: base.taken,
        section: 'MORNING',
        morningJson: mJson,
        afternoonJson: aJson,
        eveningJson: eJson,
      ));
    }

    return newMeds;
  }

  /// Helper to safely encode a [DosingScheduleModel] to JSON String.
  static String? encodeSchedule(DosingScheduleModel? model) {
    return model != null ? jsonEncode(model.toJson()) : null;
  }

  /// Helper to safely decode a JSON String into a [DosingScheduleModel].
  static DosingScheduleModel? decodeSchedule(String? jsonString) {
    if (jsonString == null) return null;
    try {
      return DosingScheduleModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }

  /// Converts a PreloadedMedications DataClass into a SeededMedicationModel
  static SeededMedicationModel toSeededMedication(PreloadedMedication c) {
    return SeededMedicationModel(
      id: c.id,
      name: c.name,
      possibleDosages: c.possibleDosagesJson != null
          ? List<String>.from(jsonDecode(c.possibleDosagesJson!))
          : [],
      createdAt: clock.now(),
      updatedAt: clock.now(),
    );
  }

  /// Merges a remote [MedicationModel] with an existing local Drift [Medication].
  ///
  /// The server's dose time wins when it sent one (rows with pending local edits
  /// are never merged). Without one, the local time stays, or a section default.
  static Medication mergeRemoteWithLocal(
    MedicationModel remote,
    Medication? existing,
    String section,
  ) {
    final derivedTime = remote.hasServerTime
        ? remote.toBeTakenAt
        : existing?.toBeTakenAt ?? _sectionDefault(section);

    return Medication(
      id: remote.id,
      name: remote.name,
      dosage: remote.dosage,
      purpose: existing?.purpose ?? remote.purpose,
      toBeTakenAt: derivedTime,
      taken: remote.taken,
      // The server's "taken" is for today.
      takenOn: remote.taken ? (existing?.takenOn ?? clock.now()) : null,
      section: section,
      notes: existing?.notes,
      morningJson: existing?.morningJson,
      afternoonJson: existing?.afternoonJson,
      eveningJson: existing?.eveningJson,
    );
  }

  /// Fallback dose time for a section when neither side knows one: 08:00, 13:00, 20:00.
  static DateTime _sectionDefault(String section) {
    final now = clock.now();
    final hour =
        switch (section) { 'AFTERNOON' => 13, 'EVENING' => 20, _ => 8 };
    return DateTime(now.year, now.month, now.day, hour);
  }
}

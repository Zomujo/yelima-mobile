import 'dart:convert';

import '../../../../core/db/app_database.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/medication_entity.dart';
import '../models/create_medication_model.dart';
import '../models/dosing_schedule_model.dart';
import '../models/medication_detail_model.dart';
import '../models/update_medication_model.dart';
import '../models/seeded_medication_model.dart';

class MedicationMapper {
  /// Maps a Drift [Medication] model to a Domain [MedicationEntity].
  static MedicationEntity toEntity(Medication med) {
    return MedicationEntity(
      id: med.id,
      name: med.name,
      dosage: med.dosage,
      purpose: med.purpose ?? '',
      toBeTakenAt: med.toBeTakenAt ?? DateTime.now(),
      taken: med.taken,
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
      createdAt: med.toBeTakenAt ?? DateTime.now(),
      updatedAt: med.toBeTakenAt ?? DateTime.now(),
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

    if (medsToInsert.isEmpty) {
      medsToInsert.add(Medication(
        id: localId,
        name: data.name,
        dosage: data.dosage,
        notes: data.notes,
        toBeTakenAt: DateTime.now(),
        taken: false,
        section: 'MORNING',
        morningJson: mJson,
        afternoonJson: aJson,
        eveningJson: eJson,
      ));
    }

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
        final taken =
            targetMeds.where((m) => m.section == section).firstOrNull?.taken ??
                false;

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
          taken: taken,
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

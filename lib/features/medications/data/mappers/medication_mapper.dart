import 'dart:convert';

import 'package:clock/clock.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/dose_window.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_form.dart';
import '../../domain/entities/medication_section.dart';
import '../../domain/models/create_medication_model.dart';
import '../../domain/models/dosing_schedule_model.dart';
import '../../domain/models/medication_detail_model.dart';
import '../../domain/models/seeded_medication_model.dart';
import '../../domain/models/update_medication_model.dart';
import '../models/medication_model.dart';

/// Converts medications between local rows, server models and domain values.
abstract final class MedicationMapper {
  /// A local row as shown in today's list.
  static MedicationEntity toEntity(Medication med) => MedicationEntity(
        id: med.id,
        name: med.name,
        dosage: med.dosage,
        purpose: med.purpose ?? '',
        toBeTakenAt: med.toBeTakenAt ?? clock.now(),
        // Taken only counts on the day it was confirmed (MED-EC-11).
        taken: med.taken && DoseWindow.takenToday(med.takenOn, clock.now()),
      );

  /// A local row as medication details.
  static MedicationDetailModel toDetailModel(Medication med) =>
      MedicationDetailModel(
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

  /// The server request to create [form].
  static CreateMedicationModel toCreateModel(MedicationForm form) =>
      CreateMedicationModel(
        name: form.name.trim(),
        dosage: form.dosage.trim(),
        notes: form.notes.trim().isEmpty ? null : form.notes.trim(),
        morning: _schedule(form, MedicationSection.morning),
        afternoon: _schedule(form, MedicationSection.afternoon),
        evening: _schedule(form, MedicationSection.evening),
      );

  /// The server request to update a medication to [form].
  static UpdateMedicationModel toUpdateModel(MedicationForm form) =>
      UpdateMedicationModel(
        dosage: form.dosage.trim(),
        notes: form.notes.trim(),
        morning: _schedule(form, MedicationSection.morning),
        afternoon: _schedule(form, MedicationSection.afternoon),
        evening: _schedule(form, MedicationSection.evening),
      );

  /// One local row per scheduled section of [form].
  ///
  /// Rows in [previous] keep their name, purpose and each section's taken state;
  /// a newly added section starts untaken. No schedule means no rows and no alarm.
  static List<Medication> rowsFor(String id, MedicationForm form,
      {List<Medication> previous = const []}) {
    final base = previous.firstOrNull;
    final json = {
      for (final s in MedicationSection.values)
        s: encodeSchedule(_schedule(form, s)),
    };
    final now = clock.now();
    final notes = form.notes.trim();
    Medication row(MedicationSection section, DoseSchedule dose) {
      final before =
          previous.where((m) => m.section == section.key).firstOrNull;
      return Medication(
        id: id,
        name: base?.name ?? form.name.trim(),
        dosage: form.dosage.trim(),
        purpose: base?.purpose,
        notes: notes.isEmpty ? null : notes,
        toBeTakenAt:
            DateTime(now.year, now.month, now.day, dose.hour, dose.minute),
        taken: before?.taken ?? false,
        takenOn: before?.takenOn,
        section: section.key,
        morningJson: json[MedicationSection.morning],
        afternoonJson: json[MedicationSection.afternoon],
        eveningJson: json[MedicationSection.evening],
      );
    }

    return [for (final e in form.doses.entries) row(e.key, e.value)];
  }

  /// A schedule as stored in a local row, or null.
  static String? encodeSchedule(DosingScheduleModel? model) =>
      model == null ? null : jsonEncode(model.toJson());

  /// A stored schedule, or null if it is missing or corrupt.
  static DosingScheduleModel? decodeSchedule(String? json) {
    if (json == null) return null;
    try {
      return DosingScheduleModel.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  /// A cached preloaded medication for the search field.
  static SeededMedicationModel toSeededMedication(PreloadedMedication c) =>
      SeededMedicationModel(
        id: c.id,
        name: c.name,
        possibleDosages: c.possibleDosagesJson == null
            ? const []
            : List<String>.from(jsonDecode(c.possibleDosagesJson!)),
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );

  /// A server medication merged into the local row for [section].
  ///
  /// The server's dose time wins when it sent one (rows with pending local edits
  /// are never merged). Without one, the local time stays, or a section default.
  static Medication mergeRemoteWithLocal(
      MedicationModel remote, Medication? existing, MedicationSection section) {
    final now = clock.now();
    return Medication(
      id: remote.id,
      name: remote.name,
      dosage: remote.dosage,
      purpose: existing?.purpose ?? remote.purpose,
      toBeTakenAt: remote.hasServerTime
          ? remote.toBeTakenAt
          : existing?.toBeTakenAt ??
              DateTime(now.year, now.month, now.day, section.defaultHour),
      taken: remote.taken,
      // The server's "taken" is for today.
      takenOn: remote.taken ? (existing?.takenOn ?? now) : null,
      section: section.key,
      notes: existing?.notes,
      morningJson: existing?.morningJson,
      afternoonJson: existing?.afternoonJson,
      eveningJson: existing?.eveningJson,
    );
  }

  static DosingScheduleModel? _schedule(
      MedicationForm form, MedicationSection section) {
    final dose = form.doses[section];
    return dose == null ? null : DosingScheduleModel.fromDose(dose, form.unit);
  }
}

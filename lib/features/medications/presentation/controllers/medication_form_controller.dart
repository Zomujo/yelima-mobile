import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/medication_form.dart';
import '../../domain/entities/medication_section.dart';
import '../../domain/models/medication_detail_model.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../medications_providers.dart';
import '../states/medication_form_state.dart';

/// The dosage, notes, unit and schedule fields shared by the add and edit forms.
mixin MedicationFormController {
  final dosageController = TextEditingController();
  final notesController = TextEditingController();
  @protected
  late MedicationRepository repository;
  bool _disposed = false;

  /// Units a dose can be measured in.
  static const units = [
    'tablet',
    'capsule',
    'ml',
    'drops',
    'mg',
    'application'
  ];

  /// The form part of the state.
  MedicationFormState get fields;

  /// Replaces the form part of the state.
  set fields(MedicationFormState value);

  /// The medication's name as entered or loaded.
  String get name;

  /// Whether the screen has closed, so late answers are dropped.
  @protected
  bool get disposed => _disposed;

  /// Wires the text fields and the repository; call first in build.
  @protected
  void startForm(Ref ref) {
    // Read, not watched: the text fields live exactly as long as the screen.
    repository = ref.read(medicationRepositoryProvider);
    dosageController.addListener(markChanged);
    notesController.addListener(markChanged);
    ref.onDispose(() {
      _disposed = true;
      dosageController.dispose();
      notesController.dispose();
    });
  }

  /// Records that the user changed something.
  void markChanged() {
    if (fields.hasChanges) return;
    fields = fields.copyWith(hasChanges: true);
  }

  /// Picks the unit.
  void setUnit(String value) =>
      fields = fields.copyWith(unit: value, hasChanges: true);

  /// Changes one section's dose.
  void setSlot(MedicationSection section,
      {bool? enabled, TimeOfDay? time, int? quantity}) {
    final slot = fields.slots[section]!;
    fields = fields.copyWith(hasChanges: true, slots: {
      ...fields.slots,
      section: (
        enabled: enabled ?? slot.enabled,
        time: time ?? slot.time,
        quantity: quantity ?? slot.quantity
      ),
    });
  }

  /// Fills the fields from saved [data], without counting as a change.
  void load(MedicationDetailModel data) {
    dosageController.text = data.dosage;
    notesController.text = data.notes ?? '';
    final saved = {
      MedicationSection.morning: data.morning,
      MedicationSection.afternoon: data.afternoon,
      MedicationSection.evening: data.evening,
    };
    fields = fields.copyWith(
      hasChanges: false,
      unit: saved.values.nonNulls.firstOrNull?.quantity.unit ?? 'tablet',
      slots: {
        for (final MapEntry(key: s, value: schedule) in saved.entries)
          s: schedule == null
              ? fields.slots[s]!
              : (
                  enabled: true,
                  time: TimeOfDay(
                      hour: schedule.time.hour24,
                      minute: schedule.time.minutes),
                  quantity: schedule.quantity.value
                ),
      },
    );
  }

  /// The form as entered.
  MedicationForm get form => MedicationForm(
        name: name,
        dosage: dosageController.text,
        notes: notesController.text,
        unit: fields.unit,
        doses: {
          for (final MapEntry(key: s, value: slot) in fields.slots.entries)
            if (slot.enabled)
              s: DoseSchedule(
                  hour: slot.time.hour,
                  minute: slot.time.minute,
                  quantity: slot.quantity),
        },
      );

  /// Saves the form; returns the failure, or null.
  Future<AppFailure?> save() async {
    fields = fields.copyWith(isSaving: true);
    final failure = await persist();
    if (_disposed) return failure;
    fields = fields.copyWith(
        isSaving: false, hasChanges: failure != null && fields.hasChanges);
    return failure;
  }

  /// Stores [form]; returns the failure, or null.
  @protected
  Future<AppFailure?> persist();
}

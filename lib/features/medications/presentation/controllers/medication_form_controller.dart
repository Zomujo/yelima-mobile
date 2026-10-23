import 'package:flutter/material.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../domain/entities/medication_form.dart';
import '../../domain/entities/medication_section.dart';
import '../../domain/models/medication_detail_model.dart';

/// One section's dose in the form: on or off, its time and how many units.
typedef DoseSlot = ({bool enabled, TimeOfDay time, int quantity});

/// The dosage, notes, unit and schedule fields shared by the add and edit forms.
abstract class MedicationFormController extends ChangeNotifier
    with SafeNotifier {
  MedicationFormController() {
    dosageController.addListener(markChanged);
    notesController.addListener(markChanged);
  }

  final dosageController = TextEditingController();
  final notesController = TextEditingController();

  /// Units a dose can be measured in.
  static const units = ['tablet', 'capsule', 'ml', 'drops', 'mg', 'application'];

  String unit = 'tablet';
  bool hasChanges = false;
  bool isSaving = false;
  Map<MedicationSection, DoseSlot> slots = {
    for (final s in MedicationSection.values)
      s: (
        enabled: false,
        time: TimeOfDay(hour: s.defaultHour, minute: 0),
        quantity: 1
      ),
  };

  /// The medication's name as entered or loaded.
  String get name;

  /// Records that the user changed something.
  void markChanged() {
    if (hasChanges) return;
    hasChanges = true;
    notifyListeners();
  }

  /// Picks the unit.
  void setUnit(String value) {
    unit = value;
    hasChanges = true;
    notifyListeners();
  }

  /// Changes one section's dose.
  void setSlot(MedicationSection section,
      {bool? enabled, TimeOfDay? time, int? quantity}) {
    final slot = slots[section]!;
    slots = {
      ...slots,
      section: (
        enabled: enabled ?? slot.enabled,
        time: time ?? slot.time,
        quantity: quantity ?? slot.quantity
      ),
    };
    hasChanges = true;
    notifyListeners();
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
    unit = saved.values.nonNulls.firstOrNull?.quantity.unit ?? 'tablet';
    slots = {
      for (final MapEntry(key: s, value: schedule) in saved.entries)
        s: schedule == null
            ? slots[s]!
            : (
                enabled: true,
                time: TimeOfDay(
                    hour: schedule.time.hour24, minute: schedule.time.minutes),
                quantity: schedule.quantity.value
              ),
    };
    hasChanges = false;
    notifyListeners();
  }

  /// The form as entered.
  MedicationForm get form => MedicationForm(
        name: name,
        dosage: dosageController.text,
        notes: notesController.text,
        unit: unit,
        doses: {
          for (final MapEntry(key: s, value: slot) in slots.entries)
            if (slot.enabled)
              s: DoseSchedule(
                  hour: slot.time.hour,
                  minute: slot.time.minute,
                  quantity: slot.quantity),
        },
      );

  /// Saves the form; returns the failure, or null.
  Future<AppFailure?> save() async {
    isSaving = true;
    notifyListeners();
    final failure = await persist();
    isSaving = false;
    if (failure == null) hasChanges = false;
    notifyListeners();
    return failure;
  }

  /// Stores [form]; returns the failure, or null.
  @protected
  Future<AppFailure?> persist();

  @override
  void dispose() {
    dosageController.dispose();
    notesController.dispose();
    super.dispose();
  }
}

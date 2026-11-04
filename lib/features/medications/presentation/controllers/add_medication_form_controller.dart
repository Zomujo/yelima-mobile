import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/models/seeded_medication_model.dart';
import '../states/medication_form_state.dart';
import 'medication_form_controller.dart';

part 'add_medication_form_controller.g.dart';

/// The add-medication form: a name (searched or typed) plus the shared fields.
@riverpod
class AddMedicationFormController extends _$AddMedicationFormController
    with MedicationFormController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  AddMedicationState build() {
    startForm(ref);
    nameController.addListener(markChanged);
    ref.onDispose(nameController.dispose);
    return AddMedicationState(form: MedicationFormState.blank());
  }

  @override
  MedicationFormState get fields => state.form;

  @override
  set fields(MedicationFormState value) => state = state.copyWith(form: value);

  @override
  String get name => nameController.text;

  /// Known medications matching [query].
  Future<List<SeededMedicationModel>> search(String query) =>
      repository.searchPreloaded(query);

  /// Picks a preloaded medication, or clears the pick when the name is edited.
  void pick(SeededMedicationModel? med) {
    state = state.copyWith(picked: med);
    if (med != null) nameController.text = med.name;
    dosageController.clear();
  }

  /// Sets the dosage from a suggestion chip.
  void selectDosage(String? dosage) => dosageController.text = dosage ?? '';

  @override
  Future<AppFailure?> save() async {
    if (!formKey.currentState!.validate()) return const CancelledFailure();
    return super.save();
  }

  @override
  Future<AppFailure?> persist() async =>
      (await repository.createMedication(form)).fold((f) => f, (_) => null);
}

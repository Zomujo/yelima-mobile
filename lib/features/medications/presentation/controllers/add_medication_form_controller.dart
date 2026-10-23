import 'package:flutter/material.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/models/seeded_medication_model.dart';
import '../../domain/repositories/medication_repository.dart';
import 'medication_form_controller.dart';

/// The add-medication form: a name (searched or typed) plus the shared fields.
class AddMedicationFormController extends MedicationFormController {
  AddMedicationFormController({required MedicationRepository repository})
      : _repository = repository {
    nameController.addListener(markChanged);
  }

  final MedicationRepository _repository;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  /// The preloaded medication picked from search, which suggests dosages.
  SeededMedicationModel? picked;

  @override
  String get name => nameController.text;

  /// Known medications matching [query].
  Future<List<SeededMedicationModel>> search(String query) =>
      _repository.searchPreloaded(query);

  /// Picks a preloaded medication, or clears the pick when the name is edited.
  void pick(SeededMedicationModel? med) {
    picked = med;
    if (med != null) nameController.text = med.name;
    dosageController.clear();
    notifyListeners();
  }

  /// Sets the dosage from a suggestion chip.
  void selectDosage(String? dosage) {
    dosageController.text = dosage ?? '';
    notifyListeners();
  }

  @override
  Future<AppFailure?> save() async {
    if (!formKey.currentState!.validate()) return const CancelledFailure();
    return super.save();
  }

  @override
  Future<AppFailure?> persist() async =>
      (await _repository.createMedication(form)).fold((f) => f, (_) => null);

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}

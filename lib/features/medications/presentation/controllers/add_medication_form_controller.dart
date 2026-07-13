import 'package:flutter/material.dart';
import '../../data/models/seeded_medication_model.dart';
import '../../domain/entities/medicine_form_data.dart';
import '../../domain/usecases/create_medication_usecase.dart';
import '../states/add_medication_form_state.dart';
import '../../../../core/utils/safe_notifier.dart';

class AddMedicationFormController extends ChangeNotifier with SafeNotifier {
  final CreateMedicationUseCase createMedicationUseCase;

  AddMedicationFormController({required this.createMedicationUseCase});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  /// The Autocomplete widget controls its own TextEditingController. We keep a
  /// reference so we can sync it with [nameController] on first binding.
  TextEditingController? boundSearchController;

  AddMedicationFormState state = const AddMedicationFormState();

  // ─── State mutations ──────────────────────────────────────────────────────

  void updateMorning(bool has, [TimeOfDay? time, int? quantity]) {
    state = state.copyWith(
      hasMorning: has,
      morningTime: time ?? state.morningTime,
      morningQuantity: quantity ?? state.morningQuantity,
    );
    notifyListeners();
  }

  void updateAfternoon(bool has, [TimeOfDay? time, int? quantity]) {
    state = state.copyWith(
      hasAfternoon: has,
      afternoonTime: time ?? state.afternoonTime,
      afternoonQuantity: quantity ?? state.afternoonQuantity,
    );
    notifyListeners();
  }

  void updateEvening(bool has, [TimeOfDay? time, int? quantity]) {
    state = state.copyWith(
      hasEvening: has,
      eveningTime: time ?? state.eveningTime,
      eveningQuantity: quantity ?? state.eveningQuantity,
    );
    notifyListeners();
  }

  void updateSelectedPreloadedMedication(SeededMedicationModel? med) {
    state = state.copyWith(selectedPreloadedMedication: med);
    if (med != null) {
      nameController.text = med.name;
    }
    dosageController.clear();
    notifyListeners();
  }

  void updateUnit(String unit) {
    state = state.copyWith(selectedUnit: unit);
    notifyListeners();
  }

  void selectDosage(String dosage) {
    dosageController.text = dosage;
    notifyListeners();
  }

  void clearDosage() {
    dosageController.clear();
    notifyListeners();
  }

  // ─── Derived ─────────────────────────────────────────────────────────────

  bool hasUnsavedChanges() {
    return nameController.text.trim().isNotEmpty ||
        dosageController.text.trim().isNotEmpty ||
        notesController.text.trim().isNotEmpty ||
        state.hasMorning ||
        state.hasAfternoon ||
        state.hasEvening;
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<String?> save() async {
    if (!formKey.currentState!.validate()) return 'validation_failed';

    final formData = MedicineFormData(
      dosage: dosageController.text.trim(),
      notes: notesController.text.trim(),
      unit: state.selectedUnit,
      morning: state.hasMorning
          ? DoseSchedule(
              hour: state.morningTime.hourOfPeriod,
              minute: state.morningTime.minute,
              period: state.morningTime.period == DayPeriod.am ? 'AM' : 'PM',
              quantity: state.morningQuantity,
            )
          : null,
      afternoon: state.hasAfternoon
          ? DoseSchedule(
              hour: state.afternoonTime.hourOfPeriod,
              minute: state.afternoonTime.minute,
              period: state.afternoonTime.period == DayPeriod.am ? 'AM' : 'PM',
              quantity: state.afternoonQuantity,
            )
          : null,
      evening: state.hasEvening
          ? DoseSchedule(
              hour: state.eveningTime.hourOfPeriod,
              minute: state.eveningTime.minute,
              period: state.eveningTime.period == DayPeriod.am ? 'AM' : 'PM',
              quantity: state.eveningQuantity,
            )
          : null,
    );

    final result =
        await createMedicationUseCase(formData, nameController.text.trim());
    return result.fold((error) => error, (_) => null);
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    notesController.dispose();
    super.dispose();
  }
}

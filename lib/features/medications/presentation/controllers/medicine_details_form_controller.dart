import 'package:flutter/material.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../data/models/medication_detail_model.dart';
import '../../domain/entities/medicine_form_data.dart';
import '../../domain/usecases/update_medication_usecase.dart';
import 'all_medicines_controller.dart';
import '../states/medicine_details_form_state.dart';

class MedicineDetailsFormController extends ChangeNotifier with SafeNotifier {
  final AllMedicinesController allMedicinesController;
  final UpdateMedicationUseCase updateMedicationUseCase;
  String medicationId;

  MedicineDetailsFormController({
    required this.allMedicinesController,
    required this.updateMedicationUseCase,
    required this.medicationId,
  }) {
    nameController.addListener(_markChanged);
    dosageController.addListener(_markChanged);
    notesController.addListener(_markChanged);
  }

  MedicineDetailsFormState state = const MedicineDetailsFormState();

  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final notesController = TextEditingController();

  // ─── Derived data getters (no business logic in UI) ──────────────────────

  String get titleName {
    final detailName = allMedicinesController.detailState.data?.name;
    final fallback = _fallbackMedication;
    return detailName ?? fallback?.name ?? 'Loading...';
  }

  String get titleDosage {
    final detailDosage = allMedicinesController.detailState.data?.dosage;
    final fallback = _fallbackMedication;
    return detailDosage ?? fallback?.dosage ?? '';
  }

  MedicationDetailModel? get medicationData {
    final detail = allMedicinesController.detailState.data;
    if (detail != null) return detail;

    final fallback = _fallbackMedication;
    if (fallback != null) {
      return MedicationDetailModel(
        id: fallback.id,
        name: fallback.name,
        dosage: fallback.dosage,
        notes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }

  bool get isLoadingData {
    return allMedicinesController.detailState.isLoading &&
        _fallbackMedication == null;
  }

  String? get dataError => allMedicinesController.detailState.error;

  dynamic get _fallbackMedication => allMedicinesController.listState.data?.rows
      .where((m) => m.id == medicationId)
      .firstOrNull;

  // ─── State mutations ──────────────────────────────────────────────────────

  void _markChanged() {
    state = state.copyWith(hasUnsavedChanges: true);
    notifyListeners();
  }

  void toggleEditing(bool value) {
    state = state.copyWith(
      isEditing: value,
      hasUnsavedChanges: value ? state.hasUnsavedChanges : false,
    );
    notifyListeners();
  }

  void setUnit(String unit) {
    state = state.copyWith(selectedUnit: unit, hasUnsavedChanges: true);
    notifyListeners();
  }

  void updateMorning(bool has, [TimeOfDay? time, int? quantity]) {
    state = state.copyWith(
      hasMorning: has,
      morningTime: time ?? state.morningTime,
      morningQuantity: quantity ?? state.morningQuantity,
      hasUnsavedChanges: true,
    );
    notifyListeners();
  }

  void updateAfternoon(bool has, [TimeOfDay? time, int? quantity]) {
    state = state.copyWith(
      hasAfternoon: has,
      afternoonTime: time ?? state.afternoonTime,
      afternoonQuantity: quantity ?? state.afternoonQuantity,
      hasUnsavedChanges: true,
    );
    notifyListeners();
  }

  void updateEvening(bool has, [TimeOfDay? time, int? quantity]) {
    state = state.copyWith(
      hasEvening: has,
      eveningTime: time ?? state.eveningTime,
      eveningQuantity: quantity ?? state.eveningQuantity,
      hasUnsavedChanges: true,
    );
    notifyListeners();
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  void init() {
    Future.microtask(() {
      allMedicinesController.fetchMedicationHistory(medicationId);
      allMedicinesController.fetchMedicationDetails(medicationId).then((_) {
        final data = allMedicinesController.detailState.data;
        if (data == null) return;

        nameController.text = data.name;
        dosageController.text = data.dosage;
        notesController.text = data.notes ?? '';

        state = MedicineDetailsFormState(
          selectedUnit: data.morning?.quantity.unit ?? 'tablet',
          hasMorning: data.morning != null,
          morningTime: data.morning != null
              ? TimeOfDay(
                  hour: _to24Hour(data.morning!.time.hour, data.morning!.time.timeDesignators),
                  minute: data.morning!.time.minutes)
              : const TimeOfDay(hour: 8, minute: 0),
          morningQuantity: data.morning?.quantity.value ?? 1,
          hasAfternoon: data.afternoon != null,
          afternoonTime: data.afternoon != null
              ? TimeOfDay(
                  hour: _to24Hour(data.afternoon!.time.hour, data.afternoon!.time.timeDesignators),
                  minute: data.afternoon!.time.minutes)
              : const TimeOfDay(hour: 13, minute: 0),
          afternoonQuantity: data.afternoon?.quantity.value ?? 1,
          hasEvening: data.evening != null,
          eveningTime: data.evening != null
              ? TimeOfDay(
                  hour: _to24Hour(data.evening!.time.hour, data.evening!.time.timeDesignators),
                  minute: data.evening!.time.minutes)
              : const TimeOfDay(hour: 20, minute: 0),
          eveningQuantity: data.evening?.quantity.value ?? 1,
        );
        notifyListeners();
      });
    });
  }

  int _to24Hour(int hour, String designator) {
    if (designator.toUpperCase() == 'PM' && hour < 12) return hour + 12;
    if (designator.toUpperCase() == 'AM' && hour == 12) return 0;
    return hour;
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<String?> save() async {
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

    final result = await updateMedicationUseCase(medicationId, formData);
    return result.fold(
      (error) => error,
      (_) {
        toggleEditing(false);
        allMedicinesController.fetchAllMedicines(forceRefresh: true);
        allMedicinesController.fetchMedicationDetails(medicationId);
        return null;
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    notesController.dispose();
    super.dispose();
  }
}

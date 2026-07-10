import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/seeded_medication_model.dart';

part 'add_medication_form_state.freezed.dart';

@freezed
abstract class AddMedicationFormState with _$AddMedicationFormState {
  const factory AddMedicationFormState({
    @Default('tablet') String selectedUnit,
    SeededMedicationModel? selectedPreloadedMedication,
    @Default(false) bool hasMorning,
    @Default(TimeOfDay(hour: 8, minute: 0)) TimeOfDay morningTime,
    @Default(1) int morningQuantity,
    @Default(false) bool hasAfternoon,
    @Default(TimeOfDay(hour: 13, minute: 0)) TimeOfDay afternoonTime,
    @Default(1) int afternoonQuantity,
    @Default(false) bool hasEvening,
    @Default(TimeOfDay(hour: 20, minute: 0)) TimeOfDay eveningTime,
    @Default(1) int eveningQuantity,
  }) = _AddMedicationFormState;
}

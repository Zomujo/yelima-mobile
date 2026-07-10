import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'medicine_details_form_state.freezed.dart';

@freezed
abstract class MedicineDetailsFormState with _$MedicineDetailsFormState {
  const factory MedicineDetailsFormState({
    @Default(false) bool isEditing,
    @Default(false) bool hasUnsavedChanges,
    @Default('tablet') String selectedUnit,
    @Default(false) bool hasMorning,
    @Default(TimeOfDay(hour: 8, minute: 0)) TimeOfDay morningTime,
    @Default(1) int morningQuantity,
    @Default(false) bool hasAfternoon,
    @Default(TimeOfDay(hour: 13, minute: 0)) TimeOfDay afternoonTime,
    @Default(1) int afternoonQuantity,
    @Default(false) bool hasEvening,
    @Default(TimeOfDay(hour: 20, minute: 0)) TimeOfDay eveningTime,
    @Default(1) int eveningQuantity,
  }) = _MedicineDetailsFormState;
}

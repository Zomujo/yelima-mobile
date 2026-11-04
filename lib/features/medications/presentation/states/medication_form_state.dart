import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../../domain/entities/medication_section.dart';
import '../../domain/models/medication_detail_model.dart';
import '../../domain/models/seeded_medication_model.dart';

part 'medication_form_state.freezed.dart';

/// One section's dose in the form: on or off, its time and how many units.
typedef DoseSlot = ({bool enabled, TimeOfDay time, int quantity});

/// The unit, schedule and save status shared by the add and edit forms.
@freezed
abstract class MedicationFormState with _$MedicationFormState {
  const factory MedicationFormState({
    @Default('tablet') String unit,
    @Default(false) bool hasChanges,
    @Default(false) bool isSaving,
    required Map<MedicationSection, DoseSlot> slots,
  }) = _MedicationFormState;

  /// Every section off, at its usual hour, one unit.
  factory MedicationFormState.blank() => MedicationFormState(slots: {
        for (final s in MedicationSection.values)
          s: (
            enabled: false,
            time: TimeOfDay(hour: s.defaultHour, minute: 0),
            quantity: 1
          ),
      });
}

/// The add-medication form: the shared fields and the medication picked from search.
@freezed
abstract class AddMedicationState with _$AddMedicationState {
  const factory AddMedicationState({
    required MedicationFormState form,

    /// The preloaded medication picked from search, which suggests dosages.
    SeededMedicationModel? picked,
  }) = _AddMedicationState;
}

/// One medication's details screen: its data, dose history and edit form.
@freezed
abstract class MedicineDetailsState with _$MedicineDetailsState {
  const MedicineDetailsState._();

  const factory MedicineDetailsState({
    required MedicationFormState form,
    MedicationDetailModel? detail,
    AppFailure? error,
    @Default(true) bool isLoading,
    @Default(false) bool isEditing,
    MedicationHistoryEntity? history,
    AppFailure? historyError,
  }) = _MedicineDetailsState;

  /// The medication's name, or empty until it loads.
  String get name => detail?.name ?? '';
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_section.dart';

part 'medications_state.freezed.dart';

/// The medications tab: adherence, counts and today's doses per section.
@freezed
abstract class MedicationsState with _$MedicationsState {
  const factory MedicationsState({
    MedicationAdherence? adherence,
    MedicationCount? counts,
    @Default({}) Map<MedicationSection, List<MedicationEntity>> doses,
    @Default({}) Set<String> confirmingMedicationIds,
    @Default(MedicationSection.morning) MedicationSection section,
  }) = _MedicationsState;
}

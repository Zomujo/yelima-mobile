import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';

part 'medications_state.freezed.dart';

@freezed
abstract class MedicationsState with _$MedicationsState {
  const factory MedicationsState({
    MedicationAdherence? adherence,
    MedicationCount? counts,
    @Default({}) Map<String, List<MedicationEntity>> medicationsBySection,
    @Default(false) bool isAdherenceLoading,
    @Default(false) bool isCountsLoading,
    @Default({}) Map<String, bool> sectionLoadingStatus,
    String? adherenceError,
    String? countsError,
    @Default({}) Map<String, String> sectionErrors,
    String? confirmingMedicationId,
    @Default(0) int selectedTabIndex,
  }) = _MedicationsState;
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/reading_form.dart';
import '../../domain/entities/vital_history_entity.dart';

part 'reading_logging_state.freezed.dart';

/// The log-a-reading form and the saved readings.
@freezed
abstract class ReadingLoggingState with _$ReadingLoggingState {
  const factory ReadingLoggingState({
    @Default(VitalKind.bloodPressure) VitalKind kind,
    @Default('fasting') String vitalSubType,
    @Default(120) int systolic,
    @Default(80) int diastolic,
    @Default(5.5) double sugarLevel,
    required DateTime selectedDate,
    @Default(false) bool hasChanged,
    @Default(false) bool isSaving,
    @Default(true) bool isInitializing,

    /// Every reading on the phone, newest first; null until loaded.
    List<VitalHistoryEntity>? history,
  }) = _ReadingLoggingState;
}

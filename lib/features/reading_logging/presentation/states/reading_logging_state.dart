import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_logging_state.freezed.dart';

@freezed
abstract class ReadingLoggingState with _$ReadingLoggingState {
  const factory ReadingLoggingState({
    @Default(0) int selectedTypeIndex,
    @Default(120) int systolic,
    @Default(80) int diastolic,
    @Default(5.5) double sugarLevel,
    required DateTime selectedDate,
    @Default(false) bool hasChanged,
    @Default(false) bool isSaving,
  }) = _ReadingLoggingState;
}

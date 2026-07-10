import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_state.freezed.dart';

@freezed
abstract class ProgressState<T> with _$ProgressState<T> {
  const factory ProgressState({
    T? data,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isSyncFailed,
    DateTime? lastUpdated,
  }) = _ProgressState<T>;
}

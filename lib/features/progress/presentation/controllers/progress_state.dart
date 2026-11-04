import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/vital_trends.dart';

part 'progress_state.freezed.dart';

/// One chart's data, and whether it is loading or failed.
@freezed
abstract class ProgressState<T> with _$ProgressState<T> {
  const factory ProgressState({
    T? data,
    @Default(false) bool isLoading,
    AppFailure? error,
  }) = _ProgressState<T>;
}

/// Both progress charts.
@freezed
abstract class ProgressCharts with _$ProgressCharts {
  const factory ProgressCharts({
    @Default(ProgressState(isLoading: true))
    ProgressState<BPTrend> bpTrendState,
    @Default(ProgressState(isLoading: true))
    ProgressState<VitalTrend> glucoseTrendState,
  }) = _ProgressCharts;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/vital_history_entity.dart';

part 'home_metrics_state.freezed.dart';

@freezed
abstract class HomeMetricsState with _$HomeMetricsState {
  const factory HomeMetricsState({
    @Default(false) bool isLoading,
    @Default(null) String? errorMessage,
    @Default(null) HomeMetricsEntity? metrics,
  }) = _HomeMetricsState;

  const HomeMetricsState._();

  factory HomeMetricsState.initial() => const HomeMetricsState();
}

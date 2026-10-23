import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../vitals/domain/entities/vital_history_entity.dart';

part 'home_metrics_state.freezed.dart';

/// The home cards: newest readings and this week's adherence.
@freezed
abstract class HomeMetricsState with _$HomeMetricsState {
  const factory HomeMetricsState({
    /// Null until the phone's readings have loaded.
    LatestVitals? vitals,

    /// Fraction of doses taken this week (0–1), or null if unknown.
    double? adherence,
  }) = _HomeMetricsState;
}

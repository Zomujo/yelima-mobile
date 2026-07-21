import 'package:flutter/foundation.dart';
import '../../domain/entities/vital_history_entity.dart';
import '../../domain/repositories/home_metrics_repository.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../states/home_metrics_state.dart';

class HomeMetricsController extends ChangeNotifier with SafeNotifier {
  final HomeMetricsRepository _repository;

  HomeMetricsController({required HomeMetricsRepository repository})
      : _repository = repository;

  HomeMetricsState _state = HomeMetricsState.initial();
  HomeMetricsState get state => _state;

  HomeMetricsEntity? get metrics => _state.metrics;

  set state(HomeMetricsState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  /// Fetches the latest home metrics initially from the cache, followed by a network refresh.
  Future<void> fetchMetrics() async {
    if (_state.metrics == null) {
      state = state.copyWith(isLoading: true);

      final cachedResult = await _repository.getCachedHomeMetrics();
      cachedResult.fold((error) => null, (data) {
        if (data.bloodPressure != null ||
            data.bloodGlucose != null ||
            data.adherenceRate != null) {
          state = state.copyWith(metrics: data, isLoading: false);
        }
      });
    }

    if (_state.metrics == null) {
      state = state.copyWith(isLoading: true);
    }

    final result = await _repository.getHomeMetrics();

    result.fold(
      (error) {
        state = state.copyWith(errorMessage: error, isLoading: false);
      },
      (data) {
        state =
            state.copyWith(metrics: data, errorMessage: null, isLoading: false);
      },
    );
  }
}

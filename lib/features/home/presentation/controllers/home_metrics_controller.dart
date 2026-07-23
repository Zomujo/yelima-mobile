import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/db/app_database.dart';
import '../../domain/entities/vital_history_entity.dart';
import '../../domain/repositories/home_metrics_repository.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../states/home_metrics_state.dart';

class HomeMetricsController extends ChangeNotifier with SafeNotifier {
  final HomeMetricsRepository _repository;
  StreamSubscription? _adherenceSub;

  HomeMetricsController({required HomeMetricsRepository repository})
      : _repository = repository {
    _initStream();
  }

  void _initStream() {
    if (GetIt.instance.isRegistered<AppDatabase>()) {
      _adherenceSub = GetIt.instance<AppDatabase>()
          .adherenceDao
          .watchGlobalAdherenceRate('global_weekly')
          .listen((data) {
        if (data != null && _state.metrics != null) {
          final newMetrics = _state.metrics!.copyWith(
            adherenceRate: data.rate > 1 ? data.rate / 100 : data.rate,
          );
          state = state.copyWith(metrics: newMetrics);
        }
      });
    }
  }

  @override
  void dispose() {
    _adherenceSub?.cancel();
    super.dispose();
  }

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

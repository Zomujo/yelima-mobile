import 'package:flutter/material.dart';
import '../../domain/entities/vital_trends.dart';
import '../../domain/repositories/progress_repository.dart';
import 'progress_state.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import 'package:get_it/get_it.dart';

class ProgressController extends ChangeNotifier with SafeNotifier implements SessionLifecycleHandler {
  // --------------------------------------------------------------------------
  // |                                  State & Dependencies                  |
  // --------------------------------------------------------------------------

  final ProgressRepository _repository;

  ProgressState<BPTrend> _bpTrendState = const ProgressState(isLoading: true);
  ProgressState<VitalTrend> _glucoseTrendState = const ProgressState(isLoading: true);

  ProgressState<BPTrend> get bpTrendState => _bpTrendState;
  ProgressState<VitalTrend> get glucoseTrendState => _glucoseTrendState;

  set bpTrendState(ProgressState<BPTrend> value) {
    if (_bpTrendState == value) return;
    _bpTrendState = value;
    notifyListeners();
  }

  set glucoseTrendState(ProgressState<VitalTrend> value) {
    if (_glucoseTrendState == value) return;
    _glucoseTrendState = value;
    notifyListeners();
  }

  ChartDateRange _currentBPRange = ChartDateRange.today;
  ChartDateRange _currentGlucoseRange = ChartDateRange.today;

  ProgressController(this._repository) {
    if (GetIt.instance.isRegistered<SessionLifecycleService>()) {
      GetIt.instance<SessionLifecycleService>().register(this);
    }
  }

  @override
  String get serviceName => 'ProgressController';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async {
    _bpTrendState = const ProgressState(isLoading: true);
    _glucoseTrendState = const ProgressState(isLoading: true);
    notifyListeners();
  }

  /// Fetches the Blood Pressure trends for the specified date range.

  // --------------------------------------------------------------------------
  // |                                   Actions & Methods                    |
  // --------------------------------------------------------------------------

  Future<void> fetchBPTrend(
      {ChartDateRange dateRange = ChartDateRange.today}) async {
    bool isNewRange = _currentBPRange != dateRange || bpTrendState.data == null;
    _currentBPRange = dateRange;

    // Load from cache if it's a new range or empty
    if (isNewRange) {
      bpTrendState = const ProgressState(isLoading: true);
      final cachedResult =
          await _repository.getCachedBPTrend(dateRange: dateRange);
      cachedResult.fold((_) {}, (data) {
        if (data.labels.isNotEmpty) {
          bpTrendState =
              bpTrendState.copyWith(data: data, isLoading: false, error: null);
        }
      });
    }

    // Emit loading state only if we still don't have data
    if (bpTrendState.data == null) {
      bpTrendState = bpTrendState.copyWith(isLoading: true, error: null);
    }

    // Fetch from network silently
    final result = await _repository.getBPTrend(dateRange: dateRange);

    result.fold(
      (err) {
        if (_currentBPRange == dateRange) {
          bpTrendState = bpTrendState.copyWith(error: err, isLoading: false);
        }
      },
      (data) {
        if (_currentBPRange == dateRange) {
          bpTrendState = bpTrendState.copyWith(
            data: data,
            isLoading: false,
            isSyncFailed: false,
            lastUpdated: DateTime.now(),
            error: null,
          );
        }
      },
    );
  }

  /// Fetches the Blood Glucose trends for the specified date range.
  Future<void> fetchGlucoseTrend(
      {ChartDateRange dateRange = ChartDateRange.today}) async {
    bool isNewRange = _currentGlucoseRange != dateRange || glucoseTrendState.data == null;
    _currentGlucoseRange = dateRange;

    // Load from cache if it's a new range or empty
    if (isNewRange) {
      glucoseTrendState = const ProgressState(isLoading: true);
      final cachedResult = await _repository.getCachedVitalTrend(
          vitalType: 'bloodSugar', dateRange: dateRange);
      cachedResult.fold((_) {}, (data) {
        if (data.labels.isNotEmpty) {
          glucoseTrendState = glucoseTrendState.copyWith(
              data: data, isLoading: false, error: null);
        }
      });
    }

    // Emit loading state only if we still don't have data
    if (glucoseTrendState.data == null) {
      glucoseTrendState =
          glucoseTrendState.copyWith(isLoading: true, error: null);
    }

    // Fetch from network silently
    final result = await _repository.getVitalTrend(
        vitalType: 'bloodSugar', dateRange: dateRange);

    result.fold(
      (err) {
        if (_currentGlucoseRange == dateRange) {
          glucoseTrendState =
              glucoseTrendState.copyWith(error: err, isLoading: false);
        }
      },
      (data) {
        if (_currentGlucoseRange == dateRange) {
          glucoseTrendState = glucoseTrendState.copyWith(
            data: data,
            isLoading: false,
            isSyncFailed: false,
            lastUpdated: DateTime.now(),
            error: null,
          );
        }
      },
    );
  }
}

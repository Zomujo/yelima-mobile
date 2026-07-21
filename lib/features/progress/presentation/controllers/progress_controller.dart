import 'package:flutter/material.dart';
import '../../domain/entities/vital_trends.dart';
import '../../domain/repositories/progress_repository.dart';
import 'progress_state.dart';
import '../../../../core/utils/safe_notifier.dart';

class ProgressController extends ChangeNotifier with SafeNotifier {
  final ProgressRepository _repository;

  ProgressState<BPTrend> _bpTrendState = const ProgressState();
  ProgressState<VitalTrend> _glucoseTrendState = const ProgressState();

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

  String _currentBPRange = 'today';
  String _currentGlucoseRange = 'today';

  ProgressController(this._repository);

  /// Fetches the Blood Pressure trends for the specified date range.
  Future<void> fetchBPTrend({String dateRange = 'today'}) async {
    _currentBPRange = dateRange;

    // Load from cache if empty
    if (bpTrendState.data == null) {
      bpTrendState = bpTrendState.copyWith(isLoading: true, error: null);

      final cachedResult =
          await _repository.getCachedBPTrend(dateRange: dateRange);
      cachedResult.fold((_) {}, (data) {
        if (data.labels.isNotEmpty) {
          bpTrendState =
              bpTrendState.copyWith(data: data, isLoading: false, error: null);
        }
      });
    }

    // Ensure loading state if still empty
    if (bpTrendState.data == null) {
      bpTrendState = bpTrendState.copyWith(isLoading: true, error: null);
    }

    // Fetch from network
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
  Future<void> fetchGlucoseTrend({String dateRange = 'today'}) async {
    _currentGlucoseRange = dateRange;

    // Load from cache if empty
    if (glucoseTrendState.data == null) {
      glucoseTrendState =
          glucoseTrendState.copyWith(isLoading: true, error: null);

      final cachedResult = await _repository.getCachedVitalTrend(
          vitalType: 'bloodSugar', dateRange: dateRange);
      cachedResult.fold((_) {}, (data) {
        if (data.labels.isNotEmpty) {
          glucoseTrendState = glucoseTrendState.copyWith(
              data: data, isLoading: false, error: null);
        }
      });
    }

    // Ensure loading state if still empty
    if (glucoseTrendState.data == null) {
      glucoseTrendState =
          glucoseTrendState.copyWith(isLoading: true, error: null);
    }

    // Fetch from network
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

import 'package:flutter/material.dart';
import '../../domain/entities/vital_trends.dart';
import '../../domain/repositories/progress_repository.dart';
import 'progress_state.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../../../core/services/mutation_sync_manager.dart';
import 'dart:async';

class ProgressController extends ChangeNotifier with SafeNotifier {
  final ProgressRepository _repository;
  final MutationSyncManager _mutationSyncManager;
  StreamSubscription<String>? _syncSubscription;

  ProgressState<BPTrend> bpTrendState = const ProgressState();
  ProgressState<VitalTrend> glucoseTrendState = const ProgressState();

  String _currentBPRange = 'today';
  String _currentGlucoseRange = 'today';

  ProgressController(this._repository, this._mutationSyncManager) {
    _initSyncListener();
  }

  void _initSyncListener() {
    _syncSubscription = _mutationSyncManager.onMutationSynced.listen((entityType) {
      if (entityType == 'vital_history') {
        fetchBPTrend(dateRange: _currentBPRange);
        fetchGlucoseTrend(dateRange: _currentGlucoseRange);
      }
    });
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchBPTrend({String dateRange = 'today'}) async {
    _currentBPRange = dateRange;

    if (bpTrendState.data == null) {
      bpTrendState = bpTrendState.copyWith(isLoading: true, error: null);
      notifyListeners();

      final cachedResult =
          await _repository.getCachedBPTrend(dateRange: dateRange);
      cachedResult.fold((_) => null, (data) {
        if (data.labels.isNotEmpty) {
          bpTrendState = bpTrendState.copyWith(
            data: data,
            isLoading: false,
            error: null,
          );
          notifyListeners();
        }
      });
    }

    if (bpTrendState.data == null) {
      bpTrendState = bpTrendState.copyWith(isLoading: true, error: null);
      notifyListeners();
    }

    final result = await _repository.getBPTrend(dateRange: dateRange);

    result.fold(
      (err) {
        if (_currentBPRange != dateRange) return;
        bpTrendState = bpTrendState.copyWith(error: err, isLoading: false);
      },
      (data) {
        if (_currentBPRange != dateRange) return;
        bpTrendState = bpTrendState.copyWith(
          data: data,
          isLoading: false,
          isSyncFailed: false,
          lastUpdated: DateTime.now(),
          error: null,
        );
      },
    );
    notifyListeners();
  }

  Future<void> fetchGlucoseTrend({String dateRange = 'today'}) async {
    _currentGlucoseRange = dateRange;

    if (glucoseTrendState.data == null) {
      glucoseTrendState =
          glucoseTrendState.copyWith(isLoading: true, error: null);
      notifyListeners();

      final cachedResult = await _repository.getCachedVitalTrend(
          vitalType: 'bloodSugar', dateRange: dateRange);
      cachedResult.fold((_) => null, (data) {
        if (data.labels.isNotEmpty) {
          glucoseTrendState = glucoseTrendState.copyWith(
            data: data,
            isLoading: false,
            error: null,
          );
          notifyListeners();
        }
      });
    }

    if (glucoseTrendState.data == null) {
      glucoseTrendState =
          glucoseTrendState.copyWith(isLoading: true, error: null);
      notifyListeners();
    }

    final result = await _repository.getVitalTrend(
        vitalType: 'bloodSugar', dateRange: dateRange);

    result.fold(
      (err) {
        if (_currentGlucoseRange != dateRange) return;
        glucoseTrendState =
            glucoseTrendState.copyWith(error: err, isLoading: false);
      },
      (data) {
        if (_currentGlucoseRange != dateRange) return;
        glucoseTrendState = glucoseTrendState.copyWith(
          data: data,
          isLoading: false,
          isSyncFailed: false,
          lastUpdated: DateTime.now(),
          error: null,
        );
      },
    );
    notifyListeners();
  }
}

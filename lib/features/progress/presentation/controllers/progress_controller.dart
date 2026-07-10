import 'package:flutter/material.dart';
import '../../domain/entities/vital_trends.dart';
import '../../domain/repositories/progress_repository.dart';
import 'progress_state.dart';
import '../../../../core/utils/safe_notifier.dart';

class ProgressController extends ChangeNotifier with SafeNotifier {
  final ProgressRepository _repository;

  ProgressState<BPTrend> bpTrendState = const ProgressState();
  ProgressState<VitalTrend> glucoseTrendState = const ProgressState();

  ProgressController(this._repository);

  Future<void> fetchBPTrend({String dateRange = 'today'}) async {
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
        bpTrendState = bpTrendState.copyWith(error: err, isLoading: false);
      },
      (data) {
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
        glucoseTrendState =
            glucoseTrendState.copyWith(error: err, isLoading: false);
      },
      (data) {
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

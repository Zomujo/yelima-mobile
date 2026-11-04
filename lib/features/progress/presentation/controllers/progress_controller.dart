import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/utils/follow_session.dart';
import '../../domain/entities/vital_trends.dart';
import '../../progress_providers.dart';
import 'progress_state.dart';

part 'progress_controller.g.dart';

/// The progress screen's blood pressure and blood sugar charts.
@Riverpod(keepAlive: true)
class ProgressController extends _$ProgressController {
  late _Trend<BPTrend> _bp;
  late _Trend<VitalTrend> _sugar;

  @override
  ProgressCharts build() {
    final repo = ref.watch(progressRepositoryProvider);
    _bp = _Trend(
        repo.getCachedBPTrend,
        repo.getBPTrend,
        () => state.bpTrendState,
        (s) => state = state.copyWith(bpTrendState: s));
    _sugar = _Trend(
        repo.getCachedSugarTrend,
        repo.getSugarTrend,
        () => state.glucoseTrendState,
        (s) => state = state.copyWith(glucoseTrendState: s));
    followSession(ref, onEnd: () {
      _bp.reset();
      _sugar.reset();
      state = const ProgressCharts();
    });
    return const ProgressCharts();
  }

  /// Loads both charts for [range].
  Future<void> load(ChartDateRange range) =>
      Future.wait([_bp.load(range), _sugar.load(range)]);
}

/// One chart: the phone's copy at once, then the server's, ignoring answers for an old range.
class _Trend<T extends TrendLabels> {
  _Trend(this._cached, this._fetch, this._get, this._set);

  final AsyncResult<T> Function(ChartDateRange) _cached;
  final AsyncResult<T> Function(ChartDateRange) _fetch;
  final ProgressState<T> Function() _get;
  final void Function(ProgressState<T>) _set;
  ChartDateRange? _range;

  Future<void> load(ChartDateRange range) async {
    if (range != _range || _get().data == null) {
      _range = range;
      _set(const ProgressState(isLoading: true));
      final cached = (await _cached(range)).toNullable();
      if (cached != null && cached.labels.isNotEmpty) {
        _set(ProgressState(data: cached));
      }
    }
    final result = await _fetch(range);
    if (range != _range) return;
    result.fold((f) => _set(_get().copyWith(isLoading: false, error: f)),
        (data) => _set(ProgressState(data: data)));
  }

  /// Forgets the range, so the next load starts from a blank chart.
  void reset() => _range = null;
}

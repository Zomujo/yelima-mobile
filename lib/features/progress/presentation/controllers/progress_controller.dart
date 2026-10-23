import 'package:flutter/foundation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../../../core/utils/session_scoped.dart';
import '../../domain/entities/vital_trends.dart';
import '../../domain/repositories/progress_repository.dart';
import 'progress_state.dart';

/// The progress screen's blood pressure and blood sugar charts.
class ProgressController extends ChangeNotifier
    with SafeNotifier, SessionScoped {
  ProgressController(ProgressRepository repository) {
    _bp = _Trend(
        repository.getCachedBPTrend, repository.getBPTrend, notifyListeners);
    _sugar = _Trend(repository.getCachedSugarTrend, repository.getSugarTrend,
        notifyListeners);
    joinSession();
  }

  late final _Trend<BPTrend> _bp;
  late final _Trend<VitalTrend> _sugar;

  ProgressState<BPTrend> get bpTrendState => _bp.state;
  ProgressState<VitalTrend> get glucoseTrendState => _sugar.state;

  @override
  String get serviceName => 'ProgressController';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async {
    _bp.reset();
    _sugar.reset();
    notifyListeners();
  }

  /// Loads both charts for [range].
  Future<void> load(ChartDateRange range) =>
      Future.wait([_bp.load(range), _sugar.load(range)]);
}

/// One chart: the phone's copy at once, then the server's, ignoring answers for an old range.
class _Trend<T extends TrendLabels> {
  _Trend(this._cached, this._fetch, this._notify);

  final AsyncResult<T> Function(ChartDateRange) _cached;
  final AsyncResult<T> Function(ChartDateRange) _fetch;
  final VoidCallback _notify;
  ProgressState<T> state = const ProgressState(isLoading: true);
  ChartDateRange? _range;

  Future<void> load(ChartDateRange range) async {
    if (range != _range || state.data == null) {
      _range = range;
      _set(const ProgressState(isLoading: true));
      final cached = (await _cached(range)).toNullable();
      if (cached != null && cached.labels.isNotEmpty) {
        _set(ProgressState(data: cached));
      }
    }
    final result = await _fetch(range);
    if (range != _range) return;
    result.fold((f) => _set(state.copyWith(isLoading: false, error: f)),
        (data) => _set(ProgressState(data: data)));
  }

  void reset() {
    _range = null;
    state = const ProgressState(isLoading: true);
  }

  void _set(ProgressState<T> value) {
    state = value;
    _notify();
  }
}

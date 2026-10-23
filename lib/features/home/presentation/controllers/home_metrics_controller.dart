import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/utils/safe_notifier.dart';
import '../../../../core/utils/session_scoped.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../vitals/domain/repositories/vitals_repository.dart';
import '../states/home_metrics_state.dart';

/// The home metric cards, kept live from the phone and refreshed from the server.
class HomeMetricsController extends ChangeNotifier
    with SafeNotifier, SessionScoped {
  HomeMetricsController({
    required VitalsRepository vitals,
    required MedicationRepository medications,
  })  : _vitals = vitals,
        _medications = medications {
    joinSession();
    _follow();
  }

  final VitalsRepository _vitals;
  final MedicationRepository _medications;
  final _subs = <StreamSubscription<Object?>>[];

  HomeMetricsState _state = const HomeMetricsState();
  HomeMetricsState get state => _state;
  set state(HomeMetricsState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  @override
  String get serviceName => 'HomeMetricsController';

  @override
  Future<void> onSessionStarted(String userId) async => _follow();

  @override
  Future<void> onSessionEnded() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    state = const HomeMetricsState();
  }

  /// A reading or dose saved anywhere updates home straight away.
  void _follow() {
    if (_subs.isNotEmpty) return;
    _subs
      ..add(_vitals
          .watchLatest()
          .listen((latest) => state = state.copyWith(vitals: latest)))
      ..add(_medications.watchAdherenceRate().listen((rate) => state =
          state.copyWith(
              adherence:
                  rate == null ? null : (rate > 1 ? rate / 100 : rate))));
  }

  /// Refreshes readings and adherence from the server.
  Future<void> fetchMetrics() async {
    await Future.wait([_vitals.refresh(), _medications.getAdherence()]);
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}

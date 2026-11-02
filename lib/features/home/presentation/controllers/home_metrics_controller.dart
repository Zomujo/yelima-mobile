import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/utils/safe_notifier.dart';
import '../../../../core/utils/session_scoped.dart';
import '../../../medications/domain/entities/medication_adherence.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../vitals/domain/repositories/vitals_repository.dart';
import '../states/home_metrics_state.dart';

/// The home metric cards, kept live from the phone and refreshed from the server.
class HomeMetricsController extends ChangeNotifier
    with SafeNotifier, SessionScoped {
  HomeMetricsController({
    required VitalsRepository vitals,
    required MedicationRepository medications,
    Stream<void> newDays = const Stream.empty(),
  })  : _vitals = vitals,
        _medications = medications,
        _newDays = newDays {
    joinSession();
    _follow();
  }

  final VitalsRepository _vitals;
  final MedicationRepository _medications;
  final Stream<void> _newDays;
  final _subs = <StreamSubscription<Object?>>[];
  MedicationAdherence? _saved;
  bool _asked = false;

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
    _saved = null;
    _asked = false;
    state = const HomeMetricsState();
  }

  /// A reading or dose saved anywhere updates home straight away.
  void _follow() {
    if (_subs.isNotEmpty) return;
    _subs
      ..add(_vitals
          .watchLatest()
          .listen((latest) => state = state.copyWith(vitals: latest)))
      ..add(_medications.watchAdherence().listen((a) {
        _saved = a;
        _showAdherence();
      }))
      // Doses sent late weren't in the server's figure yet.
      ..add(_medications.onSynced.listen((_) => _medications.getAdherence()))
      // A new week starts each day, so yesterday's figure waits for the server.
      ..add(_newDays.listen((_) {
        _asked = false;
        _showAdherence();
        fetchMetrics();
      }));
  }

  /// An older saved figure covers another week, so it waits for the server
  /// and only shows when the server can't answer.
  void _showAdherence() {
    final saved = _saved;
    final usable = saved != null && (_asked || saved.isCurrent);
    state = state.copyWith(
        adherence: usable ? saved.rate / 100 : (_asked ? 0 : null));
  }

  /// Refreshes readings and adherence from the server.
  Future<void> fetchMetrics() async {
    await Future.wait([_vitals.refresh(), _medications.getAdherence()]);
    _asked = true;
    _showAdherence();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}

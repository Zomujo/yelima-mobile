import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/core_providers.dart';
import '../../../../core/utils/follow_session.dart';
import '../../../medications/domain/entities/medication_adherence.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../medications/medications_providers.dart';
import '../../../vitals/domain/repositories/vitals_repository.dart';
import '../../../vitals/vitals_providers.dart';
import '../states/home_metrics_state.dart';

part 'home_metrics_controller.g.dart';

/// The home metric cards, kept live from the phone and refreshed from the server.
@Riverpod(keepAlive: true)
class HomeMetricsController extends _$HomeMetricsController {
  late VitalsRepository _vitals;
  late MedicationRepository _medications;
  late Stream<void> _newDays;
  final _subs = <StreamSubscription<Object?>>[];
  MedicationAdherence? _saved;
  bool _asked = false;

  @override
  HomeMetricsState build() {
    _vitals = ref.watch(vitalsRepositoryProvider);
    _medications = ref.watch(medicationRepositoryProvider);
    _newDays = ref.watch(dayChangesProvider).stream;
    followSession(ref,
        onStart: (_) => _follow(),
        onEnd: () async {
          await _stop();
          _saved = null;
          _asked = false;
          state = const HomeMetricsState();
        });
    ref.onDispose(_stop);
    _follow();
    Future.microtask(fetchMetrics);
    return const HomeMetricsState();
  }

  @override
  bool updateShouldNotify(HomeMetricsState previous, HomeMetricsState next) =>
      previous != next;

  Future<void> _stop() async {
    final subs = [..._subs];
    _subs.clear();
    for (final s in subs) {
      await s.cancel();
    }
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
}

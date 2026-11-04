import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/core_providers.dart';
import '../../../../core/utils/follow_session.dart';
import '../../domain/dose_window.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_section.dart';
import '../../domain/medication_failures.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../medications_providers.dart';
import '../states/medications_state.dart';

part 'medication_controller.g.dart';

/// The medications tab: today's doses by section, counts and weekly adherence.
@Riverpod(keepAlive: true)
class MedicationController extends _$MedicationController {
  late MedicationRepository _repository;
  late Stream<void> _newDays;
  StreamSubscription<void>? _syncSub;
  StreamSubscription<void>? _daySub;
  StreamSubscription<Object?>? _countsSub;
  StreamSubscription<List<MedicationEntity>>? _dosesSub;
  Timer? _dueTimer;

  @override
  MedicationsState build() {
    _repository = ref.watch(medicationRepositoryProvider);
    _newDays = ref.watch(dayChangesProvider).stream;
    followSession(ref, onEnd: () async {
      await _stop();
      state = const MedicationsState();
    });
    ref.onDispose(_stop);
    return const MedicationsState();
  }

  @override
  bool updateShouldNotify(MedicationsState previous, MedicationsState next) =>
      previous != next;

  Future<void> _stop() async {
    _dueTimer?.cancel();
    final subs = [_syncSub, _daySub, _countsSub, _dosesSub];
    _syncSub = _daySub = null;
    _countsSub = _dosesSub = null;
    for (final s in subs) {
      await s?.cancel();
    }
  }

  /// Opens on the section for the time of day and refreshes everything.
  void init() {
    _syncSub ??= _repository.onSynced.listen((_) => fetchAdherence());
    _daySub ??= _newDays.listen((_) => _startNewDay());
    _countsSub ??= _repository
        .watchCounts()
        .listen((counts) => state = state.copyWith(counts: counts));
    state = state.copyWith(section: MedicationSection.at(clock.now().hour));
    _watchSection();
    fetchAdherence();
    _repository.refreshAll();
  }

  /// Yesterday's ticks and week no longer apply, so everything loads afresh.
  void _startNewDay() {
    state = state.copyWith(adherence: null, doses: const {});
    _watchSection();
    fetchAdherence();
    _repository.refreshAll();
  }

  /// Shows another section's doses.
  void selectSection(MedicationSection section) {
    if (state.section == section) return;
    state = state.copyWith(section: section);
    _watchSection();
  }

  /// Shows the phone's adherence at once if saved today, then the server's.
  Future<void> fetchAdherence() async {
    final cached =
        state.adherence == null ? await _repository.getCachedAdherence() : null;
    // An older copy covers another 7 days, so it waits for the server.
    if (cached != null && cached.isCurrent) {
      state = state.copyWith(adherence: cached);
    }
    final result = await _repository.getAdherence();
    state = state.copyWith(
        adherence: result.fold((_) => state.adherence ?? cached, (a) => a));
  }

  /// Marks today's dose taken; fails with [DoseNotDueFailure] before its time.
  AsyncResult<void> confirm(MedicationEntity med) async {
    if (med.taken || state.confirmingMedicationIds.contains(med.id)) {
      return right(null);
    }
    if (!DoseWindow.canConfirm(med.toBeTakenAt, clock.now())) {
      return left(const DoseNotDueFailure());
    }
    _setConfirming(med.id, true);
    final result = await _repository.confirmDose(med.id, state.section);
    _setConfirming(med.id, false);
    if (result.isRight()) fetchAdherence();
    return result;
  }

  void _watchSection() {
    final section = state.section;
    _dosesSub?.cancel();
    _dosesSub = _repository.watchSection(section).listen((doses) {
      state = state.copyWith(doses: {...state.doses, section: doses});
      _wakeAtNextDose(doses);
    });
  }

  /// Redraws when the next dose falls due, so its Wait turns into Confirm.
  void _wakeAtNextDose(List<MedicationEntity> doses) {
    _dueTimer?.cancel();
    final now = clock.now();
    final due = [
      for (final d in doses)
        if (!d.taken) DoseWindow.scheduledToday(d.toBeTakenAt, now)
    ].where((t) => t.isAfter(now)).toList()
      ..sort();
    if (due.isNotEmpty) {
      _dueTimer = Timer(due.first.difference(now), ref.notifyListeners);
    }
  }

  void _setConfirming(String id, bool confirming) => state = state.copyWith(
      confirmingMedicationIds: confirming
          ? {...state.confirmingMedicationIds, id}
          : ({...state.confirmingMedicationIds}..remove(id)));
}

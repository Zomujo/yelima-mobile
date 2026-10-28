import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../domain/entities/reading_form.dart';
import '../../domain/entities/vital_history_entity.dart';
import '../../domain/reading_limits.dart';
import '../../domain/repositories/vitals_repository.dart';
import '../states/reading_logging_state.dart';

/// The log-a-reading screen: the form, prefilled from the last reading, and the history.
class ReadingLoggingController extends ChangeNotifier with SafeNotifier {
  ReadingLoggingController({required VitalsRepository repository})
      : _repository = repository;

  final VitalsRepository _repository;
  StreamSubscription<List<VitalHistoryEntity>>? _sub;

  /// Every reading on the phone, newest first; null until loaded.
  List<VitalHistoryEntity>? history;

  ReadingLoggingState _state = ReadingLoggingState(selectedDate: clock.now());
  ReadingLoggingState get state => _state;
  set state(ReadingLoggingState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  /// Follows the saved readings and refreshes them from the server.
  void init() {
    _sub ??= _repository.watchReadings().listen((rows) {
      history = _newestFirst(rows);
      if (!state.hasChanged) _prefillFrom(LatestVitals.from(rows));
      notifyListeners();
    });
    _repository.refresh();
  }

  /// Starts the form from the last reading, skipping values the pickers can't show.
  void _prefillFrom(LatestVitals latest) {
    final bp = latest.systolicDiastolic;
    final sugar = latest.sugarLevel;
    final bpOk =
        bp != null && ReadingLimits.bloodPressureError(bp.$1, bp.$2) == null;
    final sugarOk =
        sugar != null && ReadingLimits.bloodSugarError(sugar) == null;
    state = state.copyWith(
      systolic: bpOk ? bp.$1 : state.systolic,
      diastolic: bpOk ? bp.$2 : state.diastolic,
      sugarLevel: sugarOk ? sugar : state.sugarLevel,
      isInitializing: false,
    );
  }

  /// Switches between blood pressure and blood sugar.
  void setKind(VitalKind kind) {
    if (state.kind != kind) {
      state = state.copyWith(kind: kind, hasChanged: false);
    }
  }

  /// Sets when the blood sugar was taken (fasting, random…).
  void setVitalSubType(String subType) {
    if (state.vitalSubType != subType) {
      state = state.copyWith(vitalSubType: subType, hasChanged: true);
    }
  }

  /// Sets the blood pressure.
  void setBloodPressure(int sys, int dia) {
    if (state.systolic != sys || state.diastolic != dia) {
      state = state.copyWith(systolic: sys, diastolic: dia, hasChanged: true);
    }
  }

  /// Sets the blood sugar in mmol/L.
  void setSugarLevel(double level) {
    if (state.sugarLevel != level) {
      state = state.copyWith(sugarLevel: level, hasChanged: true);
    }
  }

  /// Sets the day of the reading, at the current time.
  void setSelectedDate(DateTime date) {
    final now = clock.now();
    state = state.copyWith(
        selectedDate: DateTime(
            date.year, date.month, date.day, now.hour, now.minute, now.second),
        hasChanged: true);
  }

  /// Saves the reading and gives its grade.
  AsyncResult<VitalSeverity> saveReading() async {
    state = state.copyWith(isSaving: true);
    final result = await _repository.saveReading(ReadingForm(
      kind: state.kind,
      subType: state.vitalSubType,
      systolic: state.systolic,
      diastolic: state.diastolic,
      sugarLevel: state.sugarLevel,
      recordedAt: state.selectedDate,
    ));
    state = state.copyWith(isSaving: false, hasChanged: result.isLeft());
    return result;
  }

  /// Newest first; readings within a second of each other fall back to id order.
  static List<VitalHistoryEntity> _newestFirst(List<VitalHistoryEntity> rows) =>
      [...rows]..sort((a, b) {
          final (ta, tb) =
              (a.recordedAt ?? DateTime(2000), b.recordedAt ?? DateTime(2000));
          return ta.difference(tb).inMilliseconds.abs() < 1000
              ? b.id.compareTo(a.id)
              : tb.compareTo(ta);
        });

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/reading_form.dart';
import '../../domain/entities/vital_history_entity.dart';
import '../../domain/reading_limits.dart';
import '../../vitals_providers.dart';
import '../states/reading_logging_state.dart';

part 'reading_logging_controller.g.dart';

/// The log-a-reading screen: the form, prefilled from the last reading, and the history.
@riverpod
class ReadingLoggingController extends _$ReadingLoggingController {
  bool _disposed = false;

  /// Follows the saved readings and refreshes them from the server.
  @override
  ReadingLoggingState build() {
    final repository = ref.watch(vitalsRepositoryProvider);
    final sub = repository.watchReadings().listen((rows) {
      state = state.copyWith(history: _newestFirst(rows));
      if (!state.hasChanged) _prefillFrom(LatestVitals.from(rows));
    });
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      sub.cancel();
    });
    repository.refresh();
    return ReadingLoggingState(selectedDate: clock.now());
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

  /// Sets the day of the reading; its time is taken when it is saved.
  void setSelectedDate(DateTime date) =>
      state = state.copyWith(selectedDate: date, hasChanged: true);

  /// The chosen day at the moment of saving, not when the screen opened.
  static DateTime _atNow(DateTime day) {
    final now = clock.now();
    return DateTime(
        day.year, day.month, day.day, now.hour, now.minute, now.second);
  }

  /// Saves the reading and gives its grade.
  AsyncResult<VitalSeverity> saveReading() async {
    state = state.copyWith(isSaving: true);
    final result =
        await ref.read(vitalsRepositoryProvider).saveReading(ReadingForm(
              kind: state.kind,
              subType: state.vitalSubType,
              systolic: state.systolic,
              diastolic: state.diastolic,
              sugarLevel: state.sugarLevel,
              recordedAt: _atNow(state.selectedDate),
            ));
    if (!_disposed) {
      state = state.copyWith(isSaving: false, hasChanged: result.isLeft());
    }
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
}

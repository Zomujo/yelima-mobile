import 'dart:async';

import 'package:clock/clock.dart';

/// Tells listeners when the date moves on, so "today" screens start the new day
/// even if the app stayed open overnight.
class DayChanges {
  DayChanges({Duration every = const Duration(minutes: 1)}) {
    _timer = Timer.periodic(every, (_) => check());
  }

  DateTime _day = _today();
  final _changes = StreamController<void>.broadcast();
  late final Timer _timer;

  /// Fires once each time the date changes.
  Stream<void> get stream => _changes.stream;

  /// Fires [stream] if the date changed since the last check.
  void check() {
    final today = _today();
    if (today == _day) return;
    _day = today;
    _changes.add(null);
  }

  static DateTime _today() {
    final now = clock.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Stops checking; for tests.
  void dispose() {
    _timer.cancel();
    _changes.close();
  }
}

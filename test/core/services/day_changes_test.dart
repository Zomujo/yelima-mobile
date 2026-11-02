import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/services/day_changes.dart';

void main() {
  test('fires once when the date moves on, not within the same day', () async {
    final sunday = DateTime(2026, 11, 1, 23, 50);
    final days = withClock(
        Clock.fixed(sunday), () => DayChanges(every: const Duration(hours: 1)));
    addTearDown(days.dispose);
    var fired = 0;
    days.stream.listen((_) => fired++);

    withClock(Clock.fixed(sunday.add(const Duration(minutes: 5))), days.check);
    withClock(Clock.fixed(DateTime(2026, 11, 2, 9, 6)), days.check);
    withClock(Clock.fixed(DateTime(2026, 11, 2, 9, 7)), days.check);
    await pumpEventQueue();

    expect(fired, 1);
  });
}

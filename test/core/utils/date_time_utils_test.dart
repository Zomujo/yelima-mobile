import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/utils/date_time_utils.dart';

void main() {
  final fixed = Clock.fixed(DateTime(2026, 10, 23, 9, 30));

  group('deriveTime converts 12-hour times onto today', () {
    const cases = <(int, String, int)>[
      (12, 'AM', 0),
      (1, 'AM', 1),
      (11, 'AM', 11),
      (12, 'PM', 12),
      (1, 'pm', 13),
      (11, 'PM', 23),
    ];
    for (final (hour, period, expected) in cases) {
      test('$hour $period -> $expected:15', () {
        final result =
            withClock(fixed, () => DateTimeUtils.deriveTime(hour, 15, period));
        expect(result, DateTime(2026, 10, 23, expected, 15));
      });
    }
  });

  group('formatDate', () {
    test('labels today and yesterday', () {
      withClock(fixed, () {
        expect(
            DateTimeUtils.formatDate(DateTime(2026, 10, 23, 23, 59)), 'Today');
        expect(DateTimeUtils.formatDate(DateTime(2026, 10, 22)), 'Yesterday');
      });
    });

    test('uses the ordinal day for older dates, including 11th-13th', () {
      withClock(fixed, () {
        expect(DateTimeUtils.formatDate(DateTime(2026, 7, 1)), '1st July 2026');
        expect(
            DateTimeUtils.formatDate(DateTime(2026, 7, 12)), '12th July 2026');
        expect(
            DateTimeUtils.formatDate(DateTime(2026, 7, 23)), '23rd July 2026');
      });
    });

    test('just after midnight, the previous evening is yesterday', () {
      withClock(Clock.fixed(DateTime(2026, 10, 23, 0, 1)), () {
        expect(DateTimeUtils.formatDate(DateTime(2026, 10, 22, 23, 59)),
            'Yesterday');
      });
    });
  });
}

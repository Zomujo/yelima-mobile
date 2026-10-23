import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/domain/entities/medication_form.dart';
import 'package:yelima/features/medications/domain/models/dosing_schedule_model.dart';

void main() {
  group('the server\'s 12-hour times on the 24-hour clock', () {
    const cases = <(int, String, int)>[
      (12, 'AM', 0),
      (1, 'AM', 1),
      (11, 'AM', 11),
      (12, 'PM', 12),
      (1, 'pm', 13),
      (11, 'PM', 23),
    ];
    for (final (hour, period, expected) in cases) {
      test('$hour $period is $expected:00 and back', () {
        final time = ScheduleTimeModel(
            hour: hour, minutes: 0, timeDesignators: period.toUpperCase());
        expect(time.hour24, expected);
        expect(ScheduleTimeModel.from24(expected, 0), time);
      });
    }
  });

  test('a dose round-trips through the server format', () {
    const dose = DoseSchedule(hour: 20, minute: 30, quantity: 2);
    expect(DosingScheduleModel.fromDose(dose, 'tablet').toDose(), dose);
  });
}

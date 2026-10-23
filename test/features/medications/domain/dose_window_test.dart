import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/domain/dose_window.dart';

void main() {
  final dose = DateTime(2026, 9, 1, 8, 0); // scheduled long ago, at 08:00

  test('a dose can be confirmed from its exact time, never earlier', () {
    expect(DoseWindow.canConfirm(dose, DateTime(2026, 10, 23, 7, 59)), isFalse);
    expect(DoseWindow.canConfirm(dose, DateTime(2026, 10, 23, 8, 0)), isTrue);
    expect(DoseWindow.canConfirm(dose, DateTime(2026, 10, 23, 23, 59)), isTrue);
  });

  test('uses today\'s time of day, not the date the dose was created', () {
    expect(DoseWindow.scheduledToday(dose, DateTime(2026, 10, 23, 12)),
        DateTime(2026, 10, 23, 8, 0));
  });

  test('more than 4 hours after its time counts as late', () {
    expect(DoseWindow.isLate(dose, DateTime(2026, 10, 23, 12, 0)), isFalse);
    expect(DoseWindow.isLate(dose, DateTime(2026, 10, 23, 12, 1)), isTrue);
  });

  test('MED-EC-11: "taken" only counts on the day it was confirmed', () {
    final now = DateTime(2026, 10, 23, 9);
    expect(DoseWindow.takenToday(DateTime(2026, 10, 23, 8, 5), now), isTrue);
    expect(DoseWindow.takenToday(DateTime(2026, 10, 22, 8, 5), now), isFalse);
    expect(DoseWindow.takenToday(null, now), isFalse);
  });
}

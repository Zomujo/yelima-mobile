import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/domain/entities/medication_adherence.dart';
import 'package:yelima/features/medications/domain/week_adherence.dart';

/// The cases are real staging answers, so the phone must give the same numbers.
void main() {
  AdherenceDay day(int month, int date, bool? taken, int done, int planned) =>
      AdherenceDay(
          takenAt: DateTime(2026, month, date),
          taken: taken,
          takenDoses: done,
          scheduledDoses: planned);

  // The server's week on Sunday 1 Nov, with Sunday still open.
  final lastWeek = [
    day(10, 26, false, 0, 1),
    day(10, 27, true, 2, 2),
    day(10, 28, true, 3, 3),
    day(10, 29, true, 7, 7),
    day(10, 30, true, 7, 7),
    day(10, 31, false, 4, 7),
    day(11, 1, null, 4, 7),
  ];

  String dots(MedicationAdherence week) => week.days
      .map((d) =>
          '${d.takenAt.day}:${d.taken}:${d.takenDoses}/${d.scheduledDoses}')
      .join(' ');

  test('Monday offline: the new week, and the rate from last week (82%)', () {
    final week = WeekAdherence.compute(
      saved: lastWeek,
      scheduledToday: 7,
      takenToday: 3,
      perDay: 7,
      now: DateTime(2026, 11, 2, 9, 6),
    );

    // Staging said 82 that morning: Tue to Sun, 27 of 33 doses.
    expect(week.rate, 82);
    expect(dots(week),
        '2:null:3/7 3:null:0/7 4:null:0/7 5:null:0/7 6:null:0/7 7:null:0/7 8:null:0/7');
  });

  test('Sunday: today is open and stays out of the rate (85%)', () {
    final week = WeekAdherence.compute(
      saved: lastWeek,
      scheduledToday: 7,
      takenToday: 4,
      perDay: 7,
      now: DateTime(2026, 11, 1, 18),
    );

    expect(week.rate, 85);
    expect(week.days.first.takenAt, DateTime(2026, 10, 26));
    expect(week.days.last.taken, isNull);
  });

  test('a day that is over is decided, even if it was saved while open', () {
    final week = WeekAdherence.compute(
      saved: lastWeek,
      scheduledToday: 7,
      takenToday: 0,
      perDay: 7,
      now: DateTime(2026, 11, 2, 9),
    );
    final sunday = WeekAdherence.compute(
      saved: lastWeek,
      scheduledToday: 7,
      takenToday: 0,
      perDay: 7,
      now: DateTime(2026, 11, 8, 9),
    );

    expect(week.rate, 82, reason: 'Sunday 4/7 now counts as missed');
    expect(sunday.days.first.taken, isNull, reason: 'never seen: no data');
  });

  test('every dose taken today ticks today', () {
    final week = WeekAdherence.compute(
      saved: const [],
      scheduledToday: 2,
      takenToday: 2,
      perDay: 2,
      now: DateTime(2026, 11, 4, 21),
    );

    expect(week.days[2].taken, isTrue);
  });

  test('a day with nothing planned is not a miss and adds nothing', () {
    final week = WeekAdherence.compute(
      saved: [
        for (final d in [29, 30, 31]) day(10, d, false, 0, 0),
        day(11, 1, false, 0, 0),
        day(11, 2, false, 0, 0),
        day(11, 3, true, 1, 1),
      ],
      scheduledToday: 1,
      takenToday: 0,
      perDay: 1,
      now: DateTime(2026, 11, 4, 9),
    );

    expect(week.rate, 100);
  });

  test('a missing day of the last 7 keeps the last known rate', () {
    // After a fresh sign-in the phone only has this week from the server.
    final week = WeekAdherence.compute(
      saved: [day(11, 2, null, 3, 7)],
      scheduledToday: 7,
      takenToday: 3,
      perDay: 7,
      now: DateTime(2026, 11, 2, 15),
      lastRate: 82,
    );

    expect(week.rate, 82);
    expect(week.days.first.takenDoses, 3);
  });

  test('nothing decided yet gives 0, which the app shows as no data', () {
    final week = WeekAdherence.compute(
      saved: const [],
      scheduledToday: 3,
      takenToday: 1,
      perDay: 3,
      now: DateTime(2026, 11, 2, 9),
    );

    expect(week.rate, 0);
  });
}

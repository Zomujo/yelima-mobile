import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/features/medications/data/models/medication_adherence_model.dart';
import 'package:yelima/features/medications/data/models/medication_history_model.dart';

import '../../../../helpers/fakes.dart';

void main() {
  group('the server\'s per-dose week', () {
    test('a day still open is pending, with its dose counts', () {
      final week = MedicationAdherenceModel.fromJson(const {
        'rate': 80,
        'days': [
          {
            'label': 'M',
            'dateTaken': '2026-10-19T00:00:00.000Z',
            'taken': true,
            'takenDoses': 2,
            'scheduledDoses': 2
          },
          {
            'label': 'T',
            'dateTaken': '2026-10-20T00:00:00.000Z',
            'taken': false,
            'takenDoses': 1,
            'scheduledDoses': 2
          },
          {
            'label': 'W',
            'dateTaken': '2026-10-21T00:00:00.000Z',
            'taken': null,
            'takenDoses': 1,
            'scheduledDoses': 2
          },
        ],
      });

      expect(week.days.map((d) => (d.taken, d.takenDoses, d.scheduledDoses)),
          [(true, 2, 2), (false, 1, 2), (null, 1, 2)]);
    });

    test('older responses with a status still read as taken', () {
      expect(
          AdherenceDayModel.fromJson(const {
            'dateTaken': '2026-10-19T00:00:00.000Z',
            'status': 'taken'
          }).taken,
          isTrue);
    });
  });

  test('a month day still open is pending, not missed', () {
    final history = MedicationHistoryModel.fromJson(const {
      'medicationName': 'Metformin',
      'adherenceRate': 92,
      'logs': [
        {'takenAt': '2026-10-21T00:00:00.000Z', 'taken': null, 'id': 'a'},
        {'takenAt': '2026-10-20T00:00:00.000Z', 'taken': false, 'id': 'b'},
      ],
    });

    expect(history.logs.map((l) => l.taken), [null, false]);
  });

  group('saved days', () {
    late AppDatabase db;
    setUp(() => db = testDb());
    tearDown(() => db.close());

    AdherenceGlobalDay day(DateTime date) => AdherenceGlobalDay(
        dateTakenStr: date.toIso8601String(),
        taken: true,
        label: '',
        type: 'global_weekly',
        takenDoses: 1,
        scheduledDoses: 1);
    Future<List<String>> dates() async => [
          for (final d in await db.adherenceDao.getGlobalAdherenceDays())
            d.dateTakenStr.substring(0, 10)
        ];

    test('a new week is merged in, so last week stays for the 7-day rate',
        () async {
      await withClock(
          Clock.fixed(DateTime(2026, 11, 1)),
          () => db.adherenceDao.saveGlobalAdherence(
              'global_weekly', 85, [day(DateTime(2026, 11, 1))]));
      await withClock(
          Clock.fixed(DateTime(2026, 11, 2)),
          () => db.adherenceDao.saveGlobalAdherence(
              'global_weekly', 82, [day(DateTime(2026, 11, 2))]));

      expect(await dates(), ['2026-11-01', '2026-11-02']);
    });

    test('days older than two weeks are dropped', () async {
      await withClock(
          Clock.fixed(DateTime(2026, 11, 1)),
          () => db.adherenceDao.saveGlobalAdherence(
              'global_weekly', 85, [day(DateTime(2026, 11, 1))]));
      await withClock(
          Clock.fixed(DateTime(2026, 11, 20)),
          () => db.adherenceDao.saveGlobalAdherence(
              'global_weekly', 90, [day(DateTime(2026, 11, 20))]));

      expect(await dates(), ['2026-11-20']);
    });
  });
}

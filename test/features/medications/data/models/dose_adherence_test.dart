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

  group('a dose confirmed offline', () {
    late AppDatabase db;
    setUp(() async {
      db = testDb();
      await db.adherenceDao.saveGlobalAdherence('global_weekly', 50, [
        const AdherenceGlobalDay(
            dateTakenStr: '2026-10-22T00:00:00.000',
            taken: null,
            label: '',
            type: 'global_weekly',
            takenDoses: 1,
            scheduledDoses: 2),
        const AdherenceGlobalDay(
            dateTakenStr: '2026-10-21T00:00:00.000',
            taken: true,
            label: '',
            type: 'global_weekly',
            takenDoses: 2,
            scheduledDoses: 2),
      ]);
    });
    tearDown(() => db.close());

    test('adds to the day, which is done once all its doses are', () async {
      await db.adherenceDao.markGlobalDayAsTakenOffline('2026-10-22');

      final day = (await db.adherenceDao.getGlobalAdherenceDays())
          .firstWhere((d) => d.dateTakenStr.startsWith('2026-10-22'));
      expect((day.taken, day.takenDoses), (true, 2));
      expect(
          (await db.adherenceDao.getGlobalAdherenceRate('global_weekly'))?.rate,
          100);
    });

    test('never counts more doses than were scheduled', () async {
      await db.adherenceDao.markGlobalDayAsTakenOffline('2026-10-21');

      final day = (await db.adherenceDao.getGlobalAdherenceDays())
          .firstWhere((d) => d.dateTakenStr.startsWith('2026-10-21'));
      expect(day.takenDoses, 2);
    });
  });
}

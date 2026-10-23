import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/features/medications/data/mappers/medication_mapper.dart';
import 'package:yelima/features/medications/data/models/create_medication_model.dart';
import 'package:yelima/features/medications/data/models/dosing_schedule_model.dart';
import 'package:yelima/features/medications/data/models/medication_model.dart';
import 'package:yelima/features/medications/data/models/update_medication_model.dart';

void main() {
  final today = DateTime(2026, 10, 23, 9, 0);
  T atToday<T>(T Function() body) => withClock(Clock.fixed(today), body);

  DosingScheduleModel dose(int hour, String period, {int minutes = 0}) =>
      DosingScheduleModel(
        time: ScheduleTimeModel(
            hour: hour, minutes: minutes, timeDesignators: period),
        quantity: const ScheduleQuantityModel(value: 1, unit: 'tablet'),
      );

  Medication row(String section, {bool taken = false, String id = 'm1'}) =>
      Medication(
        id: id,
        name: 'Amlodipine',
        dosage: '5mg',
        purpose: 'BP',
        notes: 'after food',
        toBeTakenAt: DateTime(2026, 10, 23, 8),
        taken: taken,
        section: section,
      );

  group('schedule JSON', () {
    test('round-trips a schedule', () {
      final schedule = dose(8, 'AM', minutes: 30);
      expect(
        MedicationMapper.decodeSchedule(
            MedicationMapper.encodeSchedule(schedule)),
        schedule,
      );
    });

    test('null stays null', () {
      expect(MedicationMapper.encodeSchedule(null), isNull);
      expect(MedicationMapper.decodeSchedule(null), isNull);
    });

    test('MED-EC-69: corrupt JSON decodes to null instead of throwing', () {
      expect(MedicationMapper.decodeSchedule('{not json'), isNull);
      expect(MedicationMapper.decodeSchedule('{"time": 3}'), isNull);
    });
  });

  group('fromCreateModel', () {
    test('creates one row per scheduled section with its local time', () {
      final rows = atToday(() => MedicationMapper.fromCreateModel(
            CreateMedicationModel(
              name: 'Amlodipine',
              dosage: '5mg',
              morning: dose(8, 'AM'),
              evening: dose(9, 'PM', minutes: 15),
            ),
            'local-1',
          ));

      expect(rows.map((r) => (r.id, r.section, r.toBeTakenAt, r.taken)), [
        ('local-1', 'MORNING', DateTime(2026, 10, 23, 8), false),
        ('local-1', 'EVENING', DateTime(2026, 10, 23, 21, 15), false),
      ]);
      // Every row carries the full schedule, so any row can rebuild the details.
      expect(rows.every((r) => r.morningJson != null && r.eveningJson != null),
          isTrue);
      expect(rows.every((r) => r.afternoonJson == null), isTrue);
    });

    test('12 AM is midnight and 12 PM is noon', () {
      final rows = atToday(() => MedicationMapper.fromCreateModel(
            CreateMedicationModel(
                name: 'X',
                dosage: '1',
                morning: dose(12, 'AM'),
                afternoon: dose(12, 'PM')),
            'l',
          ));

      expect(rows.map((r) => r.toBeTakenAt!.hour), [0, 12]);
    });

    test('MED-EC-38: no schedule produces no rows', () {
      final rows = atToday(() => MedicationMapper.fromCreateModel(
          const CreateMedicationModel(name: 'X', dosage: '1'), 'l'));

      expect(rows, isEmpty);
    });
  });

  group('fromUpdateModel', () {
    test('keeps each section\'s taken state and the original name', () {
      final rows = atToday(() => MedicationMapper.fromUpdateModel(
            UpdateMedicationModel(
                dosage: '10mg', morning: dose(7, 'AM'), evening: dose(8, 'PM')),
            'm1',
            [row('MORNING', taken: true), row('EVENING')],
          ));

      expect(rows.map((r) => (r.section, r.taken, r.dosage, r.name)), [
        ('MORNING', true, '10mg', 'Amlodipine'),
        ('EVENING', false, '10mg', 'Amlodipine'),
      ]);
      expect(rows.first.notes, 'after food');
    });

    test('a newly added section starts untaken', () {
      final rows = atToday(() => MedicationMapper.fromUpdateModel(
            UpdateMedicationModel(afternoon: dose(1, 'PM')),
            'm1',
            [row('MORNING', taken: true)],
          ));

      expect(rows.single.section, 'AFTERNOON');
      expect(rows.single.taken, isFalse);
    });

    test('returns nothing when there is no existing row', () {
      expect(
          MedicationMapper.fromUpdateModel(
              UpdateMedicationModel(morning: dose(8, 'AM')), 'm1', []),
          isEmpty);
    });
  });

  group('mergeRemoteWithLocal', () {
    MedicationModel remote(DateTime at, {bool taken = false}) =>
        MedicationModel(
          id: 'srv-1',
          name: 'Amlodipine',
          dosage: '5mg',
          purpose: 'BP',
          toBeTakenAt: at,
          taken: taken,
        );

    test('takes id, name and taken from the server, notes from local', () {
      final merged = atToday(() => MedicationMapper.mergeRemoteWithLocal(
          remote(DateTime(2026, 10, 23, 8), taken: true),
          row('MORNING'),
          'MORNING'));

      expect((merged.id, merged.taken, merged.notes),
          ('srv-1', true, 'after food'));
    });

    test('MED-EC-25: a time changed on the server replaces the local time', () {
      final merged = atToday(() => MedicationMapper.mergeRemoteWithLocal(
          remote(DateTime(2026, 10, 23, 9)), row('MORNING'), 'MORNING'));

      expect(merged.toBeTakenAt, DateTime(2026, 10, 23, 9));
    });

    test('MED-EC-40: a dose due right now keeps its real time', () {
      final merged = atToday(() => MedicationMapper.mergeRemoteWithLocal(
          remote(today), null, 'AFTERNOON'));

      expect(merged.toBeTakenAt, today);
    });

    test('no time from the server keeps the local one, or the section default',
        () {
      final noTime = MedicationModel.fromJson(
          const {'id': 'srv-1', 'name': 'A', 'dosage': '5mg', 'taken': false});

      final keptLocal = atToday(() => MedicationMapper.mergeRemoteWithLocal(
          noTime, row('EVENING'), 'EVENING'));
      final fallback = atToday(
          () => MedicationMapper.mergeRemoteWithLocal(noTime, null, 'EVENING'));

      expect(keptLocal.toBeTakenAt, DateTime(2026, 10, 23, 8));
      expect(fallback.toBeTakenAt, DateTime(2026, 10, 23, 20));
    });
  });

  group('MED-EC-11: taken resets every day', () {
    Medication confirmedOn(DateTime? day) => Medication(
          id: 'm1',
          name: 'Amlodipine',
          dosage: '5mg',
          section: 'MORNING',
          taken: true,
          takenOn: day,
          toBeTakenAt: DateTime(2026, 10, 20, 8),
        );

    test('a dose confirmed today shows as taken', () {
      final e = atToday(() =>
          MedicationMapper.toEntity(confirmedOn(DateTime(2026, 10, 23, 8, 5))));
      expect(e.taken, isTrue);
    });

    test('yesterday\'s confirmation does not carry over to today', () {
      final e = atToday(() =>
          MedicationMapper.toEntity(confirmedOn(DateTime(2026, 10, 22, 8, 5))));
      expect(e.taken, isFalse);
    });

    test('a server "taken" is stamped as today', () {
      final merged = atToday(() => MedicationMapper.mergeRemoteWithLocal(
          MedicationModel(
              id: 'srv-1',
              name: 'A',
              dosage: '5mg',
              purpose: '',
              toBeTakenAt: DateTime(2026, 10, 23, 8),
              taken: true),
          null,
          'MORNING'));
      expect(merged.takenOn, today);
    });
  });
}

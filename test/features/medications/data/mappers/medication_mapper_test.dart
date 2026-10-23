import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/features/medications/data/mappers/medication_mapper.dart';
import 'package:yelima/features/medications/domain/entities/medication_form.dart';
import 'package:yelima/features/medications/domain/entities/medication_section.dart';
import 'package:yelima/features/medications/domain/models/dosing_schedule_model.dart';
import 'package:yelima/features/medications/data/models/medication_model.dart';

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

  MedicationForm form(Map<MedicationSection, DoseSchedule> doses,
          {String dosage = '5mg', String notes = ''}) =>
      MedicationForm(
          name: 'Amlodipine', dosage: dosage, notes: notes, doses: doses);
  DoseSchedule at(int hour, [int minute = 0]) =>
      DoseSchedule(hour: hour, minute: minute, quantity: 1);

  group('rowsFor a new medication', () {
    test('creates one row per scheduled section with its local time', () {
      final rows = atToday(() => MedicationMapper.rowsFor(
          'local-1',
          form({
            MedicationSection.morning: at(8),
            MedicationSection.evening: at(21, 15),
          })));

      expect(rows.map((r) => (r.id, r.section, r.toBeTakenAt, r.taken)), [
        ('local-1', 'MORNING', DateTime(2026, 10, 23, 8), false),
        ('local-1', 'EVENING', DateTime(2026, 10, 23, 21, 15), false),
      ]);
      // Every row carries the full schedule, so any row can rebuild the details.
      expect(rows.every((r) => r.morningJson != null && r.eveningJson != null),
          isTrue);
      expect(rows.every((r) => r.afternoonJson == null), isTrue);
    });

    test('MED-EC-38: no schedule produces no rows', () {
      expect(MedicationMapper.rowsFor('l', form({})), isEmpty);
    });
  });

  group('rowsFor an edit', () {
    test('keeps each section\'s taken state and the original name', () {
      final rows = atToday(() => MedicationMapper.rowsFor(
            'm1',
            form({
              MedicationSection.morning: at(7),
              MedicationSection.evening: at(20)
            }, dosage: '10mg', notes: 'after food'),
            previous: [row('MORNING', taken: true), row('EVENING')],
          ));

      expect(rows.map((r) => (r.section, r.taken, r.dosage, r.name)), [
        ('MORNING', true, '10mg', 'Amlodipine'),
        ('EVENING', false, '10mg', 'Amlodipine'),
      ]);
      expect(rows.first.notes, 'after food');
    });

    test('a newly added section starts untaken', () {
      final rows = atToday(() => MedicationMapper.rowsFor(
            'm1',
            form({MedicationSection.afternoon: at(13)}),
            previous: [row('MORNING', taken: true)],
          ));

      expect(rows.single.section, 'AFTERNOON');
      expect(rows.single.taken, isFalse);
    });
  });

  test('the server request sends every slot in its 12-hour format', () {
    final json = MedicationMapper.toCreateModel(
        form({MedicationSection.evening: at(21, 15)})).toJson();
    expect(json['evening'], {
      'time': {'hour': 9, 'minutes': 15, 'timeDesignators': 'PM'},
      'quantity': {'value': 1, 'unit': 'tablet'},
    });
    expect(json.containsKey('morning'), isFalse);
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
          MedicationSection.morning));

      expect((merged.id, merged.taken, merged.notes),
          ('srv-1', true, 'after food'));
    });

    test('MED-EC-25: a time changed on the server replaces the local time', () {
      final merged = atToday(() => MedicationMapper.mergeRemoteWithLocal(
          remote(DateTime(2026, 10, 23, 9)),
          row('MORNING'),
          MedicationSection.morning));

      expect(merged.toBeTakenAt, DateTime(2026, 10, 23, 9));
    });

    test('MED-EC-40: a dose due right now keeps its real time', () {
      final merged = atToday(() => MedicationMapper.mergeRemoteWithLocal(
          remote(today), null, MedicationSection.afternoon));

      expect(merged.toBeTakenAt, today);
    });

    test('no time from the server keeps the local one, or the section default',
        () {
      final noTime = MedicationModel.fromJson(
          const {'id': 'srv-1', 'name': 'A', 'dosage': '5mg', 'taken': false});

      final keptLocal = atToday(() => MedicationMapper.mergeRemoteWithLocal(
          noTime, row('EVENING'), MedicationSection.evening));
      final fallback = atToday(() => MedicationMapper.mergeRemoteWithLocal(
          noTime, null, MedicationSection.evening));

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
          MedicationSection.morning));
      expect(merged.takenOn, today);
    });
  });
}

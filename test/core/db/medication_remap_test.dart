import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/db/app_database.dart';

import '../../helpers/fakes.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = testDb());
  tearDown(() => db.close());

  Medication row(String id, String section,
          {String? morningJson, String? notes, bool taken = false}) =>
      Medication(
        id: id,
        name: 'Amlodipine',
        dosage: '5mg',
        section: section,
        taken: taken,
        toBeTakenAt: DateTime(2026, 10, 23, 8),
        morningJson: morningJson,
        notes: notes,
      );

  Future<List<(String, String, String?, String?)>> rows() async =>
      (await db.select(db.medications).get())
          .map((m) => (m.id, m.section, m.morningJson, m.notes))
          .toList();

  test('moves every section row to the server id', () async {
    await db.medicationsDao
        .insertMedications([row('local', 'MORNING'), row('local', 'EVENING')]);

    await db.medicationsDao.updateMedicationId('local', 'srv');

    expect((await rows()).map((r) => (r.$1, r.$2)).toSet(),
        {('srv', 'MORNING'), ('srv', 'EVENING')});
  });

  test(
      'MED-EC-03: when server rows already exist, keeps the local schedule and notes',
      () async {
    await db.medicationsDao.insertMedications([
      row('local', 'MORNING', morningJson: '{"local":1}', notes: 'after food'),
      row('local', 'EVENING', morningJson: '{"local":1}', notes: 'after food'),
      row('srv', 'MORNING'), // inserted by a background fetch before the remap
    ]);

    await db.medicationsDao.updateMedicationId('local', 'srv');

    expect((await rows()).toSet(), {
      ('srv', 'MORNING', '{"local":1}', 'after food'),
      ('srv', 'EVENING', '{"local":1}', 'after food'),
    });
  });

  test('MED-EC-02: dose logs follow the medication to its server id', () async {
    await db.into(db.medicationLogs).insert(MedicationLogsCompanion.insert(
        id: 'log1',
        medicationId: 'local',
        takenAt: DateTime(2026, 10, 23),
        taken: true));

    await db.adherenceDao.updateLogsMedicationId('local', 'srv');

    final log = (await db.select(db.medicationLogs).get()).single;
    expect(log.medicationId, 'srv');
  });

  test('MED-EC-05: removes only one section of a medication', () async {
    await db.medicationsDao
        .insertMedications([row('m1', 'MORNING'), row('m1', 'EVENING')]);

    await db.medicationsDao.deleteMedicationSection('m1', 'MORNING');

    expect((await rows()).map((r) => r.$2), ['EVENING']);
  });

  test('MED-EC-04: removes the leftover UNKNOWN rows and says which', () async {
    await db.medicationsDao.insertMedications(
        [row('m1', 'MORNING'), row('m1', 'UNKNOWN'), row('m2', 'UNKNOWN')]);

    final removed = await db.medicationsDao.deleteUnknownSectionRows();

    expect(removed.toSet(), {'m1', 'm2'});
    expect((await rows()).map((r) => (r.$1, r.$2)), [('m1', 'MORNING')]);
  });
}

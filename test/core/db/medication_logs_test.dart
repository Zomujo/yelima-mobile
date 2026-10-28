import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/db/app_database.dart';

import '../../helpers/fakes.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = testDb());
  tearDown(() => db.close());

  MedicationLog log(String id, int day, {String med = 'm1'}) => MedicationLog(
      id: id,
      medicationId: med,
      takenAt: DateTime.utc(2026, 10, day),
      taken: false);

  test('a refetched month replaces its days even when the ids changed',
      () async {
    final october = DateTime(2026, 10, 15);
    await db.adherenceDao
        .replaceMonthLogs('m1', october, [log('a', 1), log('b', 2)]);
    await db.adherenceDao
        .replaceMonthLogs('m1', october, [log('x', 1), log('y', 2)]);

    final ids = (await db.adherenceDao.getLogsForMedication('m1'))
        .map((l) => l.id)
        .toSet();
    expect(ids, {'x', 'y'});
  });

  test('leaves other months and other medicines alone', () async {
    await db.adherenceDao.replaceMonthLogs(
        'm2', DateTime(2026, 10), [log('other', 3, med: 'm2')]);
    await db.adherenceDao.replaceMonthLogs('m1', DateTime(2026, 9), [
      MedicationLog(
          id: 'sep',
          medicationId: 'm1',
          takenAt: DateTime.utc(2026, 9, 30),
          taken: true)
    ]);

    await db.adherenceDao.replaceMonthLogs('m1', DateTime(2026, 10), []);

    expect((await db.adherenceDao.getLogsForMedication('m1')).single.id, 'sep');
    expect(
        (await db.adherenceDao.getLogsForMedication('m2')).single.id, 'other');
  });
}

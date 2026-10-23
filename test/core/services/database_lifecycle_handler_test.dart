import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/database_lifecycle_handler.dart';

import '../../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late DatabaseLifecycleHandler handler;

  setUp(() {
    db = testDb();
    handler = DatabaseLifecycleHandler(db);
  });

  tearDown(() => db.close());

  Future<int> rows(TableInfo table) async =>
      (await db.select(table).get()).length;

  test('CORE-EC-07: logout leaves no user data in any table', () async {
    await db
        .into(db.adherenceGlobals)
        .insert(AdherenceGlobalsCompanion.insert(id: 'global', rate: 0.8));
    await db.into(db.adherenceGlobalDays).insert(
        AdherenceGlobalDaysCompanion.insert(
            dateTakenStr: '2026-10-23', label: 'Fri', type: 'today'));
    await db.into(db.medicationLogs).insert(MedicationLogsCompanion.insert(
        id: 'log1',
        medicationId: 'm1',
        takenAt: DateTime(2026, 10, 23),
        taken: true));
    await db.pendingMutationsDao.queueMutation(
        entityId: 'e1', entityType: 'symptom', action: 'create', payload: {});

    await handler.onSessionEnded();

    for (final table in db.allTables) {
      expect(await rows(table), 0, reason: table.actualTableName);
    }
  });

  test('reports how many unsynced changes the wipe discarded', () async {
    final discarded = <int>[];
    handler = DatabaseLifecycleHandler(db, onDiscarded: discarded.add);
    for (final id in ['a', 'b']) {
      await db.pendingMutationsDao.queueMutation(
          entityId: id, entityType: 'symptom', action: 'create', payload: {});
    }

    await handler.onSessionEnded();

    expect(discarded, [2]);
  });

  test('says nothing when everything was synced', () async {
    final discarded = <int>[];
    handler = DatabaseLifecycleHandler(db, onDiscarded: discarded.add);

    await handler.onSessionEnded();

    expect(discarded, isEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/api/i_remote_mutation.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/vitals/data/datasources/vitals_remote_datasource.dart';
import 'package:yelima/features/vitals/data/datasources/vitals_remote_mutation_source.dart';
import 'package:yelima/features/vitals/data/models/vital_history_model.dart';
import 'package:yelima/features/vitals/data/repositories/vitals_repository_impl.dart';
import 'package:yelima/features/vitals/domain/entities/reading_form.dart';
import 'package:yelima/features/vitals/domain/reading_limits.dart';

import '../../../helpers/fake_api.dart';
import '../../../helpers/fakes.dart';

void main() {
  const logsPath = 'api/v1/client/vital-histories/logs';
  late AppDatabase db;
  late FakeApi api;

  Map<String, Object?> serverRow(String id, String value) => {
        'id': id,
        'vitalType': 'bloodPressure',
        'vitalName': 'Blood Pressure',
        'value': value,
        'unit': 'mmHg',
      };

  VitalHistoryModel reading(String id) => VitalHistoryModel(
        id: id,
        vitalType: 'bloodPressure',
        value: '150/95',
        unit: 'mmHg',
        severity: 'normal',
        vitalName: 'Blood Pressure',
        recordedAt: DateTime(2026, 10, 23, 8),
      );

  VitalsRepositoryImpl repo({bool online = true}) => VitalsRepositoryImpl(
        remoteDataSource: VitalsRemoteDataSource(apiClient: api.client),
        connectivityService: FakeConnectivity(online: online),
        session: SessionEpoch(),
        db: db,
      );

  Future<void> queueReading(String id) => db.pendingMutationsDao.queueMutation(
        entityId: id,
        entityType: 'vital_history',
        action: 'saveVitalReading',
        payload: {'vitalType': 'bloodPressure', 'value': '150/95'},
      );

  Future<Set<String>> storedIds() async =>
      (await repo().watchReadings().first).map((v) => v.id).toSet();

  void serverHas(List<Map<String, Object?>> rows) =>
      api.on('GET', logsPath, FakeReply.ok({'rows': rows}));

  setUp(() {
    db = testDb();
    api = FakeApi();
  });

  tearDown(() => db.close());

  test('VIT-EC-01: an unsynced reading survives a refresh from the server',
      () async {
    await db.vitalsDao.insertVitals([reading('3f2b9c1e-uuid').toDrift()]);
    await queueReading('3f2b9c1e-uuid');
    serverHas([serverRow('srv-1', '120/80')]);

    await repo().refresh();

    expect(await storedIds(), {'3f2b9c1e-uuid', 'srv-1'});
  });

  test('a synced reading is replaced by the server list', () async {
    await db.vitalsDao.insertVitals([reading('old-local').toDrift()]);
    serverHas([serverRow('srv-1', '120/80')]);

    await repo().refresh();

    expect(await storedIds(), {'srv-1'});
  });

  test('older server rows without a grade count as normal', () async {
    serverHas([serverRow('srv-1', '120/80')]);

    await repo().refresh();

    expect((await repo().watchReadings().first).single.severity, 'normal');
  });

  test('VIT-EC-25: replay returns the server id and sends the idempotency key',
      () async {
    api.on('POST', logsPath,
        FakeReply.ok('665f00000000000000000001', status: 201));
    final source = VitalsRemoteMutationSource(
        VitalsRemoteDataSource(apiClient: api.client), db);

    final id = await source.syncMutation(
      entityId: 'local-1',
      action: 'saveVitalReading',
      payloadJson: '{"vitalType":"bloodPressure","value":"150/95"}',
      createdAt: DateTime(2026, 10, 23),
    );

    expect(id, '665f00000000000000000001');
    expect(api.sent('POST', logsPath).single.headers['Idempotency-Key'],
        'local-1');
  });

  test(
      'VIT-EC-25: after sync the local reading takes its server id, no duplicate',
      () async {
    await db.vitalsDao.insertVitals([reading('local-1').toDrift()]);
    await queueReading('local-1');
    api.on('POST', logsPath, FakeReply.ok('srv-9', status: 201));
    final manager = MutationSyncManager(
      connectivityService: FakeConnectivity(),
      db: db,
      remoteSources: <String, IRemoteMutationSource>{
        'vital_history': VitalsRemoteMutationSource(
            VitalsRemoteDataSource(apiClient: api.client), db),
      },
    );
    await manager.onSessionStarted('user_1');

    await manager.triggerSync();
    expect(await storedIds(), {'srv-9'}, reason: 'remapped right after sync');

    // A refresh that already includes the reading must not show it twice.
    serverHas([serverRow('srv-9', '150/95')]);
    await repo().refresh();
    expect(await storedIds(), {'srv-9'});
    expect(await db.select(db.pendingMutations).get(), isEmpty);
    manager.dispose();
  });

  group('saveReading', () {
    ReadingForm bp(int sys, int dia) => ReadingForm(
        kind: VitalKind.bloodPressure,
        systolic: sys,
        diastolic: dia,
        sugarLevel: 0,
        recordedAt: DateTime(2026, 10, 23, 8));

    test('offline, stores the reading and its queued sync together', () async {
      db.pendingMutationsDao.owner = 'user_1';

      await repo(online: false).saveReading(bp(150, 95));

      final stored = (await repo().watchReadings().first).single;
      final queued = (await db.select(db.pendingMutations).get()).single;
      expect((queued.entityId, queued.ownerUid), (stored.id, 'user_1'));
      expect(api.requests, isEmpty);
    });

    test('online, sends it and keeps it without queueing', () async {
      api.on('POST', logsPath, FakeReply.ok('srv-1', status: 201));

      await repo().saveReading(bp(150, 95));

      expect(await db.select(db.pendingMutations).get(), isEmpty);
      expect((await repo().watchReadings().first).length, 1);
    });

    test('a server error queues it and still counts as saved', () async {
      api.on('POST', logsPath, FakeReply.error(500));

      final result = await repo().saveReading(bp(150, 95));

      expect(result.isRight(), isTrue);
      expect((await db.select(db.pendingMutations).get()).length, 1);
    });

    test('VIT-EC-11: an impossible reading is refused and not stored',
        () async {
      final result = await repo().saveReading(bp(90, 120));

      expect(result.getLeft().toNullable(),
          const ReadingFailure(ReadingError.systolicNotAboveDiastolic));
      expect(await storedIds(), isEmpty);
    });

    test('a lost login is reported, with the reading kept and queued',
        () async {
      api.on('POST', logsPath, FakeReply.error(401));

      final result = await repo().saveReading(bp(150, 95));

      expect(result.getLeft().toNullable(), const UnauthorizedFailure());
      expect((await db.select(db.pendingMutations).get()).length, 1);
    });
  });
}

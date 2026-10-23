import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/api/i_remote_mutation.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/features/home/data/datasources/home_metrics_local_datasource.dart';
import 'package:yelima/features/home/data/datasources/home_metrics_remote_mutation_source.dart';
import 'package:yelima/features/home/data/models/vital_history_model.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/home/data/datasources/home_metrics_remote_datasource.dart';
import 'package:yelima/features/home/data/repositories/home_metrics_repository_impl.dart';

import '../../../helpers/fake_api.dart';
import '../../../helpers/fakes.dart';

void main() {
  const logsPath = 'api/v1/client/vital-histories/logs';
  late AppDatabase db;
  late HomeMetricsLocalDataSourceImpl local;

  VitalHistoryModel reading(String id, String value) => VitalHistoryModel(
        id: id,
        vitalType: 'bloodPressure',
        value: value,
        unit: 'mmHg',
        severity: 'normal',
        vitalName: 'Blood Pressure',
        recordedAt: DateTime(2026, 10, 23, 8),
      );

  Future<void> queueReading(String id) => db.pendingMutationsDao.queueMutation(
        entityId: id,
        entityType: 'vital_history',
        action: 'saveVitalReading',
        payload: {'vitalType': 'bloodPressure', 'value': '150/95'},
      );

  Future<Set<String>> storedIds() async =>
      (await local.getCachedVitalHistories()).map((v) => v.id).toSet();

  setUp(() {
    db = testDb();
    local = HomeMetricsLocalDataSourceImpl(database: db);
  });

  tearDown(() => db.close());

  test('VIT-EC-01: an unsynced reading survives a refresh from the server',
      () async {
    await local.appendVitalHistory(reading('3f2b9c1e-uuid', '150/95'));
    await queueReading('3f2b9c1e-uuid');

    await local.cacheVitalHistories([reading('srv-1', '120/80')]);

    expect(await storedIds(), {'3f2b9c1e-uuid', 'srv-1'});
  });

  test('a synced reading is replaced by the server list', () async {
    await local.appendVitalHistory(reading('old-local', '150/95'));

    await local.cacheVitalHistories([reading('srv-1', '120/80')]);

    expect(await storedIds(), {'srv-1'});
  });

  test('VIT-EC-25: replay returns the server id and sends the idempotency key',
      () async {
    final api = FakeApi()
      ..on('POST', logsPath,
          FakeReply.ok('665f00000000000000000001', status: 201));
    final source = HomeMetricsRemoteMutationSource(api.client);

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
    await local.appendVitalHistory(reading('local-1', '150/95'));
    await queueReading('local-1');
    final api = FakeApi()
      ..on('POST', logsPath, FakeReply.ok('srv-9', status: 201));
    final manager = MutationSyncManager(
      connectivityService: FakeConnectivity(),
      db: db,
      remoteSources: <String, IRemoteMutationSource>{
        'vital_history': HomeMetricsRemoteMutationSource(api.client),
      },
    );
    await manager.onSessionStarted('user_1');

    await manager.triggerSync();
    expect(await storedIds(), {'srv-9'}, reason: 'remapped right after sync');

    // A refresh that already includes the reading must not show it twice.
    await local.cacheVitalHistories([reading('srv-9', '150/95')]);
    expect(await storedIds(), {'srv-9'});
    expect(await db.select(db.pendingMutations).get(), isEmpty);
    manager.dispose();
  });

  test('an offline save stores the reading and its queued sync together',
      () async {
    db.pendingMutationsDao.owner = 'user_1';
    final api = FakeApi();
    final repo = HomeMetricsRepositoryImpl(
      remoteDataSource: HomeMetricsRemoteDataSourceImpl(apiClient: api.client),
      localDataSource: local,
      connectivityService: FakeConnectivity(online: false),
      session: SessionEpoch(),
      db: db,
    );

    await repo.saveVitalReading(reading('local-7', '150/95'));

    expect(await storedIds(), {'local-7'});
    final queued = (await db.select(db.pendingMutations).get()).single;
    expect((queued.entityId, queued.ownerUid), ('local-7', 'user_1'));
    expect(api.requests, isEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/api/i_remote_mutation.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/symptoms/data/datasources/symptoms_remote_data_source.dart';
import 'package:yelima/features/symptoms/data/datasources/symptoms_remote_mutation_source.dart';
import 'package:yelima/features/symptoms/data/repositories/symptoms_repository_impl.dart';

import '../../../helpers/fake_api.dart';
import '../../../helpers/fakes.dart';

void main() {
  const path = 'api/v1/client/symptoms';
  late AppDatabase db;
  late FakeApi api;
  late FakeConnectivity connectivity;
  late SessionEpoch session;
  late SymptomsRepositoryImpl repo;

  Map<String, dynamic> serverSymptom(String id, String text) =>
      {'id': id, 'description': text, 'onsetDate': '2026-10-23T08:00:00.000Z'};

  Future<List<String>> storedIds() async =>
      (await db.select(db.symptoms).get()).map((s) => s.id).toList();

  setUp(() {
    db = testDb()..pendingMutationsDao.owner = 'user_1';
    api = FakeApi();
    connectivity = FakeConnectivity(online: false);
    session = SessionEpoch();
    repo = SymptomsRepositoryImpl(
      remoteDataSource: SymptomsRemoteDataSource(apiClient: api.client),
      connectivityService: connectivity,
      db: db,
      session: session,
    );
  });

  tearDown(() => db.close());

  test('an offline symptom is stored and queued together', () async {
    final id = (await repo.createSymptom('Headache')).getOrElse((_) => '');

    expect(await storedIds(), [id]);
    final queued = (await db.select(db.pendingMutations).get()).single;
    expect((queued.entityId, queued.entityType, queued.ownerUid),
        (id, 'symptom', 'user_1'));
  });

  test('SYM-EC-01: a refresh keeps a symptom that has not synced yet',
      () async {
    final offlineId =
        (await repo.createSymptom('Headache')).getOrElse((_) => '');
    connectivity.online = true;
    api.on(
        'GET',
        path,
        FakeReply.ok({
          'rows': [serverSymptom('srv-1', 'Dizzy')]
        }));

    await repo.refresh();

    expect((await storedIds()).toSet(), {offlineId, 'srv-1'});
  });

  test('SYM-EC-03: after sync the symptom takes its server id, no duplicate',
      () async {
    final offlineId =
        (await repo.createSymptom('Headache')).getOrElse((_) => '');
    connectivity.online = true;
    api
      ..on('POST', path, FakeReply.ok('srv-9', status: 201))
      ..on(
          'GET',
          path,
          FakeReply.ok({
            'rows': [serverSymptom('srv-9', 'Headache')]
          }));
    final manager = MutationSyncManager(
      connectivityService: connectivity,
      db: db,
      remoteSources: <String, IRemoteMutationSource>{
        'symptom': SymptomsRemoteMutationSource(
            SymptomsRemoteDataSource(apiClient: api.client), db),
      },
    );
    await manager.onSessionStarted('user_1');
    await manager.triggerSync();

    expect(await storedIds(), ['srv-9'], reason: 'remapped from $offlineId');
    await repo.refresh();
    expect(await storedIds(), ['srv-9']);
    manager.dispose();
  });

  test(
      'SYM-EC-09: a new session does not reuse the previous user\'s fresh cache',
      () async {
    connectivity.online = true;
    api.on(
        'GET',
        path,
        FakeReply.ok({
          'rows': [serverSymptom('a-1', 'A')]
        }));
    await repo.refresh();

    await session.onSessionEnded();
    await db.delete(db.symptoms).go(); // logout wipe
    api.on(
        'GET',
        path,
        FakeReply.ok({
          'rows': [serverSymptom('b-1', 'B')]
        }));
    await repo.refresh();

    expect(await storedIds(), ['b-1']);
  });

  test('a second refresh within 5 minutes is skipped, unless forced', () async {
    connectivity.online = true;
    api.on('GET', path, FakeReply.ok({'rows': []}));

    await repo.refresh();
    await repo.refresh();
    expect(api.sent('GET', path).length, 1);

    await repo.refresh(force: true);
    expect(api.sent('GET', path).length, 2);
  });

  test('online, a symptom gets its server id straight away', () async {
    connectivity.online = true;
    api.on('POST', path, FakeReply.ok('srv-1', status: 201));

    final id = (await repo.createSymptom('Headache')).getOrElse((_) => '');

    expect(id, 'srv-1');
    expect(await storedIds(), ['srv-1']);
    expect(await db.select(db.pendingMutations).get(), isEmpty);
  });
}

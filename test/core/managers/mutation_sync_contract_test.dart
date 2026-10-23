import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/api/i_remote_mutation.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';

import '../../helpers/fakes.dart';

class MockSource extends Mock implements IRemoteMutationSource {}

void main() {
  late AppDatabase db;
  late MockSource source;
  late MutationSyncManager manager;
  late List<String> broadcasts;

  /// Stubs the source; [reply] maps (entityId, action) to the returned server id.
  void stubSource(String? Function(String entityId, String action) reply) {
    when(() => source.syncMutation(
              entityId: any(named: 'entityId'),
              action: any(named: 'action'),
              payloadJson: any(named: 'payloadJson'),
              createdAt: any(named: 'createdAt'),
            ))
        .thenAnswer((i) async => reply(i.namedArguments[#entityId] as String,
            i.namedArguments[#action] as String));
  }

  Future<void> queue(String entityId, String action,
          {String type = 'medication'}) =>
      db.pendingMutationsDao.queueMutation(
          entityId: entityId,
          entityType: type,
          action: action,
          payload: {'a': 1});

  List<String> calls() => verify(() => source.syncMutation(
        entityId: captureAny(named: 'entityId'),
        action: captureAny(named: 'action'),
        payloadJson: any(named: 'payloadJson'),
        createdAt: any(named: 'createdAt'),
      )).captured.cast<String>();

  setUp(() async {
    db = testDb();
    source = MockSource();
    manager = MutationSyncManager(
      connectivityService: FakeConnectivity(),
      db: db,
      remoteSources: {'medication': source},
    );
    broadcasts = [];
    manager.onMutationSynced.listen(broadcasts.add);
    await manager.onSessionStarted('user_1');
    await manager.triggerSync(); // let the session-start sync settle
  });

  tearDown(() async {
    manager.dispose();
    await db.close();
  });

  test('a create remap rewrites queued follow-ups to the server id', () async {
    await queue('local-1', 'createMedication');
    await queue('local-1', 'updateMedication');
    stubSource((id, action) => action == 'createMedication' ? 'srv-1' : id);

    await manager.triggerSync();

    expect(
        calls(), ['local-1', 'createMedication', 'srv-1', 'updateMedication']);
    expect(broadcasts, contains('remap:medication:local-1:srv-1'));
    expect(await db.select(db.pendingMutations).get(), isEmpty);
  });

  test('a rejected item blocks later items for the same entity only', () async {
    await queue('med-a', 'createMedication');
    await queue('med-a', 'updateMedication');
    await queue('med-b', 'updateMedication');
    when(() => source.syncMutation(
          entityId: 'med-a',
          action: any(named: 'action'),
          payloadJson: any(named: 'payloadJson'),
          createdAt: any(named: 'createdAt'),
        )).thenThrow(const ApiException('Bad request', code: '400'));
    when(() => source.syncMutation(
          entityId: 'med-b',
          action: any(named: 'action'),
          payloadJson: any(named: 'payloadJson'),
          createdAt: any(named: 'createdAt'),
        )).thenAnswer((_) async => 'med-b');

    await manager.triggerSync();

    expect(calls(), ['med-a', 'createMedication', 'med-b', 'updateMedication']);
    final left = await db.select(db.pendingMutations).get();
    expect(left.map((m) => (m.entityId, m.action)),
        [('med-a', 'createMedication'), ('med-a', 'updateMedication')]);
  });

  test('nothing syncs before the session starts', () async {
    await manager.onSessionEnded();
    await queue('med-a', 'updateMedication');
    stubSource((id, _) => id);

    await manager.triggerSync();

    verifyNever(() => source.syncMutation(
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          payloadJson: any(named: 'payloadJson'),
          createdAt: any(named: 'createdAt'),
        ));
  });

  test('CORE-EC-19: a 404 on deleteMedication counts as already deleted',
      () async {
    await queue('srv-9', 'deleteMedication');
    when(() => source.syncMutation(
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          payloadJson: any(named: 'payloadJson'),
          createdAt: any(named: 'createdAt'),
        )).thenThrow(const ApiException('Not found', code: '404'));

    await manager.triggerSync();

    expect(await db.select(db.pendingMutations).get(), isEmpty);
  });

  test('CORE-EC-04: every queued entity type has a registered sync source', () {
    final queued = <String>{};
    for (final f
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      queued.addAll(RegExp(r"entityType: '(\w+)'")
          .allMatches(f.readAsStringSync())
          .map((m) => m.group(1)!));
    }
    final injection = File('lib/core/core_injection.dart').readAsStringSync();
    final syncBlock =
        injection.substring(injection.indexOf('MutationSyncManager('));
    final registered = RegExp(r"'(\w+)': sl<")
        .allMatches(syncBlock)
        .map((m) => m.group(1)!)
        .toSet();

    expect(queued.difference(registered), isEmpty);
  });

  group('failed list and retries', () {
    Future<List<(String, int)>> queued() async =>
        (await db.select(db.pendingMutations).get())
            .map((m) => (m.entityId, m.retryCount))
            .toList();

    test('MED-EC-24: a 5xx on one item no longer stops the rest of the queue',
        () async {
      await queue('med-a', 'updateMedication');
      await queue('med-b', 'updateMedication');
      when(() => source.syncMutation(
            entityId: 'med-a',
            action: any(named: 'action'),
            payloadJson: any(named: 'payloadJson'),
            createdAt: any(named: 'createdAt'),
          )).thenThrow(const ApiException('Server error', code: '500'));
      when(() => source.syncMutation(
            entityId: 'med-b',
            action: any(named: 'action'),
            payloadJson: any(named: 'payloadJson'),
            createdAt: any(named: 'createdAt'),
          )).thenAnswer((_) async => 'med-b');

      await manager.triggerSync();

      expect(await queued(), [('med-a', 1)],
          reason: 'med-b synced, med-a counts one failed try');
    });

    test('a network error still stops the batch without counting a try',
        () async {
      await queue('med-a', 'updateMedication');
      await queue('med-b', 'updateMedication');
      when(() => source.syncMutation(
            entityId: any(named: 'entityId'),
            action: any(named: 'action'),
            payloadJson: any(named: 'payloadJson'),
            createdAt: any(named: 'createdAt'),
          )).thenThrow(const NetworkException());

      await manager.triggerSync();

      expect(await queued(), [('med-a', 0), ('med-b', 0)]);
    });

    test('a rejected item shows in the failed list and can be retried',
        () async {
      await queue('med-a', 'updateMedication');
      when(() => source.syncMutation(
            entityId: any(named: 'entityId'),
            action: any(named: 'action'),
            payloadJson: any(named: 'payloadJson'),
            createdAt: any(named: 'createdAt'),
          )).thenThrow(const ApiException('Bad request', code: '400'));
      await manager.triggerSync();

      final failed = await db.pendingMutationsDao.getFailedMutations();
      expect(failed.map((m) => m.entityId), ['med-a']);

      stubSource((id, _) => id);
      await manager.retryFailed(failed.single.id);

      expect(await queued(), isEmpty);
      expect(await db.pendingMutationsDao.getFailedMutations(), isEmpty);
    });

    test('a failed item can be discarded', () async {
      await queue('med-a', 'updateMedication');
      final id = (await db.select(db.pendingMutations).get()).single.id;
      await db.pendingMutationsDao.markRejected(id);

      await manager.discardFailed(id);

      expect(await queued(), isEmpty);
    });

    test('counts waiting and failed changes for the badge', () async {
      final waiting = db.pendingMutationsDao.watchWaitingCount();
      final failedCount = db.pendingMutationsDao.watchFailedCount();

      await queue('med-a', 'updateMedication');
      await queue('med-b', 'updateMedication');
      final id = (await db.select(db.pendingMutations).get()).first.id;
      await db.pendingMutationsDao.markRejected(id);

      expect(await waiting.first, 1);
      expect(await failedCount.first, 1);
    });

    test('retries on its own after a server error, then stops', () async {
      manager.dispose();
      manager = MutationSyncManager(
        connectivityService: FakeConnectivity(),
        db: db,
        remoteSources: {'medication': source},
        retryDelays: const [Duration(milliseconds: 10)],
      );
      await manager.onSessionStarted('user_1');
      await queue('med-a', 'updateMedication');
      var calls = 0;
      when(() => source.syncMutation(
            entityId: any(named: 'entityId'),
            action: any(named: 'action'),
            payloadJson: any(named: 'payloadJson'),
            createdAt: any(named: 'createdAt'),
          )).thenAnswer((_) async {
        if (++calls == 1) throw const ApiException('Server error', code: '503');
        return 'med-a';
      });

      await manager.triggerSync();
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(calls, 2);
      expect(await queued(), isEmpty);
    });
  });

  group('CORE-EC-03: queued changes belong to the user who made them', () {
    test('a change queued in a session is tagged with that user', () async {
      await queue('med-a', 'updateMedication');

      final row = (await db.select(db.pendingMutations).get()).single;
      expect(row.ownerUid, 'user_1');
    });

    test(
        'another user\'s leftover changes are dropped, never sent with this login',
        () async {
      stubSource((id, _) => id);
      await queue('med-a', 'updateMedication'); // user_1
      await manager.onSessionEnded();
      final discarded = <int>[];
      manager.onDiscarded = discarded.add;

      await manager.onSessionStarted('user_2');
      await manager.triggerSync();

      verifyNever(() => source.syncMutation(
            entityId: any(named: 'entityId'),
            action: any(named: 'action'),
            payloadJson: any(named: 'payloadJson'),
            createdAt: any(named: 'createdAt'),
          ));
      expect(await db.select(db.pendingMutations).get(), isEmpty);
      expect(discarded, [1]);
    });

    test(
        'rows from before the upgrade (no owner) still sync for the signed-in user',
        () async {
      stubSource((id, _) => id);
      await db
          .into(db.pendingMutations)
          .insert(PendingMutationsCompanion.insert(
            id: 'legacy',
            entityType: 'medication',
            entityId: 'med-old',
            action: 'updateMedication',
            payloadJson: '{}',
            createdAt: DateTime(2026, 10, 1),
          ));

      await manager.triggerSync();

      expect(calls(), ['med-old', 'updateMedication']);
    });
  });

  test('CORE-EC-16: a change queued during a sync is sent in the same run',
      () async {
    await queue('med-a', 'updateMedication');
    var first = true;
    stubSource((id, _) {
      if (first) {
        first = false;
        queue('med-b', 'updateMedication'); // the user saves again mid-sync
      }
      return id;
    });

    await manager.triggerSync();

    expect(calls(), ['med-a', 'updateMedication', 'med-b', 'updateMedication']);
    expect(await db.select(db.pendingMutations).get(), isEmpty);
  });
}

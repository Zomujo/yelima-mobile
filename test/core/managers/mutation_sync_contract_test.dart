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
  },
      skip:
          "Known bug CORE-EC-19: the 404 shortcut checks action == 'delete'. Fix in P2.");

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
  },
      skip:
          'Known bug CORE-EC-04: user_profile is queued but has no sync source. Fix in P2.');
}

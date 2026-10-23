import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/api/i_remote_mutation.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/features/chat/data/datasources/ai_chat_remote_datasource.dart';
import 'package:yelima/features/chat/data/datasources/ai_chat_remote_mutation_source.dart';

import '../../../../helpers/fakes.dart';

class MockChatRemote extends Mock implements AiChatRemoteDataSource {}

void main() {
  late AppDatabase db;
  late MockChatRemote remote;
  late AiChatRemoteMutationSource source;

  setUp(() {
    db = testDb();
    remote = MockChatRemote();
    source = AiChatRemoteMutationSource(remote, db);
    when(() =>
            remote.sendMessage(any(), localChatId: any(named: 'localChatId')))
        .thenAnswer((_) async => {
              'inResponse': {'_id': 'srv-user'},
              'outResponse': {
                '_id': 'srv-bot',
                'text': 'Drink water',
                'suggestions': ['Why?']
              },
            });
  });

  tearDown(() => db.close());

  Future<void> insertLocalUserMessage(String id) => db.aiChatDao.insertAiChats([
        AiChatConversationsCompanion.insert(
          id: id,
          sender: 'user',
          type: 'text',
          value: 'Hello',
          createdAt: DateTime(2026, 10, 23),
          status: 'sending',
          localChatId: drift.Value(id),
        ),
      ]);

  test(
      'CHAT-EC-13: replay returns the user message\'s server id, not the bot\'s',
      () async {
    final id = await source.syncMutation(
      entityId: 'local-1',
      action: 'sendMessage',
      payloadJson: jsonEncode({'message': 'Hello', 'localChatId': 'local-1'}),
      createdAt: DateTime(2026, 10, 23),
    );

    expect(id, 'srv-user');
    final rows = await db.select(db.aiChatConversations).get();
    expect(rows.single.id, 'srv-bot');
    expect(rows.single.value, 'Drink water');
    expect(rows.single.localChatId, 'local-1');
  });

  test('CHAT-EC-13: after sync the local user message carries its server id',
      () async {
    await insertLocalUserMessage('local-1');
    await db.pendingMutationsDao.queueMutation(
      entityId: 'local-1',
      entityType: 'chat',
      action: 'sendMessage',
      payload: {'message': 'Hello', 'localChatId': 'local-1'},
    );
    final manager = MutationSyncManager(
      connectivityService: FakeConnectivity(),
      db: db,
      remoteSources: <String, IRemoteMutationSource>{'chat': source},
    );
    final broadcasts = <String>[];
    manager.onMutationSynced.listen(broadcasts.add);
    await manager.onSessionStarted('user_1');

    await manager.triggerSync();

    final ids = (await db.select(db.aiChatConversations).get())
        .map((r) => r.id)
        .toSet();
    expect(ids, {'srv-user', 'srv-bot'});
    expect(broadcasts, contains('remap:chat:local-1:srv-user'));
    expect(await db.select(db.pendingMutations).get(), isEmpty);
    manager.dispose();
  });
}

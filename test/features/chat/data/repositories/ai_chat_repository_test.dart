import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/managers/deletion_sync_manager.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/file_service.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/chat/data/datasources/ai_chat_local_datasource.dart';
import 'package:yelima/features/chat/data/datasources/ai_chat_remote_datasource.dart';
import 'package:yelima/features/chat/data/repositories/ai_chat_repository_impl.dart';
import 'package:yelima/features/chat/data/services/audio_cache.dart';

import '../../../../helpers/fake_api.dart';
import '../../../../helpers/fakes.dart';

class MockSync extends Mock implements MutationSyncManager {}

class MockDeletions extends Mock implements DeletionSyncManager {}

class MockFiles extends Mock implements FileService {}

void main() {
  const chatPath = 'api/v1/client/chat';
  late AppDatabase db;
  late FakeApi api;

  AiChatRepositoryImpl repo({bool online = true}) {
    final sync = MockSync();
    when(() => sync.triggerSync()).thenAnswer((_) async {});
    return AiChatRepositoryImpl(
      localDataSource: AiChatLocalDataSource(db),
      remoteDataSource: AiChatRemoteDataSource(api.client),
      deletionSyncManager: MockDeletions(),
      connectivityService: FakeConnectivity(online: online),
      mutationSyncManager: sync,
      fileService: MockFiles(),
      audioCache: AudioCache(db),
      session: SessionEpoch(),
    );
  }

  Future<int> queued() async =>
      (await db.select(db.pendingMutations).get()).length;

  setUp(() {
    db = testDb();
    api = FakeApi();
  });

  tearDown(() => db.close());

  test('a send returns the user message id and the bot answer', () async {
    api.on(
        'POST',
        chatPath,
        FakeReply.ok({
          'inResponse': {'_id': 'srv-user'},
          'outResponse': {
            '_id': 'srv-bot',
            'text': 'Drink water',
            'suggestions': ['Why?']
          },
        }));

    final reply = (await repo().sendMessage('Hello', localChatId: 'l-1'))
        .getOrElse((f) => throw f);

    expect(reply.userMessageId, 'srv-user');
    expect((reply.bot?.id, reply.bot?.value), ('srv-bot', 'Drink water'));
    expect(reply.bot?.suggestions, ['Why?']);
    expect(reply.bot?.localChatId, 'l-1');
    expect(await queued(), 0);
  });

  test('offline, the send is queued', () async {
    final reply = (await repo(online: false).sendMessage('Hello'))
        .getOrElse((f) => throw f);

    expect(reply.bot, isNull);
    expect(await queued(), 1);
    expect(api.requests, isEmpty);
  });

  test('a server error queues the send to retry', () async {
    api.on('POST', chatPath, FakeReply.error(500));

    final result = await repo().sendMessage('Hello');

    expect(result.isRight(), isTrue);
    expect(await queued(), 1);
  });

  test('a lost login is reported and nothing is queued', () async {
    api.on('POST', chatPath, FakeReply.error(401));

    final result = await repo().sendMessage('Hello');

    expect(result.getLeft().toNullable(), const UnauthorizedFailure());
    expect(await queued(), 0);
  });

  test('the greeting is read from the empty send', () async {
    api.on(
        'POST',
        chatPath,
        FakeReply.ok({
          'outResponse': {'_id': 'hi', 'text': 'Hello! How are you?'}
        }));

    final greeting = (await repo().loadInitialMessage()).toNullable();

    expect((greeting?.id, greeting?.sender), ('hi', 'bot'));
  });
}

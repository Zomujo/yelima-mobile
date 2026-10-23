import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/api/i_remote_deletion.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import 'package:yelima/core/managers/deletion_sync_manager.dart';

import '../../helpers/fakes.dart';

class MockSource extends Mock implements IRemoteDeletionSource {}

void main() {
  late AppDatabase db;
  late MockSource source;
  late DeletionSyncManager manager;

  setUp(() async {
    db = testDb();
    source = MockSource();
    manager = DeletionSyncManager(
        connectivityService: FakeConnectivity(),
        db: db,
        remoteSources: {'chat': source});
    await manager.onSessionStarted('user_1');
    await db.aiChatDao.insertPendingDeletion('m1', 'chat');
  });

  tearDown(() async {
    manager.dispose();
    await db.close();
  });

  Future<int> waiting() async =>
      (await db.aiChatDao.getPendingDeletions()).length;

  test('a deletion that reaches the server leaves the queue', () async {
    when(() => source.deleteMessage('m1')).thenAnswer((_) async {});

    await manager.triggerSync();

    expect(await waiting(), 0);
  });

  test('a message already gone (404) leaves the queue', () async {
    when(() => source.deleteMessage('m1'))
        .thenThrow(const ApiException('gone', code: '404'));

    await manager.triggerSync();

    expect(await waiting(), 0);
  });

  for (final (name, error) in [
    ('a server error', const ApiException('down', code: '503')),
    ('a lost login', const ApiException('no', code: '401')),
    ('no connection', const NetworkException()),
    ('another 4xx', const ApiException('bad', code: '422')),
  ]) {
    test('$name keeps the deletion queued', () async {
      when(() => source.deleteMessage('m1')).thenThrow(error);

      await manager.triggerSync();

      expect(await waiting(), 1);
    });
  }
}

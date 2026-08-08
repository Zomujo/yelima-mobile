import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/api/i_remote_mutation.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/connectivity_service.dart';
import 'package:drift/native.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import 'dart:async';

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockRemoteMutationSource extends Mock implements IRemoteMutationSource {}

void main() {
  late AppDatabase memoryDb;
  late MockConnectivityService mockConnectivityService;
  late MockRemoteMutationSource mockRemoteSource;
  late MutationSyncManager syncManager;

  setUp(() {
    memoryDb = AppDatabase(executor: NativeDatabase.memory());
    mockConnectivityService = MockConnectivityService();
    mockRemoteSource = MockRemoteMutationSource();

    when(() => mockConnectivityService.isConnected)
        .thenAnswer((_) async => true);

    // Provide a dummy stream for onConnectivityChanged
    when(() => mockConnectivityService.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());

    syncManager = MutationSyncManager(
      connectivityService: mockConnectivityService,
      db: memoryDb,
      remoteSources: {
        'test_entity': mockRemoteSource,
      },
    );
  });

  tearDown(() async {
    syncManager.dispose();
    await memoryDb.close();
  });

  test('should block mutation on 400 without deleting it', () async {
    // 1. Arrange: Insert a pending mutation
    await memoryDb.pendingMutationsDao.queueMutation(
      entityId: 'ent_123',
      entityType: 'test_entity',
      action: 'update',
      payload: {'data': 'test'},
    );

    // Make the remote source throw a 400 ApiException
    when(() => mockRemoteSource.syncMutation(
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          payloadJson: any(named: 'payloadJson'),
          createdAt: any(named: 'createdAt'),
        )).thenThrow(const ApiException('Bad request', code: '400'));

    // Start session to allow sync
    await syncManager.onSessionStarted('user_1');

    // 2. Act: Trigger sync manually
    await syncManager.triggerSync();

    // 3. Assert: Verify the mutation is still in the DB but blocked (retryCount maxed)
    final allMutations = await memoryDb.select(memoryDb.pendingMutations).get();
    expect(allMutations.length, 1);
    expect(allMutations.first.retryCount, 9999);

    // And it should no longer be fetched by getAllPendingMutations (which filters < 3)
    final syncableMutations =
        await memoryDb.pendingMutationsDao.getAllPendingMutations();
    expect(syncableMutations.isEmpty, true);
  });

  test('should gracefully handle 3 sequential failures by blocking', () async {
    // 1. Arrange: Insert a pending mutation
    await memoryDb.pendingMutationsDao.queueMutation(
      entityId: 'ent_456',
      entityType: 'test_entity',
      action: 'update',
      payload: {'data': 'test2'},
    );

    // Make the remote source throw a general Exception (e.g. 500 or timeout)
    when(() => mockRemoteSource.syncMutation(
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          payloadJson: any(named: 'payloadJson'),
          createdAt: any(named: 'createdAt'),
        )).thenThrow(Exception('General server failure'));

    await syncManager.onSessionStarted('user_1');

    // 2. Act: Trigger sync 3 times to exhaust retries
    // Actually, syncManager loop will try once per syncTask. We trigger it 3 times.
    await syncManager.triggerSync(); // attempt 1 -> retryCount = 1

    // We need to wait a tick because triggerSync prevents overlap, but here it finishes
    await Future.delayed(const Duration(milliseconds: 10));
    await syncManager.triggerSync(); // attempt 2 -> retryCount = 2

    await Future.delayed(const Duration(milliseconds: 10));
    await syncManager.triggerSync(); // attempt 3 -> retryCount = 3 (blocked)

    // 3. Assert
    final allMutations = await memoryDb.select(memoryDb.pendingMutations).get();
    expect(allMutations.length, 1);
    expect(allMutations.first.retryCount, 3);

    final syncableMutations =
        await memoryDb.pendingMutationsDao.getAllPendingMutations();
    expect(
        syncableMutations.isEmpty, true); // Since retryCount >= 3, it's ignored
  });

  test('should sync and resolve successfully', () async {
    await memoryDb.pendingMutationsDao.queueMutation(
      entityId: 'ent_789',
      entityType: 'test_entity',
      action: 'update',
      payload: {'data': 'test3'},
    );

    when(() => mockRemoteSource.syncMutation(
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          payloadJson: any(named: 'payloadJson'),
          createdAt: any(named: 'createdAt'),
        )).thenAnswer((_) async => 'ent_789'); // Returns the same ID

    await syncManager.onSessionStarted('user_1');
    await syncManager.triggerSync();

    // Verify it was deleted from DB upon success
    final allMutations = await memoryDb.select(memoryDb.pendingMutations).get();
    expect(allMutations.isEmpty, true);
  });
}

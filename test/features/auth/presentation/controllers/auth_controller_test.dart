import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/features/auth/domain/repositories/auth_repository.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_controller.dart';

import '../../../../helpers/fakes.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockSession extends Mock implements SessionLifecycleService {}

class MockSyncManager extends Mock implements MutationSyncManager {}

void main() {
  late StreamController<User?> authEvents;
  late MockSession session;
  late MockSyncManager sync;
  late FakeConnectivity connectivity;
  late AppDatabase db;
  late AuthController controller;
  late List<String> calls;

  setUp(() {
    authEvents = StreamController<User?>();
    final auth = MockFirebaseAuth();
    when(() => auth.authStateChanges()).thenAnswer((_) => authEvents.stream);
    calls = [];
    session = MockSession();
    when(() => session.endSession()).thenAnswer((_) async => calls.add('end'));
    sync = MockSyncManager();
    when(() => sync.triggerSync()).thenAnswer((_) async => calls.add('sync'));
    connectivity = FakeConnectivity();
    db = testDb();

    controller = AuthController(
      repository: MockAuthRepository(),
      sessionLifecycleService: session,
      firebaseAuth: auth,
      connectivity: connectivity,
      syncManager: sync,
      db: db,
    );
  });

  tearDown(() async {
    controller.dispose();
    await authEvents.close();
    await db.close();
  });

  Future<void> signOutEvent() async {
    authEvents.add(null);
    await pumpEventQueue();
  }

  test('starts uninitialised until Firebase reports the user', () {
    expect(controller.isInitialized, isFalse);
    expect(controller.isAuthenticated, isFalse);
  });

  test('a sign-out event marks auth ready and signed out', () async {
    await signOutEvent();

    expect(controller.isInitialized, isTrue);
    expect(controller.isAuthenticated, isFalse);
  });

  test('when online, flushes the sync queue before ending the session',
      () async {
    await signOutEvent();

    expect(calls, ['sync', 'end']);
  });

  test('when offline, skips the flush and still ends the session', () async {
    connectivity.online = false;

    await signOutEvent();

    expect(calls, ['end']);
  });
}

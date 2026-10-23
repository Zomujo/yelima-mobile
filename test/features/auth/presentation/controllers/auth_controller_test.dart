import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/managers/token_manager.dart';
import 'package:yelima/core/services/session_expiry.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/features/auth/domain/repositories/auth_repository.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_controller.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockSession extends Mock implements SessionLifecycleService {}

class MockSyncManager extends Mock implements MutationSyncManager {}

class MockUser extends Mock implements User {}

class MockTokens extends Mock implements TokenManager {}

/// A database whose wipe always fails, to check logout refuses to finish.
class StuckDb extends AppDatabase {
  StuckDb() : super(executor: testDb().executor);

  @override
  Future<void> wipeAll() => throw Exception('disk error');
}

void main() {
  late StreamController<User?> authEvents;
  late MockSession session;
  late MockSyncManager sync;
  late FakeConnectivity connectivity;
  late AppDatabase db;
  late AuthController controller;
  late List<String> calls;
  late MockAuthRepository repo;
  late SessionExpiry expiry;
  late MockFirebaseAuth auth;
  late MockTokens tokens;

  setUp(() {
    authEvents = StreamController<User?>.broadcast();
    auth = MockFirebaseAuth();
    repo = MockAuthRepository();
    expiry = SessionExpiry();
    tokens = MockTokens();
    when(() => tokens.clearTokens()).thenAnswer((_) async {});
    when(() => auth.authStateChanges()).thenAnswer((_) => authEvents.stream);
    calls = [];
    session = MockSession();
    when(() => session.endSession()).thenAnswer((_) async => calls.add('end'));
    when(() => session.startSession(any()))
        .thenAnswer((_) async => calls.add('start'));
    sync = MockSyncManager();
    when(() => sync.triggerSync()).thenAnswer((_) async => calls.add('sync'));
    connectivity = FakeConnectivity();
    db = testDb();

    controller = AuthController(
      repository: repo,
      sessionLifecycleService: session,
      firebaseAuth: auth,
      connectivity: connectivity,
      syncManager: sync,
      db: db,
      sessionExpiry: expiry,
      tokenManager: tokens,
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

  group('session expiry', () {
    MockUser user() {
      final u = MockUser();
      when(() => u.uid).thenReturn('uid-1');
      return u;
    }

    test(
        'a login that can\'t be refreshed at startup locks the app, without signing out',
        () async {
      final u = user();
      when(() => u.reload())
          .thenThrow(FirebaseAuthException(code: 'user-token-expired'));
      when(() => auth.currentUser).thenReturn(u);

      authEvents.add(u);
      await pumpEventQueue();

      expect(expiry.isExpired, isTrue);
      expect(calls, isEmpty, reason: 'no session start, no sign-out wipe');
      verifyNever(() => repo.signOut());
    });

    test('signing in again unlocks the app and starts the session', () async {
      expiry.markExpired();
      final u = user();
      when(() => auth.currentUser).thenReturn(u);
      when(() => repo.reauthenticate(password: 'pw'))
          .thenAnswer((_) async => right(null));

      final error = await controller.reauthenticate(password: 'pw');

      expect(error, isNull);
      expect(expiry.isExpired, isFalse);
      expect(calls, ['start']);
    });

    test('a failed sign-in keeps the app locked and reports why', () async {
      expiry.markExpired();
      when(() => repo.reauthenticate(password: 'wrong'))
          .thenAnswer((_) async => left('Wrong password'));

      final error = await controller.reauthenticate(password: 'wrong');

      expect(error, 'Wrong password');
      expect(expiry.isExpired, isTrue);
      expect(calls, isEmpty);
    });
  });

  group('logout', () {
    test('tries to send queued changes, then reports what is left', () async {
      await db.pendingMutationsDao.queueMutation(
          entityId: 'a', entityType: 'symptom', action: 'create', payload: {});
      await db.pendingMutationsDao.queueMutation(
          entityId: 'b', entityType: 'symptom', action: 'create', payload: {});
      final rejected = (await db.select(db.pendingMutations).get()).first.id;
      await db.pendingMutationsDao.markRejected(rejected);

      final left = await controller.syncBeforeLogout();

      expect(calls, ['sync']);
      expect((left.waiting, left.failed), (1, 1));
    });

    test('offline, it skips the sync attempt', () async {
      connectivity.online = false;

      final left = await controller.syncBeforeLogout();

      expect(calls, isEmpty);
      expect((left.waiting, left.failed), (0, 0));
    });

    testWidgets(
        'signs out of Firebase once the session ended and the data is gone',
        (tester) async {
      when(() => repo.signOut()).thenAnswer((_) async => right(null));
      await tester.pumpApp(const SizedBox());
      final context = tester.element(find.byType(Scaffold));

      await tester.runAsync(() => controller.signOut(context));

      expect(calls, contains('end'));
      verify(() => repo.signOut()).called(1);
    });

    testWidgets('CORE-EC-03: if the wipe fails, the user stays signed in',
        (tester) async {
      final stuck = StuckDb();
      addTearDown(stuck.close);
      await stuck.pendingMutationsDao.queueMutation(
          entityId: 'a', entityType: 'symptom', action: 'create', payload: {});
      final c = AuthController(
        repository: repo,
        sessionLifecycleService: session,
        firebaseAuth: auth,
        connectivity: connectivity,
        syncManager: sync,
        db: stuck,
        sessionExpiry: expiry,
        tokenManager: tokens,
      );
      addTearDown(c.dispose);
      await tester.pumpApp(const SizedBox());
      final context = tester.element(find.byType(Scaffold));

      await tester.runAsync(() => c.signOut(context));

      verifyNever(() => repo.signOut());
    });
  });
}

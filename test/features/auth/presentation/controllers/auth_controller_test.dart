import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/core_providers.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/session_expiry.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/features/auth/domain/entities/auth_user.dart';
import 'package:yelima/features/auth/domain/repositories/auth_repository.dart';
import 'package:yelima/features/auth/auth_providers.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_controller.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_state.dart';
import 'package:yelima/features/user/presentation/controllers/user_state.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSession extends Mock implements SessionLifecycleService {}

class MockSyncManager extends Mock implements MutationSyncManager {}

/// Hands login changes to [onChanged] instead of loading a profile.
class FakeUserController extends UserController {
  FakeUserController(this.onChanged);

  final Future<void> Function(AuthUser? user) onChanged;

  @override
  UserState build() => const UserState();

  @override
  Future<void> onUserChanged(AuthUser? user) => onChanged(user);
}

void main() {
  const ama = AuthUser(uid: 'uid-1', email: 'ama@example.com');
  late StreamController<AuthUser?> authEvents;
  late MockAuthRepository repo;
  late MockSession session;
  late MockSyncManager sync;
  late SessionExpiry expiry;
  late List<String> calls;
  late ProviderContainer container;

  ProviderContainer build({Future<void> Function(AuthUser?)? onUserChanged}) {
    final c = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      sessionLifecycleProvider.overrideWithValue(session),
      mutationSyncManagerProvider.overrideWithValue(sync),
      sessionExpiryProvider.overrideWithValue(expiry),
      userControllerProvider.overrideWith(
          () => FakeUserController(onUserChanged ?? (_) async {})),
    ]);
    addTearDown(c.dispose);
    c.read(authControllerProvider); // starts listening for login changes
    return c;
  }

  AuthState auth() => container.read(authControllerProvider);
  AuthController controller() =>
      container.read(authControllerProvider.notifier);

  setUp(() {
    calls = [];
    authEvents = StreamController<AuthUser?>.broadcast();
    repo = MockAuthRepository();
    when(() => repo.watchUser()).thenAnswer((_) => authEvents.stream);
    when(() => repo.currentUser).thenReturn(ama);
    when(() => repo.refreshLogin()).thenAnswer((_) async => right(null));
    session = MockSession();
    when(() => session.endSession()).thenAnswer((_) async => calls.add('end'));
    when(() => session.startSession(any()))
        .thenAnswer((_) async => calls.add('start'));
    sync = MockSyncManager();
    when(() => sync.flush()).thenAnswer((_) async {
      calls.add('flush');
      return (waiting: 0, failed: 0);
    });
    expiry = SessionExpiry();
    container = build();
  });

  tearDown(() => authEvents.close());

  Future<void> emit(AuthUser? user) async {
    authEvents.add(user);
    await pumpEventQueue();
  }

  test('starts uninitialised until the first login event', () {
    expect(auth().isInitialized, isFalse);
    expect(auth().isAuthenticated, isFalse);
  });

  test('a sign-out event sends queued changes, then ends the session',
      () async {
    await emit(null);

    expect(auth().isInitialized, isTrue);
    expect(auth().isAuthenticated, isFalse);
    expect(calls, ['flush', 'end']);
  });

  test('a sign-in event starts the session', () async {
    await emit(ama);

    expect(auth().isAuthenticated, isTrue);
    expect(auth().isInitialized, isTrue);
    expect(calls, ['start']);
  });

  test('login changes reach the profile before auth reports ready', () async {
    final seen = <(String?, bool)>[];
    late final ProviderContainer c;
    c = build(
        onUserChanged: (user) async => seen
            .add((user?.uid, c.read(authControllerProvider).isInitialized)));

    await emit(ama);
    await emit(null);

    expect(seen, [('uid-1', false), (null, true)]);
  });

  test('a revoked login locks the app instead of signing out', () async {
    when(() => repo.refreshLogin())
        .thenAnswer((_) async => left(const UnauthorizedFailure()));

    await emit(ama);

    expect(expiry.isExpired, isTrue);
    expect(calls, isEmpty, reason: 'no session start, no wipe');
  });

  test('being offline at startup still starts the session', () async {
    when(() => repo.refreshLogin())
        .thenAnswer((_) async => left(const NetworkFailure()));

    await emit(ama);

    expect(expiry.isExpired, isFalse);
    expect(calls, ['start']);
  });

  group('sign-in', () {
    test('finishes only once the profile has loaded, so the loader covers it',
        () async {
      when(() => repo.signIn('a@b.c', 'pw'))
          .thenAnswer((_) async => right(null));
      var done = false;

      controller().signIn('a@b.c', 'pw').then((_) => done = true);
      await pumpEventQueue();
      expect(done, isFalse);
      await emit(ama);

      expect(done, isTrue);
      expect(auth().isAuthLoading, isFalse);
    });

    test('a second tap while one is running is ignored quietly', () async {
      final pending = Completer<Either<AppFailure, void>>();
      when(() => repo.signIn('a@b.c', 'pw')).thenAnswer((_) => pending.future);

      controller().signIn('a@b.c', 'pw');
      final second = await controller().signIn('a@b.c', 'pw');

      expect(second, left(const CancelledFailure()));
      verify(() => repo.signIn('a@b.c', 'pw')).called(1);
      pending.complete(left(const NetworkFailure()));
    });

    test('a failed sign-in returns the failure and stops loading', () async {
      when(() => repo.signIn('a@b.c', 'pw')).thenAnswer(
          (_) async => left(const AuthFailure(AuthError.wrongPassword)));

      final result = await controller().signIn('a@b.c', 'pw');

      expect(result, left(const AuthFailure(AuthError.wrongPassword)));
      expect(auth().isAuthLoading, isFalse);
    });
  });

  group('session expiry', () {
    test('signing in again unlocks the app and starts the session', () async {
      expiry.markExpired();
      when(() => repo.reauthenticate(password: 'pw'))
          .thenAnswer((_) async => right(null));

      final result = await controller().reauthenticate(password: 'pw');

      expect(result.isRight(), isTrue);
      expect(expiry.isExpired, isFalse);
      expect(calls, ['start']);
    });

    test('a failed sign-in keeps the app locked', () async {
      expiry.markExpired();
      when(() => repo.reauthenticate(password: 'wrong')).thenAnswer(
          (_) async => left(const AuthFailure(AuthError.wrongPassword)));

      final result = await controller().reauthenticate(password: 'wrong');

      expect(result, left(const AuthFailure(AuthError.wrongPassword)));
      expect(expiry.isExpired, isTrue);
      expect(calls, isEmpty);
    });
  });

  group('logout', () {
    test('ends the session, then signs out', () async {
      when(() => repo.signOut()).thenAnswer((_) async {
        calls.add('signOut');
        return right(null);
      });

      expect(await controller().signOut(), isTrue);
      expect(calls, ['end', 'signOut']);
    });

    test('CORE-EC-03: reports failure when local data could not be wiped',
        () async {
      when(() => repo.signOut())
          .thenAnswer((_) async => left(const StorageFailure()));

      expect(await controller().signOut(), isFalse);
    });

    test('deleting the account ends the session only once it succeeded',
        () async {
      when(() => repo.deleteAccount(password: 'pw'))
          .thenAnswer((_) async => left(const NetworkFailure()));
      await controller().deleteAccount(password: 'pw');
      expect(calls, isEmpty);

      when(() => repo.deleteAccount(password: 'pw'))
          .thenAnswer((_) async => right(null));
      await controller().deleteAccount(password: 'pw');
      expect(calls, ['end']);
    });
  });
}

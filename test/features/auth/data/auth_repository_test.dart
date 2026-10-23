import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/managers/token_manager.dart';
import 'package:yelima/core/services/notification_service.dart';
import 'package:yelima/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yelima/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yelima/features/auth/domain/entities/auth_user.dart';

import '../../../helpers/fakes.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

class MockNotifications extends Mock implements NotificationService {}

class MockTokens extends Mock implements TokenManager {}

class MockUser extends Mock implements User {}

/// A database whose wipe always fails.
class StuckDb extends AppDatabase {
  StuckDb() : super(executor: testDb().executor);

  @override
  Future<void> wipeAll() => throw Exception('disk error');
}

void main() {
  late MockRemote remote;
  late MockTokens tokens;
  late FakeConnectivity connectivity;

  AuthRepositoryImpl repoWith(AppDatabase db) {
    final notifications = MockNotifications();
    when(notifications.cancelAllReminders).thenAnswer((_) async {});
    return AuthRepositoryImpl(
      remoteDataSource: remote,
      connectivityService: connectivity,
      db: db,
      notifications: notifications,
      tokens: tokens,
    );
  }

  setUp(() {
    remote = MockRemote();
    when(() => remote.signOut()).thenAnswer((_) async {});
    tokens = MockTokens();
    when(() => tokens.clearTokens()).thenAnswer((_) async {});
    connectivity = FakeConnectivity();
  });

  Future<void> queueChange(AppDatabase db) =>
      db.pendingMutationsDao.queueMutation(
          entityId: 'a', entityType: 'symptom', action: 'create', payload: {});

  group('signOut', () {
    test('wipes leftover local data, then signs out and clears tokens',
        () async {
      final db = testDb();
      addTearDown(db.close);
      await queueChange(db);

      expect(await repoWith(db).signOut(), right<AppFailure, void>(null));
      expect(await db.hasAnyRows(), isFalse);
      verify(() => remote.signOut()).called(1);
      verify(() => tokens.clearTokens()).called(1);
    });

    test('CORE-EC-03: if the wipe fails, the user stays signed in', () async {
      final db = StuckDb();
      addTearDown(db.close);
      await queueChange(db);

      final result = await repoWith(db).signOut();

      expect(result.isLeft(), isTrue);
      verifyNever(() => remote.signOut());
      verifyNever(() => tokens.clearTokens());
    });
  });

  test('maps the Firebase user to an AuthUser', () {
    final user = MockUser();
    when(() => user.uid).thenReturn('uid-1');
    when(() => user.email).thenReturn('ama@example.com');
    when(() => remote.currentUser).thenReturn(user);

    expect(repoWith(testDb()).currentUser,
        const AuthUser(uid: 'uid-1', email: 'ama@example.com'));
  });

  test('a revoked login comes back as UnauthorizedFailure', () async {
    when(() => remote.reloadUser()).thenThrow(const UnauthorizedFailure());

    expect(await repoWith(testDb()).refreshLogin(),
        left<AppFailure, void>(const UnauthorizedFailure()));
  });

  test('sign-in fails fast when offline', () async {
    connectivity.online = false;

    expect(await repoWith(testDb()).signIn('a@b.c', 'pw'),
        left<AppFailure, void>(const NetworkFailure()));
    verifyNever(() => remote.signInWithEmail(any(), any()));
  });
}

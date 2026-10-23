import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/auth/domain/entities/auth_user.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/domain/repositories/user_repository.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockUserRepository repo;
  late UserController controller;
  late StreamController<UserEntity?> profileWatch;
  late MockFirebaseAuth auth;

  UserEntity profile(String id) => UserEntity(id: id, email: '$id@example.com');

  MockUser user(String uid) {
    final u = MockUser();
    when(() => u.uid).thenReturn(uid);
    return u;
  }

  // Login changes arrive from AuthController; not awaited, like stream events.
  void emit(User? u) =>
      controller.onUserChanged(u == null ? null : AuthUser(uid: u.uid));

  setUp(() {
    profileWatch = StreamController<UserEntity?>.broadcast();
    repo = MockUserRepository();
    auth = MockFirebaseAuth();
    when(() => repo.getCachedProfile(any())).thenAnswer(
        (i) async => profile(i.positionalArguments.first as String));
    when(() => repo.watchUserProfile(any()))
        .thenAnswer((_) => profileWatch.stream);
    controller = UserController(repository: repo, firebaseAuth: auth);
  });

  tearDown(() async {
    controller.dispose();
    await profileWatch.close();
  });

  test('loads the cached profile when a user signs in', () async {
    when(() => repo.getUserProfile('a'))
        .thenAnswer((_) async => right(profile('a')));

    emit(user('a'));
    await pumpEventQueue();

    expect(controller.isInitialized, isTrue);
    expect(controller.userEntity?.id, 'a');
  });

  test('ACC-EC-01: a profile refresh that lands after sign-out is dropped',
      () async {
    final late = Completer<Either<String, UserEntity?>>();
    when(() => repo.getUserProfile('a')).thenAnswer((_) => late.future);

    emit(user('a'));
    await pumpEventQueue();
    emit(null);
    await pumpEventQueue();
    late.complete(right(profile('a')));
    await pumpEventQueue();

    expect(controller.userEntity, isNull);
  });

  test('ACC-EC-03: sign-out stops watching the previous user\'s profile',
      () async {
    when(() => repo.getUserProfile('a'))
        .thenAnswer((_) async => right(profile('a')));
    emit(user('a'));
    await pumpEventQueue();

    emit(null);
    await pumpEventQueue();
    profileWatch.add(profile('a'));
    await pumpEventQueue();

    expect(controller.userEntity, isNull);
  });

  group('ACC-EC-05: profile unavailable', () {
    setUp(() {
      when(() => repo.getCachedProfile(any())).thenAnswer((_) async => null);
    });

    test(
        'offline with no cached profile flags it, instead of looking like a new user',
        () async {
      when(() => repo.getUserProfile('a'))
          .thenAnswer((_) async => left('Offline user profile not found.'));

      emit(user('a'));
      await pumpEventQueue();

      expect(controller.isInitialized, isTrue);
      expect(controller.profileUnavailable, isTrue);
      expect(controller.userEntity, isNull);
    });

    test('a user with no profile yet is new, not unavailable', () async {
      when(() => repo.getUserProfile('a')).thenAnswer((_) async => right(null));

      emit(user('a'));
      await pumpEventQueue();

      expect(controller.profileUnavailable, isFalse);
    });

    test('retry loads the profile and clears the flag', () async {
      final u = user('a');
      when(() => auth.currentUser).thenReturn(u);
      when(() => repo.getUserProfile('a'))
          .thenAnswer((_) async => left('offline'));
      emit(u);
      await pumpEventQueue();

      when(() => repo.getUserProfile('a'))
          .thenAnswer((_) async => right(profile('a')));
      await controller.retryProfile();

      expect(controller.profileUnavailable, isFalse);
      expect(controller.userEntity?.id, 'a');
    });

    test('sign-out clears the flag', () async {
      when(() => repo.getUserProfile('a'))
          .thenAnswer((_) async => left('offline'));
      emit(user('a'));
      await pumpEventQueue();

      emit(null);
      await pumpEventQueue();

      expect(controller.profileUnavailable, isFalse);
    });
  });
}

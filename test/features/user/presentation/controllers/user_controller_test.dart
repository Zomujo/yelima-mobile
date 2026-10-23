import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/domain/repositories/user_repository.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late StreamController<User?> authEvents;
  late MockUserRepository repo;
  late UserController controller;
  late StreamController<UserEntity?> profileWatch;

  UserEntity profile(String id) => UserEntity(id: id, email: '$id@example.com');

  MockUser user(String uid) {
    final u = MockUser();
    when(() => u.uid).thenReturn(uid);
    return u;
  }

  setUp(() {
    authEvents = StreamController<User?>();
    profileWatch = StreamController<UserEntity?>.broadcast();
    repo = MockUserRepository();
    final auth = MockFirebaseAuth();
    when(() => auth.authStateChanges()).thenAnswer((_) => authEvents.stream);
    when(() => repo.getCachedProfile(any())).thenAnswer(
        (i) async => profile(i.positionalArguments.first as String));
    when(() => repo.watchUserProfile(any()))
        .thenAnswer((_) => profileWatch.stream);
    controller = UserController(repository: repo, firebaseAuth: auth);
  });

  tearDown(() async {
    controller.dispose();
    await authEvents.close();
    await profileWatch.close();
  });

  test('loads the cached profile when a user signs in', () async {
    when(() => repo.getUserProfile('a'))
        .thenAnswer((_) async => right(profile('a')));

    authEvents.add(user('a'));
    await pumpEventQueue();

    expect(controller.isInitialized, isTrue);
    expect(controller.userEntity?.id, 'a');
  });

  test('ACC-EC-01: a profile refresh that lands after sign-out is dropped',
      () async {
    final late = Completer<Either<String, UserEntity?>>();
    when(() => repo.getUserProfile('a')).thenAnswer((_) => late.future);

    authEvents.add(user('a'));
    await pumpEventQueue();
    authEvents.add(null);
    await pumpEventQueue();
    late.complete(right(profile('a')));
    await pumpEventQueue();

    expect(controller.userEntity, isNull);
  });

  test('ACC-EC-03: sign-out stops watching the previous user\'s profile',
      () async {
    when(() => repo.getUserProfile('a'))
        .thenAnswer((_) async => right(profile('a')));
    authEvents.add(user('a'));
    await pumpEventQueue();

    authEvents.add(null);
    await pumpEventQueue();
    profileWatch.add(profile('a'));
    await pumpEventQueue();

    expect(controller.userEntity, isNull);
  });
}

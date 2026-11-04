import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/features/auth/domain/entities/auth_user.dart';
import 'package:yelima/features/user/domain/entities/profile_changes.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/domain/repositories/user_repository.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/features/user/presentation/controllers/user_state.dart';
import 'package:yelima/features/user/user_providers.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  const ama = AuthUser(uid: 'a', email: 'a@example.com');
  late MockUserRepository repo;
  late StreamController<UserEntity?> profileWatch;
  late ProviderContainer container;

  UserEntity profile(String id,
          [RegistrationStatus status = RegistrationStatus.personalDetails]) =>
      UserEntity(id: id, email: '$id@example.com', registrationStatus: status);

  setUpAll(() {
    registerFallbackValue(const ProfileChanges());
    registerFallbackValue(profile('x'));
  });

  setUp(() {
    profileWatch = StreamController<UserEntity?>.broadcast();
    repo = MockUserRepository();
    when(() => repo.getCachedProfile(any())).thenAnswer(
        (i) async => profile(i.positionalArguments.first as String));
    when(() => repo.fetchProfile(any()))
        .thenAnswer((i) async => right(profile(i.positionalArguments.first)));
    when(() => repo.watchProfile(any())).thenAnswer((_) => profileWatch.stream);
    when(() => repo.updateProfile(any(), any()))
        .thenAnswer((_) async => right(null));
    when(() => repo.updatePatientProfile(any(), any()))
        .thenAnswer((_) async => right(null));
    container = ProviderContainer(
        overrides: [userRepositoryProvider.overrideWithValue(repo)]);
  });

  tearDown(() async {
    container.dispose();
    await profileWatch.close();
  });

  UserController controller() =>
      container.read(userControllerProvider.notifier);
  UserState user() => container.read(userControllerProvider);

  // Login changes arrive from AuthController; not awaited, like stream events.
  Future<void> emit(AuthUser? user) async {
    controller().onUserChanged(user);
    await pumpEventQueue();
  }

  test('loads the cached profile when a user signs in', () async {
    await emit(ama);

    expect(user().isInitialized, isTrue);
    expect(user().userEntity?.id, 'a');
  });

  test('an unchanged profile does not notify listeners', () async {
    await emit(null);
    var notified = 0;
    container.listen(userControllerProvider, (_, __) => notified++);

    await emit(null);

    expect(notified, 0);
  });

  test('ACC-EC-01: a profile refresh that lands after sign-out is dropped',
      () async {
    final late = Completer<Either<AppFailure, UserEntity?>>();
    when(() => repo.fetchProfile('a')).thenAnswer((_) => late.future);

    await emit(ama);
    await emit(null);
    late.complete(right(profile('a')));
    await pumpEventQueue();

    expect(user().userEntity, isNull);
  });

  test('ACC-EC-03: sign-out stops watching the previous user\'s profile',
      () async {
    await emit(ama);
    await emit(null);
    profileWatch.add(profile('a'));
    await pumpEventQueue();

    expect(user().userEntity, isNull);
  });

  group('ACC-EC-05: profile unavailable', () {
    setUp(() {
      when(() => repo.getCachedProfile(any())).thenAnswer((_) async => null);
    });

    test('offline with no cached profile flags it, instead of looking new',
        () async {
      when(() => repo.fetchProfile('a'))
          .thenAnswer((_) async => left(const NetworkFailure()));

      await emit(ama);

      expect(user().isInitialized, isTrue);
      expect(user().profileUnavailable, isTrue);
      expect(user().userEntity, isNull);
    });

    test('a user with no profile yet is new, not unavailable', () async {
      when(() => repo.fetchProfile('a')).thenAnswer((_) async => right(null));

      await emit(ama);

      expect(user().profileUnavailable, isFalse);
    });

    test('retry loads the profile and clears the flag', () async {
      when(() => repo.fetchProfile('a'))
          .thenAnswer((_) async => left(const NetworkFailure()));
      await emit(ama);

      when(() => repo.fetchProfile('a'))
          .thenAnswer((_) async => right(profile('a')));
      await controller().retryProfile();

      expect(user().profileUnavailable, isFalse);
      expect(user().userEntity?.id, 'a');
    });

    test('sign-out clears the flag', () async {
      when(() => repo.fetchProfile('a'))
          .thenAnswer((_) async => left(const NetworkFailure()));
      await emit(ama);
      await emit(null);

      expect(user().profileUnavailable, isFalse);
    });
  });

  group('saving', () {
    ProfileChanges sent() =>
        verify(() => repo.updateProfile('a', captureAny())).captured.last
            as ProfileChanges;

    test('ACC-EC-04: a profile edit never sends a registration status',
        () async {
      await emit(ama);

      await controller().updateName(firstName: 'Akua', lastName: 'Mensah');

      final changes = verify(() => repo.updatePatientProfile('a', captureAny()))
          .captured
          .single as ProfileChanges;
      expect(changes.firstName, 'Akua');
      expect(changes.registrationStatus, isNull);
      expect(user().userEntity?.firstName, 'Akua');
    });

    test('registration never goes backwards', () async {
      when(() => repo.getCachedProfile('a'))
          .thenAnswer((_) async => profile('a', RegistrationStatus.complete));
      when(() => repo.fetchProfile('a')).thenAnswer(
          (_) async => right(profile('a', RegistrationStatus.complete)));
      await emit(ama);

      await controller().updateDob(DateTime(1980));

      expect(sent().registrationStatus, RegistrationStatus.complete);
    });

    test('a failed save leaves the profile as it was', () async {
      await emit(ama);
      when(() => repo.updatePatientProfile(any(), any()))
          .thenAnswer((_) async => left(const StorageFailure()));

      final result =
          await controller().updateName(firstName: 'Akua', lastName: 'M');

      expect(result, left(const StorageFailure()));
      expect(user().userEntity?.firstName, isNull);
    });

    test('a tutorial is recorded once', () async {
      await emit(ama);

      await controller().markTutorialCompleted('home');
      await controller().markTutorialCompleted('home');

      verify(() => repo.updateProfile('a', any())).called(1);
      expect(user().userEntity?.completedTutorials, ['home']);
    });

    test('finishing onboarding shows the completed profile', () async {
      await emit(ama);
      final done = profile('a', RegistrationStatus.complete);
      when(() => repo.completeOnboarding(any(), 'f1'))
          .thenAnswer((_) async => right(done));

      await controller().submitOnboarding('f1');

      expect(user().userEntity, done);
    });
  });
}

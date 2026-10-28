import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/user/data/datasources/user_remote_data_source.dart';
import 'package:yelima/features/user/data/repositories/user_repository_impl.dart';
import 'package:yelima/features/user/domain/entities/profile_changes.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';

import '../../../helpers/fakes.dart';

class MockRemote extends Mock implements UserRemoteDataSource {}

void main() {
  const uid = 'uid-1';
  const ama = UserEntity(id: uid, email: 'ama@example.com', firstName: 'Ama');
  late AppDatabase db;
  late MockRemote remote;
  late FakeConnectivity connectivity;
  late UserRepositoryImpl repo;

  setUpAll(() => registerFallbackValue(ama));

  setUp(() {
    db = testDb();
    remote = MockRemote();
    when(() => remote.updateUserProfile(any(), any())).thenAnswer((_) async {});
    when(() => remote.updatePatient(any())).thenAnswer((_) async {});
    connectivity = FakeConnectivity();
    repo = UserRepositoryImpl(
        remoteDataSource: remote,
        connectivityService: connectivity,
        db: db,
        session: SessionEpoch());
  });

  tearDown(() => db.close());

  Future<int> queued() async =>
      (await db.pendingMutationsDao.getAllPendingMutations()).length;

  group('updateProfile', () {
    test('sends only the changed fields and keeps the rest on the phone',
        () async {
      await db.userProfilesDao.insertOrUpdateProfile(
          UserProfilesCompanion.insert(id: uid, email: 'ama@example.com'));

      await repo.updateProfile(uid, const ProfileChanges(firstName: 'Akua'));

      verify(() => remote.updateUserProfile(uid, {'firstName': 'Akua'}))
          .called(1);
      final saved = await repo.getCachedProfile(uid);
      expect(saved?.firstName, 'Akua');
      expect(saved?.email, 'ama@example.com');
    });

    test('offline, saves on the phone and queues the change', () async {
      connectivity.online = false;

      final result = await repo.updateProfile(
          uid, const ProfileChanges(firstName: 'Akua'));

      expect(result.isRight(), isTrue);
      expect((await repo.getCachedProfile(uid))?.firstName, 'Akua');
      expect(await queued(), 1);
      verifyNever(() => remote.updateUserProfile(any(), any()));
    });

    test('a server error queues the change without failing the save', () async {
      when(() => remote.updateUserProfile(any(), any()))
          .thenThrow(const ApiException('boom', code: '500'));

      final result =
          await repo.updateProfile(uid, const ProfileChanges(firstName: 'A'));

      expect(result.isRight(), isTrue);
      expect(await queued(), 1);
    });

    test('a 401 is reported, and the change is still queued', () async {
      when(() => remote.updateUserProfile(any(), any()))
          .thenThrow(const ApiException('no', code: '401'));

      final result =
          await repo.updateProfile(uid, const ProfileChanges(firstName: 'A'));

      expect(result, left<AppFailure, void>(const UnauthorizedFailure()));
      expect(await queued(), 1);
    });
  });

  group('updatePatientProfile', () {
    const edit = ProfileChanges(
        firstName: 'Mary Ann', lastName: 'Smith', gender: 'Female');

    test('updates Firestore and the clinic record with both name parts',
        () async {
      await repo.updatePatientProfile(uid, edit);

      verify(() => remote.updateUserProfile(uid, any())).called(1);
      verify(() => remote.updatePatient({
            'firstname': 'Mary Ann',
            'lastname': 'Smith',
            'gender': 'female'
          })).called(1);
    });

    test('offline, queues both so they replay later', () async {
      connectivity.online = false;

      final result = await repo.updatePatientProfile(uid, edit);

      expect(result.isRight(), isTrue);
      final actions = [
        for (final m in await db.pendingMutationsDao.getAllPendingMutations())
          m.action
      ];
      expect(actions, unorderedEquals(['updateUserProfile', 'updatePatient']));
    });
  });

  group('fetchProfile', () {
    test('caches the server profile on the phone', () async {
      when(() => remote.getUserProfile(uid)).thenAnswer((_) async => ama);

      expect(await repo.fetchProfile(uid), right<AppFailure, UserEntity?>(ama));
      expect(await repo.getCachedProfile(uid), ama);
    });

    test('offline, falls back to the phone\'s copy', () async {
      await db.userProfilesDao.insertOrUpdateProfile(
          UserProfilesCompanion.insert(id: uid, email: 'ama@example.com'));
      connectivity.online = false;

      final result = await repo.fetchProfile(uid);

      expect(result.getOrElse((_) => null)?.id, uid);
    });

    test('offline with nothing on the phone is a NetworkFailure', () async {
      connectivity.online = false;

      expect(await repo.fetchProfile(uid),
          left<AppFailure, UserEntity?>(const NetworkFailure()));
    });
  });

  test('onboarding completes the profile on the phone', () async {
    when(() => remote.onboardUser(any(), 'f1')).thenAnswer((_) async {});

    final result = await repo.completeOnboarding(ama, 'f1');

    final done = result.getOrElse((_) => ama);
    expect(done.registrationStatus, RegistrationStatus.complete);
    expect(done.facilityId, 'f1');
    expect((await repo.getCachedProfile(uid))?.registrationStatus,
        RegistrationStatus.complete);
  });
}

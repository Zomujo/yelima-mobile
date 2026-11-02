import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
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
  late FakeSync sync;
  late UserRepositoryImpl repo;

  setUpAll(() => registerFallbackValue(ama));

  setUp(() {
    db = testDb();
    remote = MockRemote();
    when(() => remote.updateUserProfile(any(), any())).thenAnswer((_) async {});
    when(() => remote.updatePatient(any())).thenAnswer((_) async {});
    connectivity = FakeConnectivity();
    sync = FakeSync();
    repo = UserRepositoryImpl(
        remoteDataSource: remote,
        connectivityService: connectivity,
        db: db,
        session: SessionEpoch(),
        mutationSyncManager: sync);
  });

  tearDown(() => db.close());

  Future<List<PendingMutation>> queue() =>
      db.pendingMutationsDao.getAllPendingMutations();

  group('updateProfile', () {
    test('saves on the phone, queues only the changed fields and syncs',
        () async {
      await db.userProfilesDao.insertOrUpdateProfile(
          UserProfilesCompanion.insert(id: uid, email: 'ama@example.com'));

      final result = await repo.updateProfile(
          uid, const ProfileChanges(firstName: 'Akua'));

      expect(result.isRight(), isTrue);
      final saved = await repo.getCachedProfile(uid);
      expect(saved?.firstName, 'Akua');
      expect(saved?.email, 'ama@example.com');
      expect(jsonDecode((await queue()).single.payloadJson),
          {'firstName': 'Akua'});
      expect(sync.syncs, 1);
      verifyNever(() => remote.updateUserProfile(any(), any()));
    });
  });

  group('updatePatientProfile', () {
    const edit = ProfileChanges(
        firstName: 'Mary Ann', lastName: 'Smith', gender: 'Female');

    test(
        'queues Firestore and the clinic record without waiting on the network',
        () async {
      final result = await repo.updatePatientProfile(uid, edit);

      expect(result.isRight(), isTrue);
      final queued = {
        for (final m in await queue()) m.action: jsonDecode(m.payloadJson)
      };
      expect(
          queued.keys, unorderedEquals(['updateUserProfile', 'updatePatient']));
      expect(queued['updatePatient'],
          {'firstname': 'Mary Ann', 'lastname': 'Smith', 'gender': 'female'});
      expect(sync.syncs, 1);
      verifyNever(() => remote.updatePatient(any()));
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

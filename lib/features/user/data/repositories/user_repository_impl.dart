import 'package:clock/clock.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/session_epoch.dart';
import '../../domain/entities/profile_changes.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/models/facility_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/profile_mappers.dart';

/// Offline-first [UserRepository]: the phone's copy first, the server when reachable.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
    required this.session,
    required this.mutationSyncManager,
  });

  final UserRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;
  final SessionEpoch session;
  final MutationSyncManager mutationSyncManager;

  @override
  Future<UserEntity?> getCachedProfile(String uid) async {
    try {
      return (await db.userProfilesDao.getProfile(uid))?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> watchProfile(String uid) =>
      db.userProfilesDao.watchProfile(uid).map((row) => row?.toEntity());

  @override
  AsyncResult<UserEntity?> fetchProfile(String uid) => guard(() async {
        try {
          if (!await connectivityService.isConnected) {
            throw const NetworkFailure();
          }
          final epoch = session.current;
          final profile = await remoteDataSource.getUserProfile(uid);
          session.ensure(epoch);
          if (profile != null) {
            await db.userProfilesDao.insertOrUpdateProfile(profile.toRow());
            return profile;
          }
        } catch (_) {
          // The phone's copy still knows how far registration got.
          final cached = await getCachedProfile(uid);
          if (cached != null) return cached;
          rethrow;
        }
        return getCachedProfile(uid);
      });

  @override
  AsyncResult<void> updateProfile(String uid, ProfileChanges changes) =>
      guard(() => _save(uid, changes));

  @override
  AsyncResult<void> updatePatientProfile(String uid, ProfileChanges changes) =>
      guard(() async {
        await _save(uid, changes, sync: false);
        // Both name parts always: the record stores one name and can't split it reliably.
        await _queue(uid, 'updatePatient', {
          'firstname': changes.firstName ?? '',
          'lastname': changes.lastName ?? '',
          if (changes.gender case final gender?) 'gender': gender.toLowerCase(),
        });
        mutationSyncManager.triggerSync();
      });

  @override
  AsyncResult<UserEntity> completeOnboarding(
          UserEntity profile, String facilityId) =>
      guardOnline(connectivityService, () async {
        // A repeat onboard returns 200 with the existing patient, so a retry is safe.
        await remoteDataSource.onboardUser(profile, facilityId);
        final changes = ProfileChanges(
          facilityId: facilityId,
          registrationStatus: RegistrationStatus.complete,
          createdAt: clock.now(),
        );
        await _save(profile.id, changes);
        return changes.applyTo(profile);
      });

  @override
  AsyncResult<List<FacilityModel>> searchFacilities(String search) =>
      guardOnline(
          connectivityService, () => remoteDataSource.searchFacilities(search));

  /// Writes [changes] here and queues them for Firestore; [sync] starts sending.
  Future<void> _save(String uid, ProfileChanges changes,
      {bool sync = true}) async {
    await db.userProfilesDao.patchProfile(uid, changes.toCompanion());
    await _queue(uid, 'updateUserProfile', changes.toJson());
    if (sync) mutationSyncManager.triggerSync();
  }

  Future<void> _queue(
          String uid, String action, Map<String, dynamic> payload) =>
      db.pendingMutationsDao.queueMutation(
          entityId: uid,
          entityType: 'user_profile',
          action: action,
          payload: payload);
}

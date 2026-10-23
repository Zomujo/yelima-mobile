import 'package:clock/clock.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
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
  });

  final UserRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;
  final SessionEpoch session;

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

  /// Writes [changes] here, then sends them or queues them; only a 401/403 is reported.
  Future<void> _save(String uid, ProfileChanges changes) async {
    await db.userProfilesDao.patchProfile(uid, changes.toCompanion());
    final payload = changes.toJson();
    Object? error;
    if (await connectivityService.isConnected) {
      try {
        return await remoteDataSource.updateUserProfile(uid, payload);
      } catch (e) {
        error = e;
      }
    }
    await db.pendingMutationsDao.queueMutation(
        entityId: uid,
        entityType: 'user_profile',
        action: 'updateUserProfile',
        payload: payload);
    if (error != null && AppFailure.from(error) is UnauthorizedFailure) {
      throw error;
    }
  }
}

import '../../../../core/failures/app_failure.dart';
import '../entities/profile_changes.dart';
import '../entities/user_entity.dart';
import '../models/facility_model.dart';

/// The patient's profile, kept on the phone and synced to the server.
abstract class UserRepository {
  /// The profile from this phone only; null if it was never saved here.
  Future<UserEntity?> getCachedProfile(String uid);

  /// The latest profile from the server (cached here), falling back to this phone.
  AsyncResult<UserEntity?> fetchProfile(String uid);

  /// Live profile from this phone.
  Stream<UserEntity?> watchProfile(String uid);

  /// Saves [changes] here at once and syncs them, queueing them while offline.
  AsyncResult<void> updateProfile(String uid, ProfileChanges changes);

  /// Like [updateProfile], and also updates the clinic's patient record.
  AsyncResult<void> updatePatientProfile(String uid, ProfileChanges changes);

  /// Registers the patient with [facilityId]; returns the completed profile.
  AsyncResult<UserEntity> completeOnboarding(
      UserEntity profile, String facilityId);

  /// Health facilities whose name matches [search].
  AsyncResult<List<FacilityModel>> searchFacilities(String search);
}

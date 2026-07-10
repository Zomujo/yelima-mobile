import '../../../../core/utils/custom_types.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  /// Updates specific fields of the user profile in the backend
  AsyncResponse<void> updateUserProfile(String uid, Map<String, dynamic> data);

  /// Hits the backend onboard endpoint to register the user fully
  AsyncResponse<void> onboardUser(Map<String, dynamic> data);

  /// Gets the user profile from the database
  AsyncResponse<UserEntity?> getUserProfile(String uid);

  /// Gets the user profile from local cache only (instant, no network call)
  Future<UserEntity?> getCachedProfile(String uid);

  /// Watches the user profile from the local database
  Stream<UserEntity?> watchUserProfile(String uid);
}

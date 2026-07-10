import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/user_profiles.dart';

part 'user_profiles_dao.g.dart';

@DriftAccessor(tables: [UserProfiles])
class UserProfilesDao extends DatabaseAccessor<AppDatabase> with _$UserProfilesDaoMixin {
  UserProfilesDao(super.db);

  Stream<UserProfile?> watchProfile(String id) {
    return (select(userProfiles)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<UserProfile?> getProfile(String id) {
    return (select(userProfiles)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertOrUpdateProfile(UserProfilesCompanion profile) {
    return into(userProfiles).insertOnConflictUpdate(profile);
  }

  Future<void> deleteProfile(String id) {
    return (delete(userProfiles)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearProfiles() {
    return delete(userProfiles).go();
  }
}

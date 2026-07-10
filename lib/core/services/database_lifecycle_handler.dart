import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/core/utils/logger.dart';

class DatabaseLifecycleHandler implements SessionLifecycleHandler {
  final AppDatabase _db;

  DatabaseLifecycleHandler(this._db);

  @override
  String get serviceName => 'Local Database Cache';

  @override
  Future<void> onSessionStarted(String userId) async {
    // Optionally pre-fetch or validate data on start
  }

  @override
  Future<void> onSessionEnded() async {
    AppLogger.w('DatabaseLifecycleHandler: Wiping all cached SQLite data for logout/deletion...');
    try {
      await Future.wait([
        _db.aiChatDao.clearAiChats(),
        _db.aiChatDao.clearPendingDeletions(),
        _db.vitalsDao.clearAllVitals(),
        _db.medicationsDao.clearMedications(),
        _db.appointmentsDao.clearAppointments(),
        _db.userProfilesDao.clearProfiles(),
        _db.pendingMutationsDao.clearPendingMutations(),
      ]);
      AppLogger.i('DatabaseLifecycleHandler: SQLite data successfully wiped.');
    } catch (e) {
      AppLogger.e('DatabaseLifecycleHandler: Failed to wipe SQLite data: $e');
    }
  }
}

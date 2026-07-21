import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/core/utils/logger.dart';
import 'package:yelima/features/chat/domain/services/audio_cache_manager.dart';

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
    // Defense in depth: AuthController.signOut() is expected to require
    // connectivity and force a completed sync before ending the session, so
    // this should always be empty by the time we get here. If it isn't,
    // whatever's left is about to be destroyed - log loudly rather than
    // silently losing it, since that's exactly the offline-data-loss bug
    // this ordering exists to prevent.
    try {
      final stillPending = await _db.pendingMutationsDao.getAllPendingMutations();
      if (stillPending.isNotEmpty) {
        AppLogger.e(
            'DatabaseLifecycleHandler: Wiping SQLite with ${stillPending.length} unsynced mutation(s) still pending! '
            'Entities: ${stillPending.map((m) => '${m.entityType}:${m.entityId}:${m.action}').join(', ')}');
      }
    } catch (e) {
      AppLogger.e('DatabaseLifecycleHandler: Failed to check pending mutations before wipe: $e');
    }

    AppLogger.w('DatabaseLifecycleHandler: Wiping all cached SQLite data for logout/deletion...');
    try {
      await _db.transaction(() async {
        await _db.aiChatDao.clearAiChats();
        await _db.aiChatDao.clearPendingDeletions();
        await _db.vitalsDao.clearAllVitals();
        await _db.appointmentsDao.clearAppointments();
        await _db.userProfilesDao.clearProfiles();
        await _db.pendingMutationsDao.clearPendingMutations();
      });
      await AudioCacheManager().clearCache();
      AppLogger.i('DatabaseLifecycleHandler: SQLite data successfully wiped.');
    } catch (e) {
      AppLogger.e('DatabaseLifecycleHandler: Failed to wipe SQLite data: $e');
    }
  }
}

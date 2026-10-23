import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/core/utils/logger.dart';
import 'package:yelima/features/chat/domain/services/audio_cache_manager.dart';

/// Wipes every local table and the voice-note files when a session ends.
class DatabaseLifecycleHandler implements SessionLifecycleHandler {
  final AppDatabase _db;
  final Future<void> Function() _clearAudioFiles;

  DatabaseLifecycleHandler(this._db, {Future<void> Function()? clearAudioFiles})
      : _clearAudioFiles =
            clearAudioFiles ?? (() => AudioCacheManager().clearCache());

  @override
  String get serviceName => 'Local Database Cache';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async {
    try {
      final stillPending =
          await _db.pendingMutationsDao.getAllPendingMutations();
      if (stillPending.isNotEmpty) {
        AppLogger.e(
            'DatabaseLifecycleHandler: Wiping SQLite with ${stillPending.length} unsynced mutation(s) still pending! '
            'Entities: ${stillPending.map((m) => '${m.entityType}:${m.entityId}:${m.action}').join(', ')}');
      }
    } catch (e) {
      AppLogger.e(
          'DatabaseLifecycleHandler: Failed to check pending mutations before wipe: $e');
    }

    AppLogger.w(
        'DatabaseLifecycleHandler: Wiping all cached SQLite data for logout/deletion...');
    try {
      // Every table, so tables added later can't leak to the next user.
      await _db.transaction(() async {
        for (final table in _db.allTables) {
          await _db.delete(table).go();
        }
      });
      await _clearAudioFiles();
      AppLogger.i('DatabaseLifecycleHandler: SQLite data successfully wiped.');
    } catch (e) {
      AppLogger.e('DatabaseLifecycleHandler: Failed to wipe SQLite data: $e');
    }
  }
}

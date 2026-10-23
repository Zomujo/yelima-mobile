import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/core/utils/logger.dart';
import 'package:yelima/features/chat/domain/services/audio_cache_manager.dart';

/// Wipes every local table and the voice-note files when a session ends.
class DatabaseLifecycleHandler implements SessionLifecycleHandler {
  final AppDatabase _db;
  final Future<void> Function() _clearAudioFiles;

  /// Reports how many unsynced changes the wipe threw away (a count, no content).
  final void Function(int count)? onDiscarded;

  DatabaseLifecycleHandler(this._db,
      {Future<void> Function()? clearAudioFiles, this.onDiscarded})
      : _clearAudioFiles =
            clearAudioFiles ?? (() => AudioCacheManager().clearCache());

  @override
  String get serviceName => 'Local Database Cache';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async {
    try {
      final unsynced = (await _db.select(_db.pendingMutations).get()).length;
      if (unsynced > 0) {
        AppLogger.e(
            'DatabaseLifecycleHandler: Wiping with $unsynced unsynced change(s).');
        onDiscarded?.call(unsynced);
      }
    } catch (e) {
      AppLogger.e(
          'DatabaseLifecycleHandler: Failed to count unsynced changes before wipe: $e');
    }

    AppLogger.w(
        'DatabaseLifecycleHandler: Wiping all cached SQLite data for logout/deletion...');
    try {
      await _db.wipeAll();
      await _clearAudioFiles();
      AppLogger.i('DatabaseLifecycleHandler: SQLite data successfully wiped.');
    } catch (e) {
      AppLogger.e('DatabaseLifecycleHandler: Failed to wipe SQLite data: $e');
    }
  }
}

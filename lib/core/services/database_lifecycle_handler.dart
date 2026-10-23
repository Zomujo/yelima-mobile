import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/core/utils/logger.dart';

/// Wipes every local table when a session ends. Features delete their own files.
class DatabaseLifecycleHandler implements SessionLifecycleHandler {
  final AppDatabase _db;

  /// Reports how many unsynced changes the wipe threw away (a count, no content).
  final void Function(int count)? onDiscarded;

  DatabaseLifecycleHandler(this._db, {this.onDiscarded});

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
      AppLogger.i('DatabaseLifecycleHandler: SQLite data successfully wiped.');
    } catch (e) {
      AppLogger.e('DatabaseLifecycleHandler: Failed to wipe SQLite data: $e');
    }
  }
}

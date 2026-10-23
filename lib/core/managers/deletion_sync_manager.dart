import 'dart:async';
import 'package:flutter/foundation.dart';
import '../failures/app_failure.dart';
import '../api/i_remote_deletion.dart';
import '../db/app_database.dart';
import '../services/connectivity_service.dart';
import '../services/session_lifecycle_service.dart';

/// Sends queued deletions (chat messages) when online.
class DeletionSyncManager implements SessionLifecycleHandler {
  final ConnectivityService _connectivityService;
  final AppDatabase _db;
  final Map<String, IRemoteDeletionSource> _remoteSources;

  StreamSubscription? _networkSubscription;
  bool _isSyncing = false;
  bool _isSessionActive = false;

  DeletionSyncManager({
    required ConnectivityService connectivityService,
    required AppDatabase db,
    Map<String, IRemoteDeletionSource> remoteSources = const {},
  })  : _connectivityService = connectivityService,
        _db = db,
        _remoteSources = {...remoteSources};

  Future<void>? _syncTask;

  @override
  String get serviceName => 'Chat Deletion Sync';

  /// Lets a feature send its queued deletions of [source] through [remote].
  void registerSource(String source, IRemoteDeletionSource remote) =>
      _remoteSources[source] = remote;

  @override
  Future<void> onSessionStarted(String userId) async {
    _isSessionActive = true;
    triggerSync();
  }

  @override
  Future<void> onSessionEnded() async {
    _isSessionActive = false;
    if (_syncTask != null) {
      debugPrint(
          "DeletionSyncManager: Awaiting in-flight sync task before ending session...");
      await _syncTask;
      debugPrint("DeletionSyncManager: Sync task completed, session ending.");
    }
  }

  void init() {
    if (_networkSubscription != null) return; // Prevent multiple subscriptions

    // Listen for future connection changes
    _networkSubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        debugPrint("Network connection restored. Starting deletion sync...");
        triggerSync();
      }
    });
  }

  Future<void> triggerSync() async {
    // A deletion queued by a previous user must never be sent under the next
    // user's auth token, so only sync while a session is actually active.
    if (_isSessionActive && await _connectivityService.isConnected) {
      if (!_isSyncing) {
        _syncTask = _syncPendingDeletions();
      }
      await _syncTask;
    }
  }

  Future<void> _syncPendingDeletions() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingDeletions = await _db.aiChatDao.getPendingDeletions();
      if (pendingDeletions.isEmpty) {
        return; // Nothing to sync
      }

      debugPrint("Found ${pendingDeletions.length} pending deletions to sync.");

      for (final pending in pendingDeletions) {
        if (!_isSessionActive) {
          debugPrint("Session ended during sync. Aborting batch.");
          break;
        }
        await _attemptDeletion(pending);
      }
    } catch (e) {
      debugPrint("Error during deletion sync: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _attemptDeletion(PendingDeletion pendingDeletion) async {
    try {
      final remoteSource = _remoteSources[pendingDeletion.source];
      if (remoteSource == null) {
        throw Exception("Unknown deletion source: ${pendingDeletion.source}");
      }

      await remoteSource.deleteMessage(pendingDeletion.messageId);
      await _db.aiChatDao.removePendingDeletion(
          pendingDeletion.messageId, pendingDeletion.source);
      debugPrint(
          "Successfully synced deletion for message: ${pendingDeletion.messageId}");
    } catch (e) {
      switch (AppFailure.from(e)) {
        case NotFoundFailure():
          // Already deleted on the server.
          await _db.aiChatDao.removePendingDeletion(
              pendingDeletion.messageId, pendingDeletion.source);
        case UnauthorizedFailure() || NetworkFailure():
          // Stop the run until the login or connection is back.
          rethrow;
        case ServerFailure(:final status?) when status >= 500:
          // Stop the run until the server recovers.
          rethrow;
        default:
          await _handleDeletionError(e, pendingDeletion);
      }
    }
  }

  Future<void> _handleDeletionError(
      Object e, PendingDeletion pendingDeletion) async {
    debugPrint(
        "Failed to sync deletion for message: ${pendingDeletion.source}  ${pendingDeletion.messageId}. Error: $e");
    // Leave in queue indefinitely. It will retry on next sync trigger.
    debugPrint("Deletion left in local queue to retry later.");
  }

  void dispose() {
    _networkSubscription?.cancel();
    _networkSubscription = null;
  }
}

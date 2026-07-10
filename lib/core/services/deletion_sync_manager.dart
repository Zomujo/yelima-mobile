import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/i_remote_deletion.dart';
import '../db/app_database.dart';
import 'connectivity_service.dart';
import 'session_lifecycle_service.dart';

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
    required Map<String, IRemoteDeletionSource> remoteSources,
  })  : _connectivityService = connectivityService,
        _db = db,
        _remoteSources = remoteSources;

  @override
  String get serviceName => 'Chat Deletion Sync';

  @override
  Future<void> onSessionStarted(String userId) async {
    _isSessionActive = true;
    triggerSync();
  }

  @override
  Future<void> onSessionEnded() async {
    _isSessionActive = false;
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
      _syncPendingDeletions();
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
        if (!await _connectivityService.isConnected) {
          debugPrint("Lost network connection during sync. Aborting batch.");
          break; // Stop immediately on network loss
        }
        await _attemptDeletion(pending);
      }
    } catch (e) {
      debugPrint("Error during deletion sync: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _attemptDeletion(PendingDeletion pendingDeletion,
      {int retryCount = 0}) async {
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
    } on DioException catch (e) {
      // 404 means the message is already deleted on the server.
      if (e.response?.statusCode == 404) {
        debugPrint(
            "Message ${pendingDeletion.messageId} not found on server (already deleted). Removing from local queue.");
        await _db.aiChatDao.removePendingDeletion(
            pendingDeletion.messageId, pendingDeletion.source);
        return;
      }

      // Identify connection errors and abort immediately
      if (_isConnectionError(e)) {
        debugPrint(
            "Connection error syncing deletion for ${pendingDeletion.messageId}. Aborting sync.");
        rethrow;
      }

      // Server side errors (5xx)
      await _handleDeletionError(e, pendingDeletion, retryCount);
    } catch (e) {
      if (e is SocketException) {
        debugPrint(
            "Network error syncing deletion for ${pendingDeletion.messageId}. Aborting sync.");
        rethrow;
      }

      if (e.toString().toLowerCase().contains('not found')) {
        debugPrint(
            "Message ${pendingDeletion.messageId} not found on server (already deleted or never sent). Removing from local queue.");
        await _db.aiChatDao.removePendingDeletion(
            pendingDeletion.messageId, pendingDeletion.source);
        return;
      }

      await _handleDeletionError(e, pendingDeletion, retryCount);
    }
  }

  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException;
  }

  Future<void> _handleDeletionError(
      Object e, PendingDeletion pendingDeletion, int retryCount) async {
    debugPrint(
        "Failed to sync deletion for message: ${pendingDeletion.source}  ${pendingDeletion.messageId}. Error: $e");
    if (!_isSessionActive) {
      debugPrint("Session ended, dropping retry for ${pendingDeletion.messageId}.");
      return;
    }
    if (retryCount < 5) {
      // 5 retries
      final waitSeconds =
          (2 << retryCount); // Exponential backoff: 2, 4, 8, 16, 32 seconds
      await Future.delayed(Duration(seconds: waitSeconds));
      await _attemptDeletion(pendingDeletion, retryCount: retryCount + 1);
    } else {
      debugPrint(
          "Max retries reached for message: ${pendingDeletion.messageId}. It will be retried on next app start or network change.");
    }
  }

  void dispose() {
    _networkSubscription?.cancel();
    _networkSubscription = null;
  }
}

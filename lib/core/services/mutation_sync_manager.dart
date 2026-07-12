import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/i_remote_mutation.dart';
import '../db/app_database.dart';
import 'connectivity_service.dart';
import 'session_lifecycle_service.dart';

class MutationSyncManager implements SessionLifecycleHandler {
  final ConnectivityService _connectivityService;
  final AppDatabase _db;
  final Map<String, IRemoteMutationSource> _remoteSources;

  StreamSubscription? _networkSubscription;
  bool _isSyncing = false;
  bool _isSessionActive = false;

  MutationSyncManager({
    required ConnectivityService connectivityService,
    required AppDatabase db,
    required Map<String, IRemoteMutationSource> remoteSources,
  })  : _connectivityService = connectivityService,
        _db = db,
        _remoteSources = remoteSources;

  Timer? _debounceTimer;
  Future<void>? _syncTask;

  @override
  String get serviceName => 'Mutation Sync';

  @override
  Future<void> onSessionStarted(String userId) async {
    _isSessionActive = true;
    triggerSync();
  }

  @override
  Future<void> onSessionEnded() async {
    _isSessionActive = false;
    _debounceTimer?.cancel();
    if (_syncTask != null) {
      debugPrint("MutationSyncManager: Awaiting in-flight sync task before ending session...");
      await _syncTask;
      debugPrint("MutationSyncManager: Sync task completed, session ending.");
    }
  }

  void init() {
    if (_networkSubscription != null) return;

    _networkSubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        // Debounce: Wait for connection to be stable for 3 seconds
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(seconds: 3), () {
          debugPrint("Network connection stable for 3s. Starting mutation sync...");
          triggerSync();
        });
      } else {
        _debounceTimer?.cancel();
      }
    });
  }

  Future<void> triggerSync() async {
    // A mutation queued by a previous user must never be sent under the next
    // user's auth token, so only sync while a session is actually active.
    if (_isSessionActive && await _connectivityService.isConnected) {
      if (!_isSyncing) {
        _syncTask = _syncPendingMutations();
      }
      await _syncTask;
    }
  }

  Future<void> _syncPendingMutations() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingMutations = await _db.pendingMutationsDao.getAllPendingMutations();
      if (pendingMutations.isEmpty) {
        return;
      }

      debugPrint("Found ${pendingMutations.length} pending mutations to sync.");

      for (final pending in pendingMutations) {
        if (!_isSessionActive) {
          debugPrint("Session ended during sync. Aborting batch.");
          break;
        }
        if (!await _connectivityService.isConnected) {
          debugPrint("Lost network connection during sync. Aborting batch.");
          break;
        }
        await _attemptMutation(pending);
        
        // Small delay to prevent rate-limiting when processing a large backlog
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint("Error during mutation sync: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _attemptMutation(PendingMutation pending) async {
    try {
      final remoteSource = _remoteSources[pending.entityType];
      if (remoteSource == null) {
        // Not registered with this manager - leave it queued rather than
        // poison-pilling it, since another mechanism (e.g. SyncService) may own it.
        debugPrint("No registered remote source for '${pending.entityType}', skipping for now.");
        return;
      }

      final newServerId = await remoteSource.syncMutation(
        entityId: pending.entityId,
        action: pending.action,
        payloadJson: pending.payloadJson,
        createdAt: pending.createdAt,
      );

      if (newServerId != null && newServerId != pending.entityId) {
        debugPrint("Remapping offline ID ${pending.entityId} to server ID $newServerId for ${pending.entityType}");
        if (pending.entityType == 'medication') {
          await _db.medicationsDao.updateMedicationId(pending.entityId, newServerId);
        }
        // Cascade to pending mutations (e.g. an update that followed the create)
        await _db.pendingMutationsDao.updateEntityId(pending.entityId, newServerId);
      }
      
      await _db.pendingMutationsDao.removePendingMutation(pending.id);
      debugPrint("Successfully synced mutation for ${pending.entityType} (${pending.entityId})");
    } on DioException catch (e) {
      // 409 means Conflict (e.g., server rejected due to Last-Write-Wins being older)
      // 404 means the entity no longer exists on the server.
      // 400 means Bad Request
      if (e.response?.statusCode == 409 || e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        debugPrint(
            "Mutation ${pending.id} rejected by server (${e.response?.statusCode}). Removing from local queue.");
        await _db.pendingMutationsDao.removePendingMutation(pending.id);
        return;
      }

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        debugPrint(
            "Unauthorized (${e.response?.statusCode}) during mutation sync. Aborting sync to preserve data until login.");
        rethrow;
      }

      if (_isConnectionError(e)) {
        debugPrint("Connection error syncing mutation for ${pending.id}. Aborting sync.");
        rethrow;
      }

      // Handle 5xx errors or other DioExceptions as "Poison Pills"
      await _handlePoisonPill(pending, e.toString());
      
    } catch (e) {
      debugPrint("Unexpected error syncing mutation ${pending.id}: $e");
      await _handlePoisonPill(pending, e.toString());
    }
  }

  Future<void> _handlePoisonPill(PendingMutation pending, String errorMsg) async {
    debugPrint("Failed to sync mutation ${pending.id}: $errorMsg");
    
    // Increment retry count
    final newRetryCount = pending.retryCount + 1;
    
    if (newRetryCount >= 3) {
      // Dead letter queue logic - drop it after 3 strikes to avoid infinite loops
      debugPrint("Mutation ${pending.id} failed 3 times. Dropping to prevent poison pill loop.");
      await _db.pendingMutationsDao.removePendingMutation(pending.id);
    } else {
      // Update the row with new retry count
      await _db.pendingMutationsDao.updatePendingMutation(
        pending.copyWith(retryCount: newRetryCount)
      );
    }
  }

  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException;
  }

  void dispose() {
    _debounceTimer?.cancel();
    _networkSubscription?.cancel();
    _networkSubscription = null;
  }
}

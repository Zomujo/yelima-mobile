import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/i_remote_mutation.dart';
import '../db/app_database.dart';
import 'connectivity_service.dart';
import 'session_lifecycle_service.dart';
import '../exceptions/exceptions.dart';

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
        final remapped = await _attemptMutation(pending);
        if (remapped) {
          debugPrint("ID remapped, breaking batch to refetch fresh state.");
          // Trigger next batch asynchronously
          Future.delayed(const Duration(milliseconds: 500), triggerSync);
          break;
        }
        
        // Small delay to prevent rate-limiting when processing a large backlog
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint("Error during mutation sync: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _attemptMutation(PendingMutation pending) async {
    try {
      final remoteSource = _remoteSources[pending.entityType];
      if (remoteSource == null) {
        debugPrint("No registered remote source for '${pending.entityType}', skipping for now.");
        return false;
      }

      final newServerId = await remoteSource.syncMutation(
        entityId: pending.entityId,
        action: pending.action,
        payloadJson: pending.payloadJson,
        createdAt: pending.createdAt,
      );

      bool didRemap = false;
      if (newServerId != null && newServerId != pending.entityId) {
        didRemap = true;
        debugPrint("Remapping offline ID ${pending.entityId} to server ID $newServerId for ${pending.entityType}");
        if (pending.entityType == 'medication') {
          await _db.medicationsDao.updateMedicationId(pending.entityId, newServerId);
        }
        // Cascade to pending mutations (e.g. an update that followed the create)
        await _db.pendingMutationsDao.updateEntityId(pending.entityId, newServerId);
      }
      
      await _db.pendingMutationsDao.removePendingMutation(pending.id);
      debugPrint("Successfully synced mutation for ${pending.entityType} (${pending.entityId})");
      
      return didRemap;
    } on ApiException catch (e) {
      // 409 means Conflict (e.g., server rejected due to Last-Write-Wins being older)
      // 404 means the entity no longer exists on the server.
      // 400 means Bad Request
      if (e.code == '409' || e.code == '404' || e.code == '400') {
        debugPrint(
            "Mutation ${pending.id} rejected by server (${e.code}). Removing from local queue.");
        await _db.pendingMutationsDao.removePendingMutation(pending.id);
        return false;
      }

      if (e.code == '401' || e.code == '403') {
        debugPrint(
            "Unauthorized (${e.code}) during mutation sync. Aborting sync to preserve data until login.");
        rethrow;
      }

      if (e.code != null && e.code!.startsWith('5')) {
        debugPrint(
            "Server error (${e.code}) during mutation sync. Aborting sync to preserve data until server recovers.");
        rethrow;
      }

      // Handle other non-fatal ApiExceptions or malformed responses as "Poison Pills"
      await _handlePoisonPill(pending, e.toString());
      return false;
      
    } on NetworkException catch (e) {
      debugPrint("Connection error syncing mutation for ${pending.id}. Aborting sync to try again later.");
      rethrow;
    } catch (e) {
      debugPrint("Unexpected error syncing mutation ${pending.id}: $e");
      await _handlePoisonPill(pending, e.toString());
      return false;
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



  void dispose() {
    _debounceTimer?.cancel();
    _networkSubscription?.cancel();
    _networkSubscription = null;
  }
}

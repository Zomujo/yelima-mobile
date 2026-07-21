import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/i_remote_mutation.dart';
import '../db/app_database.dart';
import 'connectivity_service.dart';
import 'session_lifecycle_service.dart';
import '../exceptions/exceptions.dart';

enum _MutationOutcome {
  resolved,
  remapped,
  blocked,
}

class MutationSyncManager implements SessionLifecycleHandler {
  final ConnectivityService _connectivityService;
  final AppDatabase _db;
  final Map<String, IRemoteMutationSource> _remoteSources;

  StreamSubscription? _networkSubscription;
  bool _isSyncing = false;
  bool _isSessionActive = false;
  
  final StreamController<String> _syncBroadcast = StreamController<String>.broadcast();
  Stream<String> get onMutationSynced => _syncBroadcast.stream;

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
      bool moreToProcess = true;
      while (moreToProcess && _isSessionActive) {
        final pendingMutations = await _db.pendingMutationsDao.getAllPendingMutations();
        if (pendingMutations.isEmpty) {
          break;
        }

        debugPrint("Found ${pendingMutations.length} pending mutations to sync.");
        final blockedEntityKeys = <String>{};
        moreToProcess = false;

        for (final pending in pendingMutations) {
          if (!_isSessionActive) {
            debugPrint("Session ended during sync. Aborting batch.");
            break;
          }

          final entityKey = '${pending.entityType}:${pending.entityId}';
          if (blockedEntityKeys.contains(entityKey)) {
            debugPrint(
                "Skipping mutation ${pending.id}: an earlier mutation for $entityKey hasn't resolved yet.");
            continue;
          }

          final outcome = await _attemptMutation(pending);
          if (outcome == _MutationOutcome.remapped) {
            debugPrint("ID remapped, breaking batch to refetch fresh state.");
            moreToProcess = true; // Loop again immediately to fetch fresh state
            break;
          }
          if (outcome == _MutationOutcome.blocked) {
            blockedEntityKeys.add(entityKey);
          }

          // Small delay to prevent rate-limiting when processing a large backlog
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      debugPrint("Error during mutation sync: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<_MutationOutcome> _attemptMutation(PendingMutation pending) async {
    try {
      final remoteSource = _remoteSources[pending.entityType];
      if (remoteSource == null) {
        debugPrint("No registered remote source for '${pending.entityType}', skipping for now.");
        return _MutationOutcome.blocked;
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
        // The row rename, the pending-mutation entityId cascade, and the
        // embedded-payload id patch must all land together - a crash
        // mid-cascade must not leave a mutation pointing at an id nothing
        // references anymore.
        await _db.transaction(() async {
          if (pending.entityType == 'medication') {
            await _db.medicationsDao.updateMedicationId(pending.entityId, newServerId);
          } else if (pending.entityType == 'ai_chat_message') {
            await _db.aiChatDao.updateMessageId(pending.entityId, newServerId);
          }
          // Cascade to pending mutations (e.g. an update/confirm that followed the create)
          await _db.pendingMutationsDao.updateEntityId(pending.entityId, newServerId);
          await _patchEmbeddedEntityIdReferences(pending.entityId, newServerId);
        });
      }

      await _db.pendingMutationsDao.removePendingMutation(pending.id);
      debugPrint("Successfully synced mutation for ${pending.entityType} (${pending.entityId})");

      if (pending.entityType == 'medication' &&
          (pending.action == 'create_medication' || pending.action == 'update_medication')) {
        await _db.medicationsDao.markSynced(newServerId ?? pending.entityId);
      }

      if (pending.entityType == 'medication') {
        // Small delay to allow backend caches to invalidate before UI refetches
        Future.delayed(const Duration(seconds: 2), () {
          _syncBroadcast.add(pending.entityType);
        });
      } else {
        _syncBroadcast.add(pending.entityType);
      }

      return didRemap ? _MutationOutcome.remapped : _MutationOutcome.resolved;
    } on ApiException catch (e) {
      // 409 means Conflict (e.g., server rejected due to Last-Write-Wins being older)
      // 404 means the entity no longer exists on the server.
      // 400 means Bad Request
      if (e.code == '409' || e.code == '404' || e.code == '400') {
        debugPrint(
            "Mutation ${pending.id} rejected by server (${e.code}). Removing from local queue.");
        await _db.transaction(() async {
          await _db.pendingMutationsDao.removePendingMutation(pending.id);

          // If this was a creation mutation, aggressively delete the orphaned optimistic record
          if (pending.action.startsWith('create')) {
            debugPrint("Deleting orphaned optimistic record ${pending.entityId} for type ${pending.entityType}");
            if (pending.entityType == 'medication') {
              await _db.medicationsDao.deleteMedication(pending.entityId);
            }
            // Delete any dependent pending mutations (e.g. a confirm mutation that followed the create)
            await _db.pendingMutationsDao.removeMutationsForEntity(pending.entityId);
          }
        });

        // Terminally resolved (rejected + cleaned up, including dependents),
        // so it doesn't block other entities' mutations.
        return _MutationOutcome.resolved;
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
      return _MutationOutcome.blocked;

    } on NetworkException {
      debugPrint("Connection error syncing mutation for ${pending.id}. Aborting sync to try again later.");
      rethrow;
    } catch (e) {
      debugPrint("Unexpected error syncing mutation ${pending.id}: $e");
      await _handlePoisonPill(pending, e.toString());
      return _MutationOutcome.blocked;
    }
  }

  /// After remapping [oldEntityId] to [newEntityId], patch any *other*
  /// pending mutation whose JSON payload embeds the old id in a
  /// `medicationId` field (e.g. an offline medication confirm carries
  /// `{"medicationId": "offline_xyz", ...}` independently of its own
  /// `entityId` column, which [PendingMutationsDao.updateEntityId] already
  /// renamed).
  Future<void> _patchEmbeddedEntityIdReferences(
      String oldEntityId, String newEntityId) async {
    final remaining = await _db.pendingMutationsDao.getAllPendingMutations();
    for (final p in remaining) {
      if (p.entityId != newEntityId) continue;
      try {
        final payload = jsonDecode(p.payloadJson);
        if (payload is Map<String, dynamic> &&
            payload['medicationId'] == oldEntityId) {
          payload['medicationId'] = newEntityId;
          await _db.pendingMutationsDao
              .updatePendingMutation(p.copyWith(payloadJson: jsonEncode(payload)));
        }
      } catch (_) {
        // Payload isn't a JSON object, or has no embedded id reference.
      }
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
    _syncBroadcast.close();
  }
}

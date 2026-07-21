import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/i_remote_mutation.dart';
import '../db/app_database.dart';
import '../services/connectivity_service.dart';
import '../services/session_lifecycle_service.dart';
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

  final StreamController<String> _syncBroadcast =
      StreamController<String>.broadcast();
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
      debugPrint(
          "MutationSyncManager: Awaiting in-flight sync task before ending session...");
      await _syncTask;
      debugPrint("MutationSyncManager: Sync task completed, session ending.");
    }
  }

  void init() {
    if (_networkSubscription != null) return;

    _networkSubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(seconds: 3), () {
          debugPrint(
              "Network connection stable for 3s. Starting mutation sync...");
          triggerSync();
        });
      } else {
        _debounceTimer?.cancel();
      }
    });
  }

  Future<void> triggerSync() async {
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
      bool hasPendingMutations = true;
      while (hasPendingMutations && _isSessionActive) {
        final mutations =
            await _db.pendingMutationsDao.getAllPendingMutations();
        if (mutations.isEmpty) {
          break;
        }

        debugPrint("Found ${mutations.length} pending mutations to sync.");
        final blockedKeys = <String>{};
        hasPendingMutations = false;

        for (final mutation in mutations) {
          if (!_isSessionActive) {
            debugPrint("Session ended during sync. Aborting batch.");
            break;
          }

          final entityKey = '${mutation.entityType}:${mutation.entityId}';
          if (blockedKeys.contains(entityKey)) {
            debugPrint(
                "Skipping mutation ${mutation.id}: an earlier mutation for $entityKey hasn't resolved yet.");
            continue;
          }

          final outcome = await _attemptMutation(mutation);

          if (outcome == _MutationOutcome.remapped) {
            debugPrint("ID remapped, breaking batch to refetch fresh state.");
            hasPendingMutations = true;
            break;
          }

          if (outcome == _MutationOutcome.blocked) {
            blockedKeys.add(entityKey);
          }

          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      debugPrint("Error during mutation sync: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<_MutationOutcome> _attemptMutation(PendingMutation mutation) async {
    try {
      final remoteSource = _remoteSources[mutation.entityType];
      if (remoteSource == null) {
        debugPrint(
            "No registered remote source for '${mutation.entityType}', skipping for now.");
        return _MutationOutcome.blocked;
      }

      final newServerId = await remoteSource.syncMutation(
        entityId: mutation.entityId,
        action: mutation.action,
        payloadJson: mutation.payloadJson,
        createdAt: mutation.createdAt,
      );

      bool didRemap = false;

      if (newServerId != null && newServerId != mutation.entityId) {
        didRemap = true;
        debugPrint(
            "Remapping offline ID ${mutation.entityId} to server ID $newServerId for ${mutation.entityType}");

        await _db.transaction(() async {
          if (mutation.entityType == 'ai_chat_message') {
            await _db.aiChatDao.updateMessageId(mutation.entityId, newServerId);
          }
          await _db.pendingMutationsDao
              .updateEntityId(mutation.entityId, newServerId);
        });
      }

      await _db.pendingMutationsDao.removePendingMutation(mutation.id);
      debugPrint(
          "Successfully synced mutation for ${mutation.entityType} (${mutation.entityId})");

      if (didRemap && newServerId != null) {
        _syncBroadcast.add(
            'remap:${mutation.entityType}:${mutation.entityId}:$newServerId');
      } else {
        _syncBroadcast.add(mutation.entityType);
      }

      return didRemap ? _MutationOutcome.remapped : _MutationOutcome.resolved;
    } on ApiException catch (e) {
      if (e.code == '409' || e.code == '404' || e.code == '400') {
        debugPrint(
            "Mutation ${mutation.id} rejected by server (${e.code}). Removing from local queue.");

        await _db.transaction(() async {
          await _db.pendingMutationsDao.removePendingMutation(mutation.id);

          if (mutation.action.startsWith('create')) {
            debugPrint(
                "Deleting orphaned optimistic record ${mutation.entityId} for type ${mutation.entityType}");
            await _db.pendingMutationsDao
                .removeMutationsForEntity(mutation.entityId);
          }
        });

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

      await _handleFailedMutation(mutation, e.toString());
      return _MutationOutcome.blocked;
    } on NetworkException {
      debugPrint(
          "Connection error syncing mutation for ${mutation.id}. Aborting sync to try again later.");
      rethrow;
    } catch (e) {
      debugPrint("Unexpected error syncing mutation ${mutation.id}: $e");
      await _handleFailedMutation(mutation, e.toString());
      return _MutationOutcome.blocked;
    }
  }

  Future<void> _handleFailedMutation(
      PendingMutation mutation, String errorMsg) async {
    debugPrint("Failed to sync mutation ${mutation.id}: $errorMsg");

    final newRetryCount = mutation.retryCount + 1;

    if (newRetryCount >= 3) {
      debugPrint(
          "Mutation ${mutation.id} failed 3 times. Dropping from queue to prevent infinite retry loop.");
      await _db.pendingMutationsDao.removePendingMutation(mutation.id);
    } else {
      await _db.pendingMutationsDao
          .updatePendingMutation(mutation.copyWith(retryCount: newRetryCount));
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _networkSubscription?.cancel();
    _networkSubscription = null;
    _syncBroadcast.close();
  }
}

part of 'mutation_sync_manager.dart';

/// What one send of a queued change came to.
enum _MutationOutcome {
  resolved,
  remapped,
  blocked,

  /// Failed for a reason that may pass later (5xx, unexpected error).
  retry,
}

/// Sends one queued change and decides, from the outcome, what happens to it.
extension _Attempt on MutationSyncManager {
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
          await remoteSource.remapLocalId(mutation.entityId, newServerId);
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
    } catch (e) {
      switch (AppFailure.from(e)) {
        case NotFoundFailure() when mutation.action.startsWith('delete'):
          // Already deleted on the server.
          await _db.pendingMutationsDao.removePendingMutation(mutation.id);
          _syncBroadcast.add(mutation.entityType);
          return _MutationOutcome.resolved;
        case NotFoundFailure() || ServerFailure(status: 400 || 413 || 422):
          // Rejected (422: idempotency key reused for another payload): kept on
          // the failed list for the user, never silently dropped.
          debugPrint("Mutation ${mutation.id} rejected by the server.");
          await _db.pendingMutationsDao.markRejected(mutation.id);
          return _MutationOutcome.blocked;
        case UnauthorizedFailure() ||
              NetworkFailure() ||
              ServerFailure(isRateLimited: true):
          // Stop the run: wait for a new login, a connection, or the rate limit.
          rethrow;
        default:
          // 5xx, 409 (the same write is still running) and anything else:
          // count a try for this item only and keep going.
          await _handleFailedMutation(mutation, e.toString());
          return _MutationOutcome.retry;
      }
    }
  }

  /// Counts one failed try; after [PendingMutationsDao.maxTries] the item moves to the failed list.
  Future<void> _handleFailedMutation(
      PendingMutation mutation, String errorMsg) async {
    debugPrint("Failed to sync mutation ${mutation.id}: $errorMsg");
    await _db.pendingMutationsDao.updatePendingMutation(
        mutation.copyWith(retryCount: mutation.retryCount + 1));
  }
}

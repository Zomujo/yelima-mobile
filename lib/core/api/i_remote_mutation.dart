abstract class IRemoteMutationSource {
  /// Syncs a mutation to the backend.
  /// Implementations should handle comparing timestamps to enforce Last-Write-Wins
  /// if the backend requires it, or just push the payload.
  /// 
  /// Throws an exception if the network fails.
  Future<void> syncMutation({
    required String entityId,
    required String action, // 'create', 'update', 'delete'
    required String payloadJson,
    required DateTime createdAt,
  });
}

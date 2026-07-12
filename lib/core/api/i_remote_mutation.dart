abstract class IRemoteMutationSource {
  /// Syncs a mutation to the backend.
  Future<String?> syncMutation({
    required String entityId,
    required String action, // 'create', 'update', 'delete'
    required String payloadJson,
    required DateTime createdAt,
  });
}

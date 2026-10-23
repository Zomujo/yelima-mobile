abstract class IRemoteMutationSource {
  /// Syncs a mutation to the backend.
  Future<String?> syncMutation({
    required String entityId,
    required String action, // 'create', 'update', 'delete'
    required String payloadJson,
    required DateTime createdAt,
  });

  /// Renames the local entity from [oldId] to the server's [newId] after a create
  /// syncs. Runs inside the sync manager's transaction.
  Future<void> remapLocalId(String oldId, String newId);
}

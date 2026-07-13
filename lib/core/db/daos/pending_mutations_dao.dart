import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/pending_mutations.dart';
import 'dart:convert';

part 'pending_mutations_dao.g.dart';

@DriftAccessor(tables: [PendingMutations])
class PendingMutationsDao extends DatabaseAccessor<AppDatabase> with _$PendingMutationsDaoMixin {
  PendingMutationsDao(super.db);

  Future<List<PendingMutation>> getAllPendingMutations() {
    // Order matters: sync handlers resolve offline-created entity ids by
    // processing mutations in creation order (e.g. create before a
    // subsequent update/confirm for the same entity).
    return (select(pendingMutations)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> addPendingMutation(PendingMutationsCompanion mutation) {
    return into(pendingMutations).insert(mutation);
  }

  Future<void> removePendingMutation(String id) {
    return (delete(pendingMutations)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updatePendingMutation(PendingMutation mutation) {
    return update(pendingMutations).replace(mutation);
  }

  Future<void> clearPendingMutations() {
    return delete(pendingMutations).go();
  }

  Future<void> updateEntityId(String oldEntityId, String newEntityId) {
    return (update(pendingMutations)..where((t) => t.entityId.equals(oldEntityId)))
        .write(PendingMutationsCompanion(entityId: Value(newEntityId)));
  }

  Future<void> removeMutationsForEntity(String entityId) {
    return (delete(pendingMutations)..where((t) => t.entityId.equals(entityId))).go();
  }

  Future<void> queueMutation({
    required String entityId,
    required String entityType,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    await addPendingMutation(PendingMutationsCompanion(
      id: Value('mut_${DateTime.now().microsecondsSinceEpoch}'),
      entityId: Value(entityId),
      entityType: Value(entityType),
      action: Value(action),
      payloadJson: Value(jsonEncode(payload)),
      createdAt: Value(DateTime.now()),
    ));
  }
}

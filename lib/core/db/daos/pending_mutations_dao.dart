import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/pending_mutations.dart';
import 'dart:convert';
import 'package:clock/clock.dart';
import 'package:uuid/uuid.dart';

part 'pending_mutations_dao.g.dart';

@DriftAccessor(tables: [PendingMutations])
class PendingMutationsDao extends DatabaseAccessor<AppDatabase>
    with _$PendingMutationsDaoMixin {
  PendingMutationsDao(super.db);

  /// Tries before an item moves to the failed list.
  static const maxTries = 3;

  /// Retry count that marks an item the server rejected (4xx).
  static const rejected = 9999;

  /// The signed-in user; new items are tagged with it. Set by the sync manager.
  String? owner;

  /// Items still waiting to sync for the current owner (or untagged), oldest first.
  Future<List<PendingMutation>> getAllPendingMutations() {
    return (select(pendingMutations)
          ..where((t) =>
              t.retryCount.isSmallerThanValue(maxTries) &
              (t.ownerUid.isNull() |
                  (owner == null
                      ? const Constant(true)
                      : t.ownerUid.equals(owner!))))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Whether changes for [entityId] or of [entityType] are still waiting to sync.
  Future<bool> hasWaiting({String? entityId, String? entityType}) async {
    final query = select(pendingMutations)
      ..where((t) =>
          t.retryCount.isSmallerThanValue(maxTries) &
          (entityId == null ? const Constant(true) : t.entityId.equals(entityId)) &
          (entityType == null
              ? const Constant(true)
              : t.entityType.equals(entityType)))
      ..limit(1);
    return (await query.get()).isNotEmpty;
  }

  /// Deletes items another user left behind and returns how many.
  Future<int> removeOtherOwners(String uid) => (delete(pendingMutations)
        ..where((t) => t.ownerUid.isNotNull() & t.ownerUid.equals(uid).not()))
      .go();

  /// Items the server rejected or that ran out of tries, oldest first.
  Future<List<PendingMutation>> getFailedMutations() {
    return (select(pendingMutations)
          ..where((t) => t.retryCount.isBiggerOrEqualValue(maxTries))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Live list of failed items, oldest first.
  Stream<List<PendingMutation>> watchFailedMutations() =>
      (select(pendingMutations)
            ..where((t) => t.retryCount.isBiggerOrEqualValue(maxTries))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  /// Live count of items waiting to sync, for the "changes waiting" badge.
  Stream<int> watchWaitingCount() =>
      _watchCount(pendingMutations.retryCount.isSmallerThanValue(maxTries));

  /// Live count of failed items.
  Stream<int> watchFailedCount() =>
      _watchCount(pendingMutations.retryCount.isBiggerOrEqualValue(maxTries));

  Stream<int> _watchCount(Expression<bool> where) {
    final count = pendingMutations.id.count();
    return (selectOnly(pendingMutations)
          ..addColumns([count])
          ..where(where))
        .map((r) => r.read(count) ?? 0)
        .watchSingle();
  }

  /// Moves an item to the failed list as rejected by the server.
  Future<void> markRejected(String id) => _setRetryCount(id, rejected);

  /// Puts a failed item back in the queue with a fresh set of tries.
  Future<void> resetRetries(String id) => _setRetryCount(id, 0);

  Future<void> _setRetryCount(String id, int value) =>
      (update(pendingMutations)..where((t) => t.id.equals(id)))
          .write(PendingMutationsCompanion(retryCount: Value(value)));

  /// Queues [mutation], tagged with the current [owner] unless it has one.
  Future<void> addPendingMutation(PendingMutationsCompanion mutation) {
    return into(pendingMutations).insert(mutation.ownerUid.present
        ? mutation
        : mutation.copyWith(ownerUid: Value(owner)));
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

  /// Ids of every queued entity of [entityType], including blocked ones.
  Future<Set<String>> getEntityIdsOfType(String entityType) async {
    final rows = await (selectOnly(pendingMutations, distinct: true)
          ..addColumns([pendingMutations.entityId])
          ..where(pendingMutations.entityType.equals(entityType)))
        .get();
    return rows.map((r) => r.read(pendingMutations.entityId)!).toSet();
  }

  Future<void> updateEntityId(String oldEntityId, String newEntityId) {
    return (update(pendingMutations)
          ..where((t) => t.entityId.equals(oldEntityId)))
        .write(PendingMutationsCompanion(entityId: Value(newEntityId)));
  }

  Future<void> removeMutationsForEntity(String entityId) {
    return (delete(pendingMutations)..where((t) => t.entityId.equals(entityId)))
        .go();
  }

  /// Adds a change to the sync queue.
  Future<void> queueMutation({
    required String entityId,
    required String entityType,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    await addPendingMutation(PendingMutationsCompanion(
      id: Value('mut_${const Uuid().v4()}'),
      entityId: Value(entityId),
      entityType: Value(entityType),
      action: Value(action),
      payloadJson: Value(jsonEncode(payload)),
      createdAt: Value(clock.now()),
    ));
  }
}

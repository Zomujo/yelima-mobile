import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/pending_mutations.dart';

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
}

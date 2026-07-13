import 'package:drift/drift.dart';

@TableIndex(name: 'idx_pending_mutations_entity', columns: {#entityType, #entityId})
class PendingMutations extends Table {
  TextColumn get id => text()(); // UUID of the pending action
  TextColumn get entityType => text()(); // 'profile', 'medication', 'appointment', etc.
  TextColumn get entityId => text()(); // ID of the entity being mutated
  TextColumn get action => text()(); // 'create', 'update', 'delete'
  TextColumn get payloadJson => text()(); // JSON representation of the mutated data
  DateTimeColumn get createdAt => dateTime()(); // Crucial for Last-Write-Wins resolution
  IntColumn get retryCount => integer().withDefault(const Constant(0))(); // Track retries for "Poison Pill" edge case

  @override
  Set<Column> get primaryKey => {id};
}

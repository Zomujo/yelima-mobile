import 'package:drift/drift.dart';

class PendingDeletions extends Table {
  TextColumn get messageId => text()();
  TextColumn get source => text()(); // e.g. 'chat'

  @override
  Set<Column> get primaryKey => {messageId, source};
}

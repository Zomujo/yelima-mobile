import 'package:drift/drift.dart';

class AudioCache extends Table {
  TextColumn get id => text()(); // The messageId
  TextColumn get filename => text()();

  @override
  Set<Column> get primaryKey => {id};
}

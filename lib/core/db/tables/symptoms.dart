import 'package:drift/drift.dart';

class Symptoms extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  DateTimeColumn get onsetDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

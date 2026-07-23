import 'package:drift/drift.dart';

class AdherenceGlobals extends Table {
  TextColumn get id => text()(); 
  RealColumn get rate => real()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

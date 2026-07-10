import 'package:drift/drift.dart';

class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  TextColumn get purpose => text()();
  DateTimeColumn get toBeTakenAt => dateTime()();
  BoolColumn get taken => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

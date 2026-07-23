import 'package:drift/drift.dart';

class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  TextColumn get purpose => text().nullable()();
  TextColumn get notes => text().nullable()();
  
  // Storing DosingScheduleModel as JSON string
  TextColumn get morningJson => text().nullable()();
  TextColumn get afternoonJson => text().nullable()();
  TextColumn get eveningJson => text().nullable()();
  
  // Flattened for easy local querying (similar to MedicationEntity properties)
  DateTimeColumn get toBeTakenAt => dateTime().nullable()();
  BoolColumn get taken => boolean().withDefault(const Constant(false))();
  TextColumn get section => text().withDefault(const Constant('UNKNOWN'))();

  @override
  Set<Column> get primaryKey => {id, section};
}

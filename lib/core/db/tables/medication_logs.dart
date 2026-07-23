import 'package:drift/drift.dart';

class MedicationLogs extends Table {
  TextColumn get id => text()(); 
  TextColumn get medicationId => text()(); 
  DateTimeColumn get takenAt => dateTime()();
  BoolColumn get taken => boolean()();
  
  @override
  Set<Column> get primaryKey => {id};
}

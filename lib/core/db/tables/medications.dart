import 'package:drift/drift.dart';

class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  TextColumn get purpose => text()();
  
  // JSON encoded schedules from the backend
  TextColumn get morningSchedule => text().nullable()();
  TextColumn get afternoonSchedule => text().nullable()();
  TextColumn get eveningSchedule => text().nullable()();
  
  // Sync engine state
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastModifiedAt => dateTime().nullable()();
  
  // Keep legacy fields nullable temporarily to prevent schema migration crashes during development
  DateTimeColumn get toBeTakenAt => dateTime().nullable()();
  BoolColumn get taken => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

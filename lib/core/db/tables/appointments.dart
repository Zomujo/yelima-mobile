import 'package:drift/drift.dart';

class Appointments extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get appointmentDate => dateTime()();
  
  // Flattened Host Personnel data
  TextColumn get hostPersonnelId => text()();
  TextColumn get hostPersonnelUserName => text()();
  TextColumn get hostPersonnelFacilityName => text()();

  @override
  Set<Column> get primaryKey => {id};
}

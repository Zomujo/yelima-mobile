import 'package:drift/drift.dart';

class PreloadedMedications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get possibleDosagesJson => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

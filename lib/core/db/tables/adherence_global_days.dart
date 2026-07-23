import 'package:drift/drift.dart';

class AdherenceGlobalDays extends Table {
  TextColumn get dateTakenStr => text()(); 
  BoolColumn get taken => boolean().nullable()();
  TextColumn get label => text()();
  TextColumn get type => text()();
  
  @override
  Set<Column> get primaryKey => {dateTakenStr};
}

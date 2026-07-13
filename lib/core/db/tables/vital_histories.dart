import 'package:drift/drift.dart';

@TableIndex(name: 'idx_vital_histories_type_date', columns: {#vitalType, #recordedAt})
class VitalHistories extends Table {
  TextColumn get id => text()();
  TextColumn get vitalType => text()();
  TextColumn get value => text()();
  TextColumn get unit => text()();
  TextColumn get severity => text()();
  TextColumn get vitalName => text()();
  DateTimeColumn get recordedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

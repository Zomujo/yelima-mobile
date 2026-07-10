import 'package:drift/drift.dart';

class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get gender => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  
  // Store conditions as JSON string list
  TextColumn get conditionsJson => text().withDefault(const Constant('[]'))();
  
  BoolColumn get hasConsented => boolean().withDefault(const Constant(false))();
  TextColumn get registrationStatus => text().withDefault(const Constant('personalDetails'))();
  TextColumn get modeOfRegistration => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

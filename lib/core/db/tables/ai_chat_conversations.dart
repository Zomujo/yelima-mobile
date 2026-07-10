import 'package:drift/drift.dart';

class AiChatConversations extends Table {
  TextColumn get id => text()();
  TextColumn get sender => text()(); // 'bot' or 'user'
  TextColumn get type => text()(); // 'text' or 'audio'
  TextColumn get value => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get status => text()(); // 'sending', 'sent', 'failed'
  TextColumn get suggestionsJson =>
      text().nullable()(); // JSON string of List<String>
  TextColumn get localChatId => text().nullable()();
  TextColumn get audioUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

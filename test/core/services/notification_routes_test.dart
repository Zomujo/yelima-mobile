import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/services/notification_routes.dart';

void main() {
  test('a medication reminder opens medications', () {
    expect(notificationRoute({'notification_type': medicationReminderType}),
        '/medications');
  });

  test('a clinician chat message opens chat', () {
    expect(notificationRoute({'notification_type': 'chat'}), '/chat');
    expect(notificationRoute({'chat_id': 'room-1'}), '/chat');
  });

  test('an AI message opens the AI chat', () {
    expect(notificationRoute({'notification_type': 'zyptyk_ai'}), '/ai-chat');
  });

  test('anything else, or no data, opens home', () {
    expect(notificationRoute({'notification_type': 'notification'}), '/home');
    expect(notificationRoute({}), '/home');
  });
}

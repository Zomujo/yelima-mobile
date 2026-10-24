import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/services/notification_routes.dart';

void main() {
  test('a medication reminder opens medications', () {
    expect(notificationRoute({'notification_type': medicationReminderType}),
        '/medications');
  });

  test('a clinician chat push opens home (there is no clinician chat)', () {
    expect(notificationRoute({'notification_type': 'chat'}), '/home');
    expect(notificationRoute({'chat_id': 'room-1'}), '/home');
  });

  test('appointment, vital alert and medication pushes open their screens', () {
    expect(notificationRoute({'notification_type': 'appointment'}),
        '/appointments');
    expect(notificationRoute({'notification_type': 'vital_alert'}),
        '/reading-logging');
    expect(notificationRoute({'notification_type': 'medication'}),
        '/medications');
  });

  test('an AI message opens the AI chat', () {
    expect(notificationRoute({'notification_type': 'ai_chat'}), '/ai-chat');
  });

  test('anything else, or no data, opens home', () {
    expect(notificationRoute({'notification_type': 'notification'}), '/home');
    expect(notificationRoute({'notification_type': 'zyptyk_ai'}), '/home');
    expect(notificationRoute({}), '/home');
  });
}

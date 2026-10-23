import '../router/route_paths.dart';

/// Local medication reminders carry this type in their payload.
const medicationReminderType = 'medication_reminder';

/// Screen to open when a notification is tapped, from its data payload.
///
/// The backend's `notification_type` is coarse today ('chat', 'zyptyk_ai',
/// 'notification'), so anything not recognised opens home.
String notificationRoute(Map<String, dynamic> data) {
  final type = data['notification_type']?.toString();
  if (type == medicationReminderType) return RoutePaths.medications;
  if (type == 'chat' || data['chat_id'] != null) return RoutePaths.chat;
  if (type == 'zyptyk_ai') return RoutePaths.aiChat;
  return RoutePaths.home;
}

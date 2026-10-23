import '../router/route_paths.dart';

/// Local medication reminders carry this type in their payload.
const medicationReminderType = 'medication_reminder';

/// Screen to open when a notification is tapped, from its data payload.
///
/// Unknown types open home, including the backend's untyped default 'zyptyk_ai'.
String notificationRoute(Map<String, dynamic> data) {
  final type = data['notification_type']?.toString();
  if (type == medicationReminderType) return RoutePaths.medications;
  if (type == 'ai_chat') return RoutePaths.aiChat;
  return RoutePaths.home;
}

import '../router/route_paths.dart';

/// Local medication reminders carry this type in their payload.
const medicationReminderType = 'medication_reminder';

/// Screen to open when a notification is tapped, from its data payload.
///
/// Unknown types open home, including the backend's untyped default 'zyptyk_ai'.
String notificationRoute(Map<String, dynamic> data) =>
    switch (data['notification_type']?.toString()) {
      medicationReminderType || 'medication' => RoutePaths.medications,
      'appointment' => RoutePaths.appointments,
      'vital_alert' => RoutePaths.readingLogging,
      'ai_chat' => RoutePaths.aiChat,
      _ => RoutePaths.home,
    };

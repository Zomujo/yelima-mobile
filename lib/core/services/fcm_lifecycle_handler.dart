import 'package:get_it/get_it.dart';
import 'session_lifecycle_service.dart';
import 'fcm_token_service.dart';
import 'notification_service.dart';

class FCMLifecycleHandler implements SessionLifecycleHandler {
  @override
  String get serviceName => 'FCMLifecycleHandler';
  @override
  Future<void> onSessionStarted(String userId) async {
    // You could also check if the user profile is complete if needed, 
    // but registering on session start is a good default.
    // Fire and forget so we don't block session startup
    GetIt.instance<FCMTokenService>().registerFCMToken().catchError((e) {
      // Ignored
    });
    
    NotificationService.instance.subscribeToTopic('yelima').catchError((e) {
      // Ignored
    });
  }

  @override
  Future<void> onSessionEnded() async {
    // We MUST await this so it completes before the Firebase Auth session is wiped.
    // If we fire-and-forget, the auth token is wiped before the API call fires,
    // resulting in a 401 Unauthorized. A 3-second timeout ensures logout isn't blocked on bad network.
    try {
      await GetIt.instance<FCMTokenService>()
          .deleteFCMToken()
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      // Ignored
    }
    
    try {
      await NotificationService.instance
          .unSubscribeFromTopic('yelima')
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      // Ignored
    }
  }
}

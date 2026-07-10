import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// A centralized monitoring service for Firebase Analytics and Crashlytics.
///
/// This service is implemented as a singleton and provides methods for logging
/// events, tracking screens, and recording errors.
class MonitoringService {
  MonitoringService._internal();

  /// The single instance of [MonitoringService].
  static final MonitoringService instance = MonitoringService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Returns a [FirebaseAnalyticsObserver] for use in the router.
  FirebaseAnalyticsObserver get analyticsObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Initializes the monitoring service.
  ///
  /// Disables Crashlytics collection in debug mode and enables Analytics collection.
  /// Accepts an optional [userId] to identify the user.
  Future<void> initialize({String? userId}) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      await _analytics.setAnalyticsCollectionEnabled(true);

      if (userId != null) {
        await identifyUser(userId: userId);
      } else {
        // Automatically identify if already logged in
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await identifyUser(
            userId: user.uid,
            email: user.email,
          );
        } else {
          await _crashlytics.setCustomKey('is_authenticated', false);
        }
      }
    } catch (e, stack) {
      debugPrint('MonitoringService: Failed to initialize: $e');
      await recordError(e, stack, reason: 'Initialization failure');
    }
  }

  // --------------------------------------------------------------------------
  // |                            Analytics Methods                             |
  // --------------------------------------------------------------------------

  /// Logs a screen view event.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      debugPrint('MonitoringService: Failed to log screen view: $e');
    }
  }

  /// Logs a custom event with optional parameters.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('MonitoringService: Failed to log event ($name): $e');
    }
  }

  /// Logs a login event.
  Future<void> logLogin({required String loginMethod}) async {
    try {
      await _analytics.logLogin(loginMethod: loginMethod);
    } catch (e) {
      debugPrint('MonitoringService: Failed to log login: $e');
    }
  }

  /// Logs a sign-up event.
  Future<void> logSignUp({required String signUpMethod}) async {
    try {
      await _analytics.logSignUp(signUpMethod: signUpMethod);
    } catch (e) {
      debugPrint('MonitoringService: Failed to log sign-up: $e');
    }
  }

  /// Logs a search event.
  Future<void> logSearch({required String searchTerm}) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);
    } catch (e) {
      debugPrint('MonitoringService: Failed to log search: $e');
    }
  }

  /// Logs a share event.
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: method,
      );
    } catch (e) {
      debugPrint('MonitoringService: Failed to log share: $e');
    }
  }

  /// Logs a button tap event.
  Future<void> logButtonTap({
    required String buttonName,
    String? screenName,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'button_tap',
        parameters: {
          'button_name': buttonName,
          if (screenName != null) 'screen_name': screenName,
        },
      );
    } catch (e) {
      debugPrint('MonitoringService: Failed to log button tap: $e');
    }
  }

  /// Sets a user property for analytics.
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('MonitoringService: Failed to set user property: $e');
    }
  }

  /// Sets the user ID for analytics.
  Future<void> setUserId({required String userId}) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('MonitoringService: Failed to set analytics user ID: $e');
    }
  }

  /// Resets user identity on both services.
  Future<void> resetUser() async {
    try {
      await _analytics.setUserId(id: null);
      await _crashlytics.setUserIdentifier('');
      await _crashlytics.setCustomKey('is_authenticated', false);
      await _crashlytics.setCustomKey('user_email', 'anonymous');
      await _crashlytics.setCustomKey('account_type', 'none');
    } catch (e) {
      debugPrint('MonitoringService: Failed to reset user: $e');
    }
  }

  // --------------------------------------------------------------------------
  // |                            Crashlytics Methods                           |
  // --------------------------------------------------------------------------

  /// Records an error or exception to Crashlytics.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) async {
    if (exception.toString().contains('UserCanceledException') ||
        exception.toString().contains('Sign in cancelled')) {
      return;
    }

    try {
      await _crashlytics.recordError(
        exception,
        stack,
        fatal: fatal,
        reason: reason,
      );
    } catch (e) {
      debugPrint('MonitoringService: Failed to record error: $e');
    }
  }

  /// Records a non-fatal error to Crashlytics.
  Future<void> recordNonFatalError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    await recordError(exception, stack, fatal: false, reason: reason);
  }

  /// Logs a custom message (breadcrumb) to Crashlytics.
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      debugPrint('MonitoringService: Failed to log breadcrumb: $e');
    }
  }

  /// Sets a custom key-value pair for Crashlytics reports.
  Future<void> setCustomKey(String key, Object value) async {
    try {
      if (value is String) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics.setCustomKey(key, value);
      } else {
        await _crashlytics.setCustomKey(key, value.toString());
      }
    } catch (e) {
      debugPrint('MonitoringService: Failed to set custom key ($key): $e');
    }
  }

  /// Sets the user identifier for Crashlytics.
  Future<void> setCrashlyticsUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('MonitoringService: Failed to set Crashlytics user ID: $e');
    }
  }

  // --------------------------------------------------------------------------
  // |                            Combined Methods                              |
  // --------------------------------------------------------------------------

  /// Identifies the user on both Analytics and Crashlytics.
  Future<void> identifyUser({
    required String userId,
    String? email,
    String? accountType,
  }) async {
    try {
      await setUserId(userId: userId);
      await setCrashlyticsUserId(userId);

      // Enhance Crashlytics correlation with custom keys
      await _crashlytics.setCustomKey('is_authenticated', true);
      
      if (email != null) {
        await setUserProperty(name: 'email', value: email);
        await _crashlytics.setCustomKey('user_email', email);
      }
      
      if (accountType != null) {
        await setUserProperty(name: 'account_type', value: accountType);
        await _crashlytics.setCustomKey('account_type', accountType);
      }

      await log('User identified: $userId ${email != null ? "($email)" : ""}');
    } catch (e) {
      debugPrint('MonitoringService: Failed to identify user: $e');
    }
  }

  /// Clears user identity on both services.
  Future<void> clearUser() async {
    await resetUser();
  }
}

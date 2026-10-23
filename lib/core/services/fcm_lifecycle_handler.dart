import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'session_lifecycle_service.dart';
import 'fcm_token_service.dart';
import 'notification_service.dart';
import 'connectivity_service.dart';

/// Registers the push token when a session starts and removes it when it ends.
class FCMLifecycleHandler implements SessionLifecycleHandler {
  FCMLifecycleHandler({
    required ConnectivityService connectivity,
    required FCMTokenService Function() tokenService,
    required NotificationService notifications,
    required FirebaseMessaging messaging,
  })  : _connectivity = connectivity,
        _tokenService = tokenService,
        _notifications = notifications,
        _messaging = messaging;

  final ConnectivityService _connectivity;
  // Resolved on first use, so the token service starts with the first session.
  final FCMTokenService Function() _tokenService;
  final NotificationService _notifications;
  final FirebaseMessaging _messaging;
  StreamSubscription? _connectivitySub;
  bool _registrationSucceeded = false;
  bool _isSessionActive = false;

  @override
  String get serviceName => 'FCMLifecycleHandler';

  @override
  Future<void> onSessionStarted(String userId) async {
    _isSessionActive = true;
    _registrationSucceeded = false;
    _attemptRegistration();

    _connectivitySub?.cancel();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen((isConnected) {
      if (isConnected && !_registrationSucceeded && _isSessionActive) {
        _attemptRegistration();
      }
    });
  }

  Future<void> _attemptRegistration() async {
    if (!_isSessionActive) return;
    try {
      await _tokenService().registerFCMToken();
      if (!_isSessionActive) return;
      await _notifications.subscribeToTopic('yelima');
      if (!_isSessionActive) return;
      _registrationSucceeded = true;
    } catch (e) {
      _registrationSucceeded = false;
    }
  }

  @override
  Future<void> onSessionEnded() async {
    _isSessionActive = false;
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _registrationSucceeded = false;

    try {
      await _tokenService()
          .deleteFCMToken()
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      // Ignored
    }

    try {
      await _notifications
          .unSubscribeFromTopic('yelima')
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      // Ignored
    }

    try {
      await _messaging.deleteToken();
    } catch (e) {
      // Ignored
    }
  }
}

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
  // Bumped per session, so a late attempt from the last one changes nothing.
  int _session = 0;

  @override
  String get serviceName => 'FCMLifecycleHandler';

  @override
  Future<void> onSessionStarted(String userId) async {
    _isSessionActive = true;
    _session++;
    _registrationSucceeded = false;
    _attemptRegistration(fresh: true);

    _connectivitySub?.cancel();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen((isConnected) {
      if (isConnected && !_registrationSucceeded && _isSessionActive) {
        _attemptRegistration();
      }
    });
  }

  Future<void> _attemptRegistration({bool fresh = false}) async {
    final session = _session;
    bool current() => _isSessionActive && session == _session;
    if (!current()) return;
    try {
      await _tokenService().registerFCMToken(fresh: fresh);
      if (!current()) return;
      await _notifications.subscribeToTopic('yelima');
      if (!current()) return;
      _registrationSucceeded = true;
    } catch (e) {
      if (current()) _registrationSucceeded = false;
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

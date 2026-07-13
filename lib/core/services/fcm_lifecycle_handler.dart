import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'session_lifecycle_service.dart';
import 'fcm_token_service.dart';
import 'notification_service.dart';
import 'connectivity_service.dart';

class FCMLifecycleHandler implements SessionLifecycleHandler {
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
    _connectivitySub = GetIt.instance<ConnectivityService>()
        .onConnectivityChanged
        .listen((isConnected) {
      if (isConnected && !_registrationSucceeded && _isSessionActive) {
        _attemptRegistration();
      }
    });
  }

  Future<void> _attemptRegistration() async {
    if (!_isSessionActive) return;
    try {
      await GetIt.instance<FCMTokenService>().registerFCMToken();
      if (!_isSessionActive) return;
      await NotificationService.instance.subscribeToTopic('yelima');
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

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      // Ignored
    }
  }
}

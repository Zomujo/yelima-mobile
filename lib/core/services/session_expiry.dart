import 'package:flutter/foundation.dart';

import 'session_lifecycle_service.dart';

/// Whether the login expired and the app is locked until the user signs in again.
///
/// Set when a token can't be refreshed. Nothing is wiped: the same user signing in
/// again keeps their unsynced data. Only an explicit logout ends the session.
class SessionExpiry extends ChangeNotifier implements SessionLifecycleHandler {
  bool _expired = false;

  bool get isExpired => _expired;

  /// Locks the app behind the "Session expired" screen.
  void markExpired() {
    if (_expired) return;
    _expired = true;
    notifyListeners();
  }

  /// Unlocks the app after a successful re-authentication.
  void clear() {
    if (!_expired) return;
    _expired = false;
    notifyListeners();
  }

  @override
  String get serviceName => 'SessionExpiry';

  @override
  Future<void> onSessionStarted(String userId) async => clear();

  @override
  Future<void> onSessionEnded() async => clear();
}

import 'session_lifecycle_service.dart';

/// Counts sessions, so a request started before logout can't write into the next user's data.
///
/// Capture [current] before a network call; write its result only if [isCurrent] is still true.
class SessionEpoch implements SessionLifecycleHandler {
  int _value = 0;

  /// The current session's number.
  int get current => _value;

  /// Whether [epoch] still belongs to the current session.
  bool isCurrent(int epoch) => epoch == _value;

  /// Throws [SessionEndedException] if [epoch] is from an earlier session.
  void ensure(int epoch) {
    if (!isCurrent(epoch)) throw const SessionEndedException();
  }

  @override
  String get serviceName => 'SessionEpoch';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async => _value++;
}

/// Thrown when a result arrives after the session that asked for it ended.
class SessionEndedException implements Exception {
  const SessionEndedException();

  @override
  String toString() => 'Session ended.';
}

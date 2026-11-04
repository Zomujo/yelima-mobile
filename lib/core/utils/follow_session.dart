import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core_providers.dart';
import '../services/session_lifecycle_service.dart';

/// Calls [onStart] and [onEnd] when a session starts or ends, for as long as
/// the provider that owns [ref] is alive.
void followSession(
  Ref ref, {
  FutureOr<void> Function(String userId)? onStart,
  FutureOr<void> Function()? onEnd,
}) {
  final service = ref.read(sessionLifecycleProvider);
  final hook = _SessionHook(onStart, onEnd);
  service.register(hook);
  ref.onDispose(() => service.unregister(hook));
}

class _SessionHook implements SessionLifecycleHandler {
  _SessionHook(this._onStart, this._onEnd);

  final FutureOr<void> Function(String userId)? _onStart;
  final FutureOr<void> Function()? _onEnd;

  @override
  String get serviceName => 'followSession';

  @override
  Future<void> onSessionStarted(String userId) async => _onStart?.call(userId);

  @override
  Future<void> onSessionEnded() async => _onEnd?.call();
}

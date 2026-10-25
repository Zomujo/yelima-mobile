import 'dart:async';

import 'package:clock/clock.dart';

import 'session_lifecycle_service.dart';

/// Remembers what was downloaded in the last minute, so moving between screens
/// shows the saved copy instead of fetching the same data again.
///
/// Everything counts as stale again after a write, when the app comes back on
/// screen, when the connection returns, when a queued change syncs, and at
/// sign-in or sign-out.
class RecentFetches implements SessionLifecycleHandler {
  RecentFetches({
    this.window = const Duration(minutes: 1),
    Stream<bool>? connectivity,
    Stream<String>? synced,
  }) {
    var wasOnline = true;
    _subs = [
      // Only a real reconnect counts; repeated "online" signals don't.
      if (connectivity != null)
        connectivity.listen((online) {
          if (online && !wasOnline) clear();
          wasOnline = online;
        }),
      if (synced != null) synced.listen((_) => clear()),
    ];
  }

  final Duration window;
  final _fetchedAt = <String, DateTime>{};
  final _values = <String, Object>{};
  final _running = <String, Future<Object?>>{};
  late final List<StreamSubscription<Object?>> _subs;

  /// Whether [key] was downloaded within the last [window].
  bool isFresh(String key) {
    final at = _fetchedAt[key];
    return at != null && clock.now().difference(at) < window;
  }

  /// The answer saved with [key], while it is still fresh.
  T? valueOf<T extends Object>(String key) =>
      isFresh(key) ? _values[key] as T? : null;

  /// Records that [key] was just downloaded, with its answer when the caller
  /// can't rebuild it from the database (e.g. the server's page counts).
  void markFetched(String key, [Object? value]) {
    _fetchedAt[key] = clock.now();
    value == null ? _values.remove(key) : _values[key] = value;
  }

  /// Runs [fetch] for [key], or joins the one already running, so two screens
  /// asking at the same moment share one download.
  Future<T> share<T>(String key, Future<T> Function() fetch) {
    final running = _running[key];
    if (running != null) return running.then((v) => v as T);
    final future = fetch();
    _running[key] = future;
    return future.whenComplete(() => _running.remove(key));
  }

  /// Makes everything stale, so the next screen fetches fresh data.
  void clear() {
    _fetchedAt.clear();
    _values.clear();
  }

  @override
  String get serviceName => 'RecentFetches';

  @override
  Future<void> onSessionStarted(String userId) async => clear();

  @override
  Future<void> onSessionEnded() async => clear();

  /// Stops listening; for tests.
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
  }
}

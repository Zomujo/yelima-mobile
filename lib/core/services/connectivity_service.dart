import 'dart:async';

import 'package:clock/clock.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../utils/logger.dart';

/// Whether the phone can reach the internet, now and as it changes.
///
/// Online means a real request got through. The phone's own network flag is
/// only a hint to check again: iOS can say "no network" while online.
class ConnectivityService {
  ConnectivityService({
    ConnectivityCheckCallback? check,
    Stream<Object?>? networkChanges,
  }) : _checker = InternetConnection.createInstance(
          useDefaultOptions: false,
          customCheckOptions: _probes,
          customConnectivityCheck: check,
        ) {
    _status.onListen = _recheck;
    _status.onCancel = () => _timer?.cancel();
    (networkChanges ?? Connectivity().onConnectivityChanged)
        .listen((_) => _recheck(), onError: (_) {});
  }

  // Answer 204 only when really online, so a Wi-Fi login page (which
  // answers 200) counts as offline. Two providers, in case one is down.
  // Not our API: phones behind one carrier IP would use up its rate limit.
  static final _probes = [
    for (final url in [
      'https://www.google.com/generate_204',
      'https://cp.cloudflare.com/generate_204',
    ])
      InternetCheckOption(
        uri: Uri.parse(url),
        responseStatusFn: (response) => response.statusCode == 204,
      ),
  ];

  /// How long an answer is reused before checking again.
  static const fresh = Duration(seconds: 3);
  // Offline it checks often, so a returning connection shows within seconds;
  // a check then fails fast and costs almost nothing.
  static const onlineEvery = Duration(seconds: 10);
  static const offlineEvery = Duration(seconds: 2);
  static const _idleEvery = Duration(hours: 1);

  final InternetConnection _checker;
  final _status = StreamController<bool>.broadcast();
  bool _paused = false;
  Timer? _timer;

  // Bumped on every network change, so an answer about the old network is dropped.
  int _generation = 0;
  ({int generation, Future<bool> answer})? _checking;
  bool? _online;
  DateTime? _answeredAt;

  /// Whether a request can reach the internet right now.
  ///
  /// Callers at the same moment share one check, and the answer is reused for
  /// [fresh]. A network change always asks again.
  Future<bool> get isConnected {
    final at = _answeredAt;
    if (at != null && clock.now().difference(at) < fresh) {
      return Future.value(_online!);
    }
    final running = _checking;
    if (running != null && running.generation == _generation) {
      return running.answer;
    }
    final generation = _generation;
    final answer = _checker.hasInternetAccess.then((online) {
      if (generation == _generation) _remember(online);
      return online;
    });
    _checking = (generation: generation, answer: answer);
    answer.whenComplete(() {
      if (identical(_checking?.answer, answer)) _checking = null;
    });
    return answer;
  }

  /// The latest answer, without waiting; true until the first check.
  bool get lastKnownOnline => _online ?? true;

  /// Emits whenever the connection comes or goes, starting with the current one.
  Stream<bool> get onConnectivityChanged async* {
    final known = _online;
    if (known != null) yield known;
    yield* _status.stream;
  }

  /// A reply from our server came back: online, no check needed.
  void sawReply() {
    if (_online == true) {
      _answeredAt = clock.now();
      return;
    }
    _generation++; // a slower check still running mustn't undo this
    _remember(true);
  }

  /// A request failed for lack of connection: check now, if we thought we were online.
  void sawNetworkError() {
    if (_online != false) _recheck();
  }

  /// Checks rarely while the app is in the background, to save battery and data.
  void pause() {
    _paused = true;
    _schedule();
  }

  /// Checks again at once when the app is back on screen.
  void resume() {
    _paused = false;
    _recheck();
  }

  // Forgets the answer, and checks now if anyone listens.
  void _recheck() {
    _generation++;
    _answeredAt = null;
    _checkNow();
  }

  void _checkNow() {
    _timer?.cancel();
    if (_status.hasListener) isConnected.whenComplete(_schedule).ignore();
  }

  // The next check, sooner while offline, while anyone listens.
  void _schedule() {
    _timer?.cancel();
    if (!_status.hasListener) return;
    final every =
        _paused ? _idleEvery : (_online == false ? offlineEvery : onlineEvery);
    _timer = Timer(every, () {
      _answeredAt = null;
      _checkNow();
    });
  }

  void _remember(bool online) {
    final changed = online != _online;
    _online = online;
    _answeredAt = clock.now();
    if (changed) AppLogger.i('Connection: ${online ? 'online' : 'offline'}');
    if (changed && _status.hasListener) {
      _status.add(online);
      _schedule();
    }
  }
}

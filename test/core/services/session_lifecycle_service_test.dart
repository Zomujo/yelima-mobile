import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';

/// Records start/end calls; can register another handler while running.
class Recorder implements SessionLifecycleHandler {
  Recorder(this.name, this.log, {this.onStart});

  final String name;
  final List<String> log;
  final void Function()? onStart;

  @override
  String get serviceName => name;

  @override
  Future<void> onSessionStarted(String userId) async {
    log.add('start:$name');
    onStart?.call();
  }

  @override
  Future<void> onSessionEnded() async => log.add('end:$name');
}

void main() {
  late SessionLifecycleService service;
  late List<String> log;

  setUp(() {
    service = SessionLifecycleService();
    log = [];
  });

  test('starts in ascending priority and ends in reverse', () async {
    service
      ..register(Recorder('db', log), priority: 10)
      ..register(Recorder('sync', log), priority: 80);

    await service.startSession('u');
    await service.endSession();

    expect(log, ['start:db', 'start:sync', 'end:sync', 'end:db']);
  });

  test('an unregistered handler gets no more calls', () async {
    final screen = Recorder('screen', log);
    service.register(screen);

    service.unregister(screen);
    await service.startSession('u');

    expect(log, isEmpty);
  });

  test('a handler registering another during start does not crash it',
      () async {
    service.register(Recorder('a', log,
        onStart: () => service.register(Recorder('late', log))));

    await expectLater(service.startSession('u'), completes);
    expect(log, contains('start:a'));
  });

  test('a failing handler does not stop the others', () async {
    service
      ..register(_Failing(), priority: 10)
      ..register(Recorder('next', log), priority: 20);

    await service.startSession('u');

    expect(log, ['start:next']);
  });
}

class _Failing implements SessionLifecycleHandler {
  @override
  String get serviceName => 'failing';

  @override
  Future<void> onSessionStarted(String userId) => throw Exception('boom');

  @override
  Future<void> onSessionEnded() async {}
}

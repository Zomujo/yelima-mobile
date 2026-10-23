import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/core/utils/session_scoped.dart';

class ScreenController extends ChangeNotifier with SessionScoped {
  ScreenController() {
    joinSession();
  }

  int ended = 0;

  @override
  String get serviceName => 'screen';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async => ended++;
}

void main() {
  late SessionLifecycleService service;

  setUp(() {
    service = SessionLifecycleService();
    GetIt.instance.registerSingleton(service);
  });

  tearDown(GetIt.instance.reset);

  test('a live controller gets session events', () async {
    final c = ScreenController();
    await service.startSession('u');
    await service.endSession();

    expect(c.ended, 1);
    c.dispose();
  });

  test('a disposed controller no longer piles up as a handler', () async {
    final c = ScreenController()..dispose();

    await service.startSession('u');
    await service.endSession();

    expect(c.ended, 0);
  });
}

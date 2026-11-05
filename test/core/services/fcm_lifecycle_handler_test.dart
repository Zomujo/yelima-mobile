import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/services/fcm_lifecycle_handler.dart';
import 'package:yelima/core/services/fcm_token_service.dart';
import 'package:yelima/core/services/notification_service.dart';

import '../../helpers/fakes.dart';

class _Tokens extends Mock implements FCMTokenService {}

class _Notifications extends Mock implements NotificationService {}

class _Messaging extends Mock implements FirebaseMessaging {}

void main() {
  late _Tokens tokens;
  late FakeConnectivity connectivity;
  late FCMLifecycleHandler handler;
  late List<Completer<void>> attempts;

  setUp(() {
    tokens = _Tokens();
    connectivity = FakeConnectivity();
    attempts = [];
    final notifications = _Notifications();
    final messaging = _Messaging();
    when(() => tokens.registerFCMToken(fresh: any(named: 'fresh')))
        .thenAnswer((_) => (attempts..add(Completer())).last.future);
    when(() => tokens.deleteFCMToken()).thenAnswer((_) async {});
    when(() => notifications.subscribeToTopic(any())).thenAnswer((_) async {});
    when(() => notifications.unSubscribeFromTopic(any()))
        .thenAnswer((_) async {});
    when(() => messaging.deleteToken()).thenAnswer((_) async {});
    handler = FCMLifecycleHandler(
        connectivity: connectivity,
        tokenService: () => tokens,
        notifications: notifications,
        messaging: messaging);
  });

  test('each session registers afresh, not by joining the last one', () async {
    await handler.onSessionStarted('a');
    await handler.onSessionEnded();
    await handler.onSessionStarted('b');

    verify(() => tokens.registerFCMToken(fresh: true)).called(2);
  });

  test("a late success from the last session doesn't count for the next",
      () async {
    await handler.onSessionStarted('a');
    await handler.onSessionEnded();
    await handler.onSessionStarted('b');

    attempts[1].completeError(Exception('offline'));
    attempts[0].complete();
    await pumpEventQueue();

    // B never registered, so coming back online tries again.
    connectivity.set(true);
    await pumpEventQueue();
    expect(attempts, hasLength(3));
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/services/notification_service.dart';
import 'package:yelima/features/medications/data/services/medication_alarm_sync_service.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';

class MockRepo extends Mock implements MedicationRepository {}

class MockNotifications extends Mock implements NotificationService {}

void main() {
  late MockRepo repo;
  late MockNotifications notifications;
  late MedicationAlarmSyncService service;
  late StreamController<String> events;

  setUp(() {
    repo = MockRepo();
    notifications = MockNotifications();
    events = StreamController<String>.broadcast();
    service = MedicationAlarmSyncService(repo, notifications, events.stream);
  });

  test('a session start reschedules the local reminders', () async {
    when(() => repo.syncLocalAlarms()).thenAnswer((_) async {});

    await service.onSessionStarted('uid');

    verify(() => repo.syncLocalAlarms()).called(1);
  });

  test('CORE-EC-08: any session end cancels every reminder', () async {
    when(() => notifications.cancelAllReminders()).thenAnswer((_) async {});

    await service.onSessionEnded();

    verify(() => notifications.cancelAllReminders()).called(1);
  });

  test('a failed cancel does not break the logout chain', () async {
    when(() => notifications.cancelAllReminders()).thenThrow(Exception('x'));

    await expectLater(service.onSessionEnded(), completes);
  });

  test('MED-EC-02: a medication remap moves its reminders to the server id',
      () async {
    when(() => repo.syncLocalAlarms()).thenAnswer((_) async {});
    when(() => repo.moveReminders(any(), any())).thenAnswer((_) async {});
    await service.onSessionStarted('uid');

    events
      ..add('remap:chat:a:b')
      ..add('medication')
      ..add('remap:medication:local-1:srv-1');
    await pumpEventQueue();

    verify(() => repo.moveReminders('local-1', 'srv-1')).called(1);
  });

  test('stops listening once the session ends', () async {
    when(() => repo.syncLocalAlarms()).thenAnswer((_) async {});
    when(() => notifications.cancelAllReminders()).thenAnswer((_) async {});
    await service.onSessionStarted('uid');
    await service.onSessionEnded();

    events.add('remap:medication:local-1:srv-1');
    await pumpEventQueue();

    verifyNever(() => repo.moveReminders(any(), any()));
  });
}

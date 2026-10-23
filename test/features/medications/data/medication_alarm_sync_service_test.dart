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

  setUp(() {
    repo = MockRepo();
    notifications = MockNotifications();
    service = MedicationAlarmSyncService(repo, notifications);
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
}

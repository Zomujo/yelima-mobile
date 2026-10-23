import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/notification_service.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/medications/data/datasources/medication_local_datasource.dart';
import 'package:yelima/features/medications/data/datasources/medication_remote_datasource.dart';
import 'package:yelima/features/medications/data/models/create_medication_model.dart';
import 'package:yelima/features/medications/data/models/dosing_schedule_model.dart';
import 'package:yelima/features/medications/data/models/medication_list_response_model.dart';
import 'package:yelima/features/medications/data/models/medication_model.dart';
import 'package:yelima/features/medications/utils/medication_reminder_id.dart';
import 'package:yelima/features/medications/data/repositories/medication_repository_impl.dart';

import '../../../../helpers/fakes.dart';

class MockRemote extends Mock implements MedicationRemoteDataSource {}

class MockNotifications extends Mock implements NotificationService {}

class MockSync extends Mock implements MutationSyncManager {}

/// Local source whose queue write fails, to check the medication rows roll back.
class FailingQueueLocal extends MedicationLocalDataSourceImpl {
  FailingQueueLocal({required super.db});

  @override
  Future<void> addPendingMutation(PendingMutationsCompanion mutation) =>
      throw Exception('disk full');
}

void main() {
  late AppDatabase db;
  late MockNotifications notifications;

  const data = CreateMedicationModel(
    name: 'Amlodipine',
    dosage: '5mg',
    morning: DosingScheduleModel(
      time: ScheduleTimeModel(hour: 8, minutes: 0, timeDesignators: 'AM'),
      quantity: ScheduleQuantityModel(value: 1, unit: 'tablet'),
    ),
  );

  late MockRemote remote;

  MedicationRepositoryImpl repoWith(MedicationLocalDataSource local,
      {bool online = false}) {
    final sync = MockSync();
    when(() => sync.triggerSync()).thenAnswer((_) async {});
    return MedicationRepositoryImpl(
      remoteDataSource: remote,
      connectivityService: FakeConnectivity(online: online),
      localDataSource: local,
      mutationSyncManager: sync,
      notificationService: notifications,
      session: SessionEpoch(),
    );
  }

  setUpAll(() => registerFallbackValue(const TimeOfDay(hour: 0, minute: 0)));

  setUp(() {
    remote = MockRemote();
    db = testDb()..pendingMutationsDao.owner = 'user_1';
    notifications = MockNotifications();
    when(() => notifications.scheduleDailyReminder(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          time: any(named: 'time'),
        )).thenAnswer((_) async {});
    when(() => notifications.cancelReminder(any())).thenAnswer((_) async {});
  });

  tearDown(() => db.close());

  test('create saves the medication and its queued sync, tagged with the user',
      () async {
    final repo = repoWith(MedicationLocalDataSourceImpl(db: db));

    final id = (await withClock(Clock.fixed(DateTime(2026, 10, 23, 7)),
            () => repo.createMedication(data)))
        .getOrElse((_) => '');

    final meds = await db.select(db.medications).get();
    final queued = (await db.select(db.pendingMutations).get()).single;
    expect(meds.single.id, id);
    expect((queued.entityId, queued.action, queued.ownerUid),
        (id, 'createMedication', 'user_1'));
  });

  test('if queueing the sync fails, the medication is not saved either',
      () async {
    final repo = repoWith(FailingQueueLocal(db: db));

    await expectLater(repo.createMedication(data), throwsException);

    expect(await db.select(db.medications).get(), isEmpty);
    expect(await db.select(db.pendingMutations).get(), isEmpty);
    verifyNever(() => notifications.scheduleDailyReminder(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          time: any(named: 'time'),
        ));
  });

  test('delete removes the rows and queues the delete together', () async {
    final repo = repoWith(MedicationLocalDataSourceImpl(db: db));
    final id = (await repo.createMedication(data)).getOrElse((_) => '');
    await db.delete(db.pendingMutations).go();

    await repo.deleteMedication(id);

    expect(await db.select(db.medications).get(), isEmpty);
    expect((await db.select(db.pendingMutations).get()).single.action,
        'deleteMedication');
  });

  group('background sync', () {
    Medication row(String id, String section) => Medication(
          id: id,
          name: 'Old name',
          dosage: '5mg',
          section: section,
          taken: false,
          toBeTakenAt: DateTime(2026, 10, 23, section == 'MORNING' ? 8 : 20),
          morningJson: '{"m":1}',
        );

    MedicationModel remoteMed(String id, {String name = 'Amlodipine'}) =>
        MedicationModel(
          id: id,
          name: name,
          dosage: '10mg',
          purpose: 'BP',
          toBeTakenAt: DateTime(2026, 10, 23, 8),
          taken: false,
        );

    /// Background work runs unawaited; wait until it has finished.
    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 50));

    Future<Set<(String, String)>> rows() async =>
        (await db.select(db.medications).get())
            .map((m) => (m.id, m.section))
            .toSet();

    test('MED-EC-05: a med gone from one section keeps its other sections',
        () async {
      await db.medicationsDao.insertMedications(
          [row('srv-1', 'MORNING'), row('srv-1', 'EVENING')]);
      when(() => remote.getMedicationsBySection('MORNING'))
          .thenAnswer((_) async => <MedicationModel>[]);
      final repo =
          repoWith(MedicationLocalDataSourceImpl(db: db), online: true);

      await repo.getMedicationsBySection('MORNING');
      await settle();

      expect(await rows(), {('srv-1', 'EVENING')});
      verify(() => notifications
          .cancelReminder(medicationReminderId('srv-1', 'MORNING'))).called(1);
      verifyNever(() => notifications
          .cancelReminder(medicationReminderId('srv-1', 'EVENING')));
    });

    test('MED-EC-04: the list sync updates details and never adds UNKNOWN rows',
        () async {
      await db.medicationsDao.insertMedications([
        row('srv-1', 'MORNING'),
        row('srv-1', 'UNKNOWN'), // left by an older version
      ]);
      when(() => remote.getAllMedications(
              page: any(named: 'page'), pageSize: any(named: 'pageSize')))
          .thenAnswer((_) async => MedicationListResponseModel(
                rows: [remoteMed('srv-1')],
                total: 1,
                pageSize: 10,
                page: 1,
                totalPages: 1,
              ));
      final repo =
          repoWith(MedicationLocalDataSourceImpl(db: db), online: true);

      await repo.getAllMedications();
      await settle();

      final meds = await db.select(db.medications).get();
      expect(
          meds.map((m) => (m.id, m.section, m.name, m.dosage, m.morningJson)),
          [('srv-1', 'MORNING', 'Amlodipine', '10mg', '{"m":1}')]);
      verify(() => notifications
          .cancelReminder(medicationReminderId('srv-1', 'UNKNOWN'))).called(1);
      verifyNever(() => notifications.scheduleDailyReminder(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            time: any(named: 'time'),
          ));
    });
  });

  test('confirming a dose stamps it with today', () async {
    final repo = repoWith(MedicationLocalDataSourceImpl(db: db));
    final id = (await repo.createMedication(data)).getOrElse((_) => '');

    await withClock(Clock.fixed(DateTime(2026, 10, 23, 8, 30)),
        () => repo.confirmMedication(id, 'MORNING'));

    final row = (await db.select(db.medications).get()).single;
    expect((row.taken, row.takenOn), (true, DateTime(2026, 10, 23, 8, 30)));
  });
}

import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/db/daos/pending_mutations_dao.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/notification_service.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/medications/domain/models/medication_detail_model.dart';
import 'package:yelima/core/services/recent_fetches.dart';
import 'package:yelima/features/medications/data/datasources/medication_remote_datasource.dart';
import 'package:yelima/features/medications/data/models/medication_list_response_model.dart';
import 'package:yelima/features/medications/data/models/medication_model.dart';
import 'package:yelima/features/medications/data/repositories/medication_repository_impl.dart';
import 'package:yelima/features/medications/domain/entities/medication_form.dart';
import 'package:yelima/features/medications/domain/entities/medication_section.dart';
import 'package:yelima/features/medications/domain/medication_failures.dart';
import 'package:yelima/features/medications/utils/medication_reminder_id.dart';

import '../../../../helpers/fakes.dart';

class MockRemote extends Mock implements MedicationRemoteDataSource {}

class MockNotifications extends Mock implements NotificationService {}

class MockSync extends Mock implements MutationSyncManager {}

class _FailingQueueDao extends PendingMutationsDao {
  _FailingQueueDao(super.db);

  @override
  Future<void> addPendingMutation(PendingMutationsCompanion mutation) =>
      throw Exception('disk full');
}

/// A database whose sync-queue writes fail, to check the medication rows roll back.
class FailingQueueDb extends AppDatabase {
  FailingQueueDb() : super(executor: testDb().executor);

  late final _failing = _FailingQueueDao(this);

  @override
  PendingMutationsDao get pendingMutationsDao => _failing;
}

void main() {
  late AppDatabase db;
  late MockNotifications notifications;
  late MockRemote remote;

  const form = MedicationForm(
    name: 'Amlodipine',
    dosage: '5mg',
    doses: {
      MedicationSection.morning: DoseSchedule(hour: 8, minute: 0, quantity: 1)
    },
  );

  MedicationRepositoryImpl repoWith(AppDatabase db,
      {bool online = false, RecentFetches? recent}) {
    final sync = MockSync();
    when(() => sync.triggerSync()).thenAnswer((_) async {});
    return MedicationRepositoryImpl(
      remoteDataSource: remote,
      connectivityService: FakeConnectivity(online: online),
      db: db,
      mutationSyncManager: sync,
      notificationService: notifications,
      session: SessionEpoch(),
      l10n: () => lookupAppLocalizations(const Locale('en')),
      recent: recent,
    );
  }

  void expectNoReminderScheduled() =>
      verifyNever(() => notifications.scheduleDailyReminder(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            time: any(named: 'time'),
          ));

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

  group('create', () {
    test('saves the medication and its queued sync, tagged with the user',
        () async {
      final id = (await withClock(Clock.fixed(DateTime(2026, 10, 23, 7)),
              () => repoWith(db).createMedication(form)))
          .getOrElse((_) => '');

      final meds = await db.select(db.medications).get();
      final queued = (await db.select(db.pendingMutations).get()).single;
      expect(meds.single.id, id);
      expect((queued.entityId, queued.action, queued.ownerUid),
          (id, 'createMedication', 'user_1'));
    });

    test('schedules a reminder in the app language, without the drug name',
        () async {
      await repoWith(db).createMedication(form);

      verify(() => notifications.scheduleDailyReminder(
            id: any(named: 'id'),
            title: 'Time for your medication',
            body: 'Open Yelima to see which medicine to take.',
            time: const TimeOfDay(hour: 8, minute: 0),
          )).called(1);
    });

    test('saves the name and dosage trimmed', () async {
      await repoWith(db).createMedication(
          const MedicationForm(name: '  Amlodipine ', dosage: ' 5mg ', doses: {
        MedicationSection.morning: DoseSchedule(hour: 8, minute: 0, quantity: 1)
      }));

      final row = (await db.select(db.medications).get()).single;
      expect((row.name, row.dosage), ('Amlodipine', '5mg'));
    });

    test('MED-EC-44: a name or dosage of only spaces is refused', () async {
      final result = await repoWith(db).createMedication(
          MedicationForm(name: '   ', dosage: '5mg', doses: form.doses));

      expect(
          result, left<AppFailure, String>(const MissingNameOrDosageFailure()));
      expect(await db.select(db.medications).get(), isEmpty);
    });

    test('a schedule is required', () async {
      final result = await repoWith(db).createMedication(
          const MedicationForm(name: 'Amlodipine', dosage: '5mg'));

      expect(result, left<AppFailure, String>(const MissingScheduleFailure()));
    });

    test('the same name and dosage, ignoring case and spaces, is a duplicate',
        () async {
      final repo = repoWith(db);
      await repo.createMedication(form);

      final result = await repo.createMedication(MedicationForm(
          name: ' amlodipine', dosage: '5MG ', doses: form.doses));

      expect(
          result, left<AppFailure, String>(const DuplicateMedicationFailure()));
      expect((await db.select(db.medications).get()).length, 1);
    });

    test('if queueing the sync fails, the medication is not saved either',
        () async {
      final failing = FailingQueueDb();
      addTearDown(failing.close);

      final result = await repoWith(failing).createMedication(form);

      expect(result.isLeft(), isTrue);
      expect(await failing.select(failing.medications).get(), isEmpty);
      expectNoReminderScheduled();
    });
  });

  test('delete removes the rows and queues the delete together', () async {
    final repo = repoWith(db);
    final id = (await repo.createMedication(form)).getOrElse((_) => '');
    await db.delete(db.pendingMutations).go();

    await repo.deleteMedication(id);

    expect(await db.select(db.medications).get(), isEmpty);
    expect((await db.select(db.pendingMutations).get()).single.action,
        'deleteMedication');
  });

  test('confirming a dose stamps it with the moment it was taken', () async {
    final repo = repoWith(db);
    final id = (await repo.createMedication(form)).getOrElse((_) => '');

    final tappedAt = DateTime(2026, 10, 23, 8, 30);
    await withClock(Clock.fixed(tappedAt),
        () => repo.confirmDose(id, MedicationSection.morning));

    final row = (await db.select(db.medications).get()).single;
    expect((row.taken, row.takenOn), (true, tappedAt));
    final confirm = (await db.select(db.pendingMutations).get())
        .singleWhere((m) => m.action == 'confirmMedication');
    expect(jsonDecode(confirm.payloadJson),
        {'section': 'MORNING', 'date': '2026-10-23'});
  });

  test(
      'a medicine opened again within a minute is not downloaded again, '
      'but is after the minute', () async {
    final details = MedicationDetailModel(
        id: '665f00000000000000000001',
        name: 'Amlodipine',
        dosage: '5mg',
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1));
    when(() => remote.getMedicationById('665f00000000000000000001'))
        .thenAnswer((_) async => details);
    final repo = repoWith(db, online: true, recent: RecentFetches());

    final start = DateTime(2026, 10, 25, 9);
    Future<void> openAt(Duration later) => withClock(
        Clock.fixed(start.add(later)),
        () => repo.getMedicationById('665f00000000000000000001'));

    await openAt(Duration.zero);
    await openAt(const Duration(seconds: 30));
    verify(() => remote.getMedicationById('665f00000000000000000001'))
        .called(1);

    await openAt(const Duration(minutes: 2));
    verify(() => remote.getMedicationById('665f00000000000000000001'))
        .called(1);
  });

  group('exact reminders', () {
    setUp(() {
      when(() => notifications.cancelAllReminders()).thenAnswer((_) async {});
    });

    test('once allowed, every reminder is scheduled again', () async {
      final repo = repoWith(db);
      await repo.createMedication(form);
      clearInteractions(notifications);
      when(() => notifications.allowExactReminders())
          .thenAnswer((_) async => true);

      await repo.allowExactReminders();

      verify(() => notifications.cancelAllReminders()).called(1);
      verify(() => notifications.scheduleDailyReminder(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            time: any(named: 'time'),
          )).called(1);
    });

    test('if the user says no, the existing reminders are left alone',
        () async {
      when(() => notifications.allowExactReminders())
          .thenAnswer((_) async => false);

      await repoWith(db).allowExactReminders();

      verifyNever(() => notifications.cancelAllReminders());
    });
  });

  group('refresh from the server', () {
    Medication row(String id, String section) => Medication(
          id: id,
          name: 'Old name',
          dosage: '5mg',
          section: section,
          taken: false,
          toBeTakenAt: DateTime(2026, 10, 23, section == 'MORNING' ? 8 : 20),
          morningJson: '{"m":1}',
        );

    MedicationModel remoteMed(String id) => MedicationModel(
          id: id,
          name: 'Amlodipine',
          dosage: '10mg',
          purpose: 'BP',
          toBeTakenAt: DateTime(2026, 10, 23, 8),
          taken: false,
        );

    MedicationListResponseModel page(List<MedicationModel> rows) =>
        MedicationListResponseModel(
            rows: rows,
            total: rows.length,
            pageSize: 100,
            page: 1,
            totalPages: 1);

    Future<Set<(String, String)>> rows() async =>
        (await db.select(db.medications).get())
            .map((m) => (m.id, m.section))
            .toSet();

    setUp(() {
      // Each test opens just one source; the others fail and change nothing.
      when(() => remote.getMedicationsBySection(any()))
          .thenThrow(Exception('offline'));
      when(() => remote.getAllMedications(pageSize: any(named: 'pageSize')))
          .thenThrow(Exception('offline'));
    });

    test('MED-EC-05: a med gone from one section keeps its other sections',
        () async {
      await db.medicationsDao.insertMedications(
          [row('srv-1', 'MORNING'), row('srv-1', 'EVENING')]);
      when(() => remote.getMedicationsBySection('MORNING'))
          .thenAnswer((_) async => <MedicationModel>[]);

      await repoWith(db, online: true).refreshAll();

      expect(await rows(), {('srv-1', 'EVENING')});
      verify(() => notifications
          .cancelReminder(medicationReminderId('srv-1', 'MORNING'))).called(1);
      verifyNever(() => notifications
          .cancelReminder(medicationReminderId('srv-1', 'EVENING')));
    });

    test('MED-EC-04: the list updates details and never adds UNKNOWN rows',
        () async {
      await db.medicationsDao.insertMedications([
        row('srv-1', 'MORNING'),
        row('srv-1', 'UNKNOWN'), // left by an older version
      ]);
      when(() => remote.getAllMedications(pageSize: 100))
          .thenAnswer((_) async => page([remoteMed('srv-1')]));

      await repoWith(db, online: true).refreshAll();

      final meds = await db.select(db.medications).get();
      expect(
          meds.map((m) => (m.id, m.section, m.name, m.dosage, m.morningJson)),
          [('srv-1', 'MORNING', 'Amlodipine', '10mg', '{"m":1}')]);
      verify(() => notifications
          .cancelReminder(medicationReminderId('srv-1', 'UNKNOWN'))).called(1);
      expectNoReminderScheduled();
    });

    test('rows with unsent changes are never overwritten', () async {
      await db.medicationsDao.insertMedications([row('srv-1', 'MORNING')]);
      await db.pendingMutationsDao.queueMutation(
          entityId: 'srv-1',
          entityType: 'medication',
          action: 'updateMedication',
          payload: {});
      when(() => remote.getMedicationsBySection('MORNING'))
          .thenAnswer((_) async => <MedicationModel>[]);

      await repoWith(db, online: true).refreshAll();

      expect(await rows(), {('srv-1', 'MORNING')});
    });

    test('offline, nothing is fetched', () async {
      await repoWith(db).refreshAll();

      verifyNever(() => remote.getMedicationsBySection(any()));
    });
  });
}

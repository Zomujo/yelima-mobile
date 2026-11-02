import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/notification_service.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/medications/data/datasources/medication_remote_datasource.dart';
import 'package:yelima/features/medications/data/repositories/medication_repository_impl.dart';
import 'package:yelima/features/medications/domain/entities/medication_section.dart';

import '../../../../helpers/fakes.dart';

class MockRemote extends Mock implements MedicationRemoteDataSource {}

class MockNotifications extends Mock implements NotificationService {}

void main() {
  late AppDatabase db;

  setUp(() => db = testDb());
  tearDown(() => db.close());

  Medication row(String id, String name, int hour, {int day = 29}) =>
      Medication(
        id: id,
        name: name,
        dosage: '5mg',
        section: 'MORNING',
        taken: false,
        toBeTakenAt: DateTime(2026, 10, day, hour),
      );

  test("today's doses come earliest first, then by name", () async {
    await db.medicationsDao.insertMedications([
      row('a', 'Lisinopril', 8),
      row('b', 'Amlodipine', 3, day: 28), // an older row keeps its old date
      row('c', 'Atenolol', 8),
    ]);
    final repo = MedicationRepositoryImpl(
      remoteDataSource: MockRemote(),
      connectivityService: FakeConnectivity(online: false),
      db: db,
      mutationSyncManager: FakeSync(),
      notificationService: MockNotifications(),
      session: SessionEpoch(),
      l10n: () => lookupAppLocalizations(const Locale('en')),
    );

    final doses = await withClock(Clock.fixed(DateTime(2026, 10, 29, 2)),
        () => repo.watchSection(MedicationSection.morning).first);

    expect(doses.map((d) => d.name), ['Amlodipine', 'Atenolol', 'Lisinopril']);
  });
}

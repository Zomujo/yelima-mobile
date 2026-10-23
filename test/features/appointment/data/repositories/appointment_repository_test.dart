import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'package:yelima/features/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:yelima/features/appointment/domain/entities/appointment_entity.dart';

import '../../../../helpers/fake_api.dart';
import '../../../../helpers/fakes.dart';

void main() {
  const listPath = 'api/v1/client/appointments';
  const nearestPath = 'api/v1/client/appointments/nearest';
  final now = DateTime(2026, 10, 23, 12);
  late AppDatabase db;
  late FakeApi api;

  Map<String, dynamic> row(String id, DateTime at) => {
        'id': id,
        'title': 'Review',
        'appointmentDate': at.toUtc().toIso8601String(),
        'hostPersonnel': {
          'id': 'p1',
          'userName': 'Dr Mensah',
          'facility': {'name': 'Korle Bu'}
        },
      };

  AppointmentRepositoryImpl repo({bool online = true}) =>
      AppointmentRepositoryImpl(
        remoteDataSource: AppointmentRemoteDataSource(apiClient: api.client),
        connectivityService: FakeConnectivity(online: online),
        db: db,
        session: SessionEpoch(),
      );

  setUp(() {
    db = testDb();
    api = FakeApi();
  });

  tearDown(() => db.close());

  Future<T> at<T>(Future<T> Function() body) =>
      withClock(Clock.fixed(now), body);

  test('a fetched page is cached and shown again offline', () async {
    api.on(
        'GET',
        listPath,
        FakeReply.ok({
          'rows': [
            row('a1', now.add(const Duration(days: 1))),
            row('a2', now.add(const Duration(days: 2)))
          ],
          'total': 2,
          'totalPages': 1,
        }));
    await at(() => repo().getAppointments(
        page: 1, pageSize: 3, filter: AppointmentFilter.upcoming));

    final offline = (await at(() => repo(online: false).getAppointments(
            page: 1, pageSize: 3, filter: AppointmentFilter.upcoming)))
        .toNullable();

    expect(offline?.rows.map((a) => a.id), ['a1', 'a2']);
  });

  test('cached pages split upcoming from past and page them', () async {
    api.on(
        'GET',
        listPath,
        FakeReply.ok({
          'rows': [
            row('past', now.subtract(const Duration(days: 1))),
            for (var i = 1; i <= 4; i++) row('u$i', now.add(Duration(days: i))),
          ],
        }));
    await at(() => repo().getAppointments(
        page: 1, pageSize: 3, filter: AppointmentFilter.upcoming));

    final page2 = (await at(() => repo().getCachedAppointments(
            page: 2, pageSize: 3, filter: AppointmentFilter.upcoming)))
        .toNullable();
    final past = (await at(() => repo().getCachedAppointments(
            page: 1, pageSize: 3, filter: AppointmentFilter.past)))
        .toNullable();

    expect(page2?.rows.map((a) => a.id), ['u4']);
    expect((page2?.totalPages, page2?.nextPage), (2, null));
    expect(past?.rows.map((a) => a.id), ['past']);
  });

  test('APPT-EC-27: no next appointment on the server clears a stale one',
      () async {
    await db.appointmentsDao.insertOrUpdateAppointment(
        AppointmentsCompanion.insert(
            id: 'old',
            title: 'Old',
            appointmentDate: now.add(const Duration(days: 1)),
            hostPersonnelId: 'p',
            hostPersonnelUserName: 'Dr',
            hostPersonnelFacilityName: 'F'));
    api.on('GET', nearestPath, FakeReply.ok(null));

    final nearest =
        (await at(() => repo().getNearestAppointment())).toNullable();

    expect(nearest, isNull);
    expect((await at(() => repo().getCachedNearestAppointment())).toNullable(),
        isNull);
  });

  test('offline, the nearest appointment comes from the phone', () async {
    api.on('GET', nearestPath,
        FakeReply.ok(row('a9', now.add(const Duration(hours: 3)))));
    await at(() => repo().getNearestAppointment());

    final offline =
        (await at(() => repo(online: false).getNearestAppointment()))
            .toNullable();

    expect(offline?.id, 'a9');
  });
}

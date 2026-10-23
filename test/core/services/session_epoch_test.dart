import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'package:yelima/features/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:yelima/features/appointment/domain/entities/appointment_entity.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/fakes.dart';

void main() {
  group('SessionEpoch', () {
    test('a captured epoch stops being current once the session ends',
        () async {
      final epoch = SessionEpoch();
      final captured = epoch.current;

      await epoch.onSessionEnded();

      expect(epoch.isCurrent(captured), isFalse);
      expect(
          () => epoch.ensure(captured), throwsA(isA<SessionEndedException>()));
      expect(() => epoch.ensure(epoch.current), returnsNormally);
    });
  });

  group('APPT-EC-02: a response that lands after logout is not cached', () {
    late AppDatabase db;
    late SessionEpoch session;
    late FakeApi api;
    late AppointmentRepositoryImpl repo;

    Map<String, dynamic> row(String id) => {
          'id': id,
          'title': 'Review',
          'appointmentDate': '2026-10-24T09:00:00.000Z',
          'hostPersonnel': {
            'id': 'p',
            'userName': 'Dr A',
            'facility': {'name': 'F'}
          },
        };

    setUp(() {
      db = testDb();
      session = SessionEpoch();
      api = FakeApi();
      repo = AppointmentRepositoryImpl(
        remoteDataSource: AppointmentRemoteDataSource(apiClient: api.client),
        connectivityService: FakeConnectivity(),
        db: db,
        session: session,
      );
    });

    tearDown(() => db.close());

    /// The user logs out while the server is still answering.
    FakeReply Function(RequestOptions) logoutMidRequest(FakeReply reply) =>
        (_) {
          session.onSessionEnded();
          return reply;
        };

    test('list', () async {
      api.onRequest(
          'GET',
          'api/v1/client/appointments',
          logoutMidRequest(FakeReply.ok({
            'rows': [row('a1')],
            'total': 1
          })));

      await repo.getAppointments(
          page: 1, pageSize: 3, filter: AppointmentFilter.upcoming);

      expect(await db.select(db.appointments).get(), isEmpty);
    });

    test('nearest', () async {
      api.onRequest('GET', 'api/v1/client/appointments/nearest',
          logoutMidRequest(FakeReply.ok(row('a9'))));

      await repo.getNearestAppointment();

      expect(await db.select(db.appointments).get(), isEmpty);
    });

    test('a response within the same session is still cached', () async {
      api.on(
          'GET', 'api/v1/client/appointments/nearest', FakeReply.ok(row('a9')));

      await repo.getNearestAppointment();

      expect((await db.select(db.appointments).get()).single.id, 'a9');
    });
  });
}

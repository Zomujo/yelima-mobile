import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import 'package:yelima/features/appointment/data/datasources/appointment_remote_datasource.dart';

import '../../../../helpers/fake_api.dart';

void main() {
  late FakeApi api;
  late AppointmentRemoteDataSourceImpl dataSource;

  const listPath = 'api/v1/client/appointments';
  const nearestPath = 'api/v1/client/appointments/nearest';

  Map<String, dynamic> appointment(String id, String date) => {
        'id': id,
        'title': 'Review',
        'appointmentDate': date,
        'hostPersonnel': {
          'id': 'p1',
          'userName': 'Dr Mensah',
          'facility': {'name': 'Korle Bu'},
        },
      };

  setUp(() {
    api = FakeApi();
    dataSource = AppointmentRemoteDataSourceImpl(apiClient: api.client);
  });

  group('getAppointments', () {
    test('parses the paginated envelope and sends page, pageSize and filter',
        () async {
      api.on(
          'GET',
          listPath,
          FakeReply.ok({
            'rows': [appointment('a1', '2026-10-24T09:00:00.000Z')],
            'total': 4,
            'pageSize': 3,
            'page': 1,
            'totalPages': 2,
            'nextPage': 2,
          }));

      final result = await dataSource.getAppointments(
          page: 1, pageSize: 3, filter: 'upcoming');

      expect(result.rows.single.id, 'a1');
      expect(result.rows.single.hostPersonnel.facility.name, 'Korle Bu');
      expect((result.total, result.totalPages, result.nextPage), (4, 2, 2));
      expect(api.sent('GET', listPath).single.queryParameters,
          {'page': 1, 'pageSize': 3, 'filter': 'upcoming'});
    });

    test('returns an empty list when rows is missing', () async {
      api.on('GET', listPath, FakeReply.ok({'total': 0}));

      final result = await dataSource.getAppointments(
          page: 1, pageSize: 3, filter: 'past');

      expect(result.rows, isEmpty);
    });

    test('APPT-EC-05: keeps the HTTP status code on server errors', () async {
      api.on('GET', listPath, FakeReply.error(500, 'boom'));

      expect(
        () => dataSource.getAppointments(page: 1, pageSize: 3, filter: 'past'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', '500')),
      );
    });

    test('APPT-EC-05: an offline request surfaces as NetworkException',
        () async {
      api.on('GET', listPath, const FakeReply.offline());

      expect(
        () => dataSource.getAppointments(page: 1, pageSize: 3, filter: 'past'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getNearestAppointment', () {
    test('returns null when the server has no upcoming appointment', () async {
      api.on('GET', nearestPath, FakeReply.ok(null));

      expect(await dataSource.getNearestAppointment(), isNull);
    });

    test('parses the appointment when present', () async {
      api.on('GET', nearestPath,
          FakeReply.ok(appointment('a9', '2026-10-24T09:00:00.000Z')));

      final result = await dataSource.getNearestAppointment();

      expect(result?.id, 'a9');
      expect(result?.hostPersonnel.userName, 'Dr Mensah');
    });

    test('APPT-EC-01: converts the UTC appointment time to local time',
        () async {
      api.on('GET', nearestPath,
          FakeReply.ok(appointment('a9', '2026-10-24T09:00:00.000Z')));

      final result = await dataSource.getNearestAppointment();

      expect(result?.appointmentDate.isUtc, isFalse);
    });
  });

  test('requestAppointment posts the note as a SCHEDULE request', () async {
    const path = 'api/v1/client/appointment-requests';
    api.on('POST', path, FakeReply.ok('req1', status: 201));

    await dataSource.requestAppointment(note: 'Headaches');

    expect(api.sent('POST', path).single.data,
        {'type': 'SCHEDULE', 'note': 'Headaches'});
  });
}

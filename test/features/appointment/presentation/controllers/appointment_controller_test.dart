import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/core_providers.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/features/appointment/appointment_providers.dart';
import 'package:yelima/features/appointment/domain/entities/appointment_entity.dart';
import 'package:yelima/features/appointment/domain/entities/appointment_list_response.dart';
import 'package:yelima/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:yelima/features/appointment/presentation/controllers/appointment_controller.dart';
import 'package:yelima/features/appointment/presentation/states/appointment_state.dart';

class MockRepo extends Mock implements AppointmentRepository {}

void main() {
  late MockRepo repo;
  late ProviderContainer container;
  late SessionLifecycleService session;

  AppointmentEntity appt(String id) => AppointmentEntity(
      id: id,
      title: id,
      appointmentDate: DateTime(2026, 10, 24),
      hostPersonnel: const HostPersonnelEntity(
          id: 'p', userName: 'Dr', facility: FacilityEntity(name: 'F')));

  AppointmentListResponse page(List<String> ids, {int page = 1}) =>
      AppointmentListResponse(
          rows: [for (final id in ids) appt(id)],
          total: ids.length,
          pageSize: 3,
          page: page,
          totalPages: 2);

  setUpAll(() => registerFallbackValue(AppointmentFilter.upcoming));

  setUp(() {
    repo = MockRepo();
    // Opening loads the first page of both lists; by default both are empty.
    when(() => repo.getCachedAppointments(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        filter: any(named: 'filter'))).thenAnswer((_) async => right(page([])));
    when(() => repo.getAppointments(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        filter: any(named: 'filter'))).thenAnswer((_) async => right(page([])));
    session = SessionLifecycleService();
    container = ProviderContainer(overrides: [
      appointmentRepositoryProvider.overrideWithValue(repo),
      sessionLifecycleProvider.overrideWithValue(session),
    ]);
  });

  tearDown(() => container.dispose());

  AppointmentState state() => container.read(appointmentControllerProvider);
  AppointmentController controller() =>
      container.read(appointmentControllerProvider.notifier);

  test('opening loads the first page of both lists', () async {
    controller();
    await pumpEventQueue();

    for (final filter in AppointmentFilter.values) {
      verify(() => repo.getAppointments(page: 1, pageSize: 3, filter: filter))
          .called(1);
    }
  });

  test('signing out clears the lists and the next visit', () async {
    when(() => repo.getCachedNearestAppointment())
        .thenAnswer((_) async => right(null));
    when(() => repo.getNearestAppointment())
        .thenAnswer((_) async => right(appt('next')));
    await controller().fetchNearestAppointment();
    expect(state().nearestAppointment?.id, 'next');

    await session.startSession('u');
    await session.endSession();

    expect(state(), const AppointmentState());
  });

  test('shows the cached page at once, then the server\'s', () async {
    final server = Completer<Either<AppFailure, AppointmentListResponse>>();
    when(() => repo.getCachedAppointments(
            page: 1, pageSize: 3, filter: AppointmentFilter.upcoming))
        .thenAnswer((_) async => right(page(['cached'])));
    when(() => repo.getAppointments(
        page: 1,
        pageSize: 3,
        filter: AppointmentFilter.upcoming)).thenAnswer((_) => server.future);

    final done =
        controller().fetchAppointments(filter: AppointmentFilter.upcoming);
    await pumpEventQueue();
    expect(state().upcomingState.items.single.id, 'cached');

    server.complete(right(page(['fresh'])));
    await done;
    expect(state().upcomingState.items.single.id, 'fresh');
    expect(state().pastState.items, isEmpty);
  });

  test('a failure with nothing cached shows the error', () async {
    when(() => repo.getCachedAppointments(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        filter: any(named: 'filter'))).thenAnswer((_) async => right(page([])));
    when(() => repo.getAppointments(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter')))
        .thenAnswer((_) async => left(const StorageFailure()));

    await controller().fetchAppointments(filter: AppointmentFilter.past);

    expect(state().pastState.error, const StorageFailure());
    expect(state().pastState.isLoading, isFalse);
  });

  test('a slow older nearest-appointment answer can\'t overwrite a newer one',
      () async {
    final slow = Completer<Either<AppFailure, AppointmentEntity?>>();
    when(() => repo.getCachedNearestAppointment())
        .thenAnswer((_) async => right(null));
    var calls = 0;
    when(() => repo.getNearestAppointment()).thenAnswer(
        (_) => calls++ == 0 ? slow.future : Future.value(right(appt('new'))));

    final first = controller().fetchNearestAppointment();
    await pumpEventQueue();
    await controller().fetchNearestAppointment();
    slow.complete(right(appt('old')));
    await first;

    expect(state().nearestAppointment?.id, 'new');
  });
}

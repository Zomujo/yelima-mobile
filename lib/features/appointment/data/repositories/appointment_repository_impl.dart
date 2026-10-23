import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/db/app_database.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/session_epoch.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_list_response.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

/// [AppointmentRepository] that caches every page it fetches.
class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
    required this.session,
  });

  final AppointmentRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;
  final SessionEpoch session;

  @override
  AsyncResult<AppointmentListResponse> getAppointments(
          {required int page,
          required int pageSize,
          required AppointmentFilter filter}) =>
      guard(() async {
        try {
          if (!await connectivityService.isConnected) {
            throw const NetworkFailure();
          }
          final epoch = session.current;
          final remote = await remoteDataSource.getAppointments(
              page: page, pageSize: pageSize, filter: filter.name);
          session.ensure(epoch);
          await db.transaction(() async {
            if (page == 1) {
              filter == AppointmentFilter.upcoming
                  ? await db.appointmentsDao.clearUpcomingAppointments()
                  : await db.appointmentsDao.clearPastAppointments();
            }
            for (final a in remote.rows) {
              await db.appointmentsDao.insertOrUpdateAppointment(_toRow(a));
            }
          });
          return remote;
        } catch (_) {
          return _cachedPage(page, pageSize, filter);
        }
      });

  @override
  AsyncResult<AppointmentListResponse> getCachedAppointments(
          {required int page,
          required int pageSize,
          required AppointmentFilter filter}) =>
      guard(() => _cachedPage(page, pageSize, filter));

  @override
  AsyncResult<AppointmentEntity?> getNearestAppointment() => guard(() async {
        try {
          if (!await connectivityService.isConnected) {
            throw const NetworkFailure();
          }
          final epoch = session.current;
          final remote = await remoteDataSource.getNearestAppointment();
          session.ensure(epoch);
          remote == null
              // None on the server: drop a stale one cached here (APPT-EC-27).
              ? await db.appointmentsDao.clearUpcomingAppointments()
              : await db.appointmentsDao
                  .insertOrUpdateAppointment(_toRow(remote));
          return remote;
        } catch (_) {
          return (await _sorted(AppointmentFilter.upcoming)).firstOrNull;
        }
      });

  @override
  AsyncResult<AppointmentEntity?> getCachedNearestAppointment() => guard(
      () async => (await _sorted(AppointmentFilter.upcoming)).firstOrNull);

  /// Cached appointments for [filter]: upcoming soonest first, past latest first.
  Future<List<AppointmentEntity>> _sorted(AppointmentFilter filter) async {
    final now = clock.now();
    final upcoming = filter == AppointmentFilter.upcoming;
    return [
      for (final a in await db.appointmentsDao.getAllAppointments())
        if (upcoming
            ? a.appointmentDate.isAfter(now)
            : a.appointmentDate.isBefore(now))
          _toEntity(a)
    ]..sort((a, b) => upcoming
        ? a.appointmentDate.compareTo(b.appointmentDate)
        : b.appointmentDate.compareTo(a.appointmentDate));
  }

  Future<AppointmentListResponse> _cachedPage(
      int page, int pageSize, AppointmentFilter filter) async {
    final all = await _sorted(filter);
    final totalPages = all.isEmpty ? 1 : (all.length / pageSize).ceil();
    return AppointmentListResponse(
      rows: all.skip((page - 1) * pageSize).take(pageSize).toList(),
      total: all.length,
      pageSize: pageSize,
      page: page,
      totalPages: totalPages,
      nextPage: page < totalPages ? page + 1 : null,
    );
  }

  static AppointmentsCompanion _toRow(AppointmentEntity a) =>
      AppointmentsCompanion(
        id: Value(a.id),
        title: Value(a.title),
        appointmentDate: Value(a.appointmentDate),
        hostPersonnelId: Value(a.hostPersonnel.id),
        hostPersonnelUserName: Value(a.hostPersonnel.userName),
        hostPersonnelFacilityName: Value(a.hostPersonnel.facility.name),
      );

  static AppointmentEntity _toEntity(Appointment a) => AppointmentEntity(
        id: a.id,
        title: a.title,
        appointmentDate: a.appointmentDate,
        hostPersonnel: HostPersonnelEntity(
          id: a.hostPersonnelId,
          userName: a.hostPersonnelUserName,
          facility: FacilityEntity(name: a.hostPersonnelFacilityName),
        ),
      );
}

import 'package:fpdart/fpdart.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/custom_types.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_list_response.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../../../../core/db/app_database.dart';
import 'package:drift/drift.dart' as drift;

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;

  AppointmentRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
  });

  @override
  AsyncResponse<AppointmentListResponse> getAppointments({
    required int page,
    required int pageSize,
    required String filter,
    bool forceRefresh = false,
  }) async {
    if (await connectivityService.isConnected) {
      try {
        final remoteData = await remoteDataSource.getAppointments(
          page: page,
          pageSize: pageSize,
          filter: filter,
        );

        await db.transaction(() async {
          if (page == 1) {
            if (filter == 'upcoming') {
              await db.appointmentsDao.clearUpcomingAppointments();
            } else if (filter == 'past') {
              await db.appointmentsDao.clearPastAppointments();
            }
          }

          for (var row in remoteData.rows) {
            await db.appointmentsDao
                .insertOrUpdateAppointment(AppointmentsCompanion(
              id: drift.Value(row.id),
              title: drift.Value(row.title),
              appointmentDate: drift.Value(row.appointmentDate),
              hostPersonnelId: drift.Value(row.hostPersonnel.id),
              hostPersonnelUserName: drift.Value(row.hostPersonnel.userName),
              hostPersonnelFacilityName:
                  drift.Value(row.hostPersonnel.facility.name),
            ));
          }
        });

        return Right(remoteData);
      } catch (e) {
        return getLocalAppointments(page: page, pageSize: pageSize, filter: filter);
      }
    } else {
      return getLocalAppointments(page: page, pageSize: pageSize, filter: filter);
    }
  }

  @override
  AsyncResponse<AppointmentListResponse> getLocalAppointments({
      required int page, required int pageSize, required String filter}) async {
    try {
      final localAppointments = await db.appointmentsDao.getAllAppointments();
      final now = DateTime.now();
      final filtered = localAppointments
          .where((a) => filter == 'upcoming'
              ? a.appointmentDate.isAfter(now)
              : a.appointmentDate.isBefore(now))
          .toList()
        ..sort((a, b) => filter == 'upcoming'
            ? a.appointmentDate.compareTo(b.appointmentDate)
            : b.appointmentDate.compareTo(a.appointmentDate));

      final start = (page - 1) * pageSize;
      final pageRows = start >= filtered.length
          ? <Appointment>[]
          : filtered.sublist(
              start, (start + pageSize).clamp(0, filtered.length));

      final entities = pageRows
          .map((a) => AppointmentEntity(
                id: a.id,
                title: a.title,
                appointmentDate: a.appointmentDate,
                hostPersonnel: HostPersonnelEntity(
                  id: a.hostPersonnelId,
                  userName: a.hostPersonnelUserName,
                  facility: FacilityEntity(name: a.hostPersonnelFacilityName),
                ),
              ))
          .toList();

      final totalPages =
          filtered.isEmpty ? 1 : (filtered.length / pageSize).ceil();

      return Right(AppointmentListResponse(
        rows: entities,
        total: filtered.length,
        pageSize: pageSize,
        page: page,
        totalPages: totalPages,
        nextPage: page < totalPages ? page + 1 : null,
      ));
    } catch (e) {
      return const Left('Failed to load cached appointments');
    }
  }

  @override
  AsyncResponse<AppointmentEntity?> getNearestAppointment() async {
    if (await connectivityService.isConnected) {
      try {
        final remoteData = await remoteDataSource.getNearestAppointment();
        if (remoteData != null) {
          await db.appointmentsDao
              .insertOrUpdateAppointment(AppointmentsCompanion(
            id: drift.Value(remoteData.id),
            title: drift.Value(remoteData.title),
            appointmentDate: drift.Value(remoteData.appointmentDate),
            hostPersonnelId: drift.Value(remoteData.hostPersonnel.id),
            hostPersonnelUserName:
                drift.Value(remoteData.hostPersonnel.userName),
            hostPersonnelFacilityName:
                drift.Value(remoteData.hostPersonnel.facility.name),
          ));
        } else {
          // Edge Case 27: Clear ghost nearest appointment from local cache if it doesn't exist remotely
          await db.appointmentsDao.clearUpcomingAppointments();
        }
        return Right(remoteData);
      } catch (e) {
        return getLocalNearestAppointment();
      }
    } else {
      return getLocalNearestAppointment();
    }
  }

  @override
  AsyncResponse<AppointmentEntity?>
      getLocalNearestAppointment() async {
    try {
      final localApts = await db.appointmentsDao.getAllAppointments();
      final now = DateTime.now();

      final upcoming = localApts
          .where((a) => a.appointmentDate.isAfter(now))
          .toList()
        ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

      if (upcoming.isEmpty) {
        return const Right(null);
      }

      final nearest = upcoming.first;
      return Right(AppointmentEntity(
        id: nearest.id,
        title: nearest.title,
        appointmentDate: nearest.appointmentDate,
        hostPersonnel: HostPersonnelEntity(
          id: nearest.hostPersonnelId,
          userName: nearest.hostPersonnelUserName,
          facility: FacilityEntity(name: nearest.hostPersonnelFacilityName),
        ),
      ));
    } catch (e) {
      return const Left('Failed to load cached nearest appointment');
    }
  }

  @override
  AsyncResponse<void> requestAppointment({required String note}) async {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        await remoteDataSource.requestAppointment(note: note);
        return const Right(null);
      },
      connectivityService: connectivityService,
    );
  }
}

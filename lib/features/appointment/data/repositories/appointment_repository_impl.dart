import 'package:flutter/foundation.dart';
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

  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  AsyncResponse<AppointmentListResponse> getAppointments({
    required int page,
    required int pageSize,
    required String filter,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _lastFetchTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime!) < _cacheDuration) {
        debugPrint("Skipping remote fetch for Appointments. Cache is fresh.");
        return _fetchLocalAppointments(page, pageSize, filter);
      }
    }

    if (await connectivityService.isConnected) {
      try {
        final remoteData = await remoteDataSource.getAppointments(
          page: page,
          pageSize: pageSize,
          filter: filter,
        );
        
        await db.transaction(() async {
          for (var row in remoteData.rows) {
            await db.appointmentsDao.insertOrUpdateAppointment(AppointmentsCompanion(
              id: drift.Value(row.id),
              title: drift.Value(row.title),
              appointmentDate: drift.Value(row.appointmentDate),
              hostPersonnelId: drift.Value(row.hostPersonnel.id),
              hostPersonnelUserName: drift.Value(row.hostPersonnel.userName),
              hostPersonnelFacilityName: drift.Value(row.hostPersonnel.facility.name),
            ));
          }
        });

        _lastFetchTime = DateTime.now();
        return Right(remoteData);
      } catch (e) {
        return _fetchLocalAppointments(page, pageSize, filter);
      }
    } else {
      return _fetchLocalAppointments(page, pageSize, filter);
    }
  }

  Future<Either<String, AppointmentListResponse>> _fetchLocalAppointments(
      int page, int pageSize, String filter) async {
    try {
      final localAppointments = await db.appointmentsDao.getAllAppointments();
      final now = DateTime.now();
      final filtered = localAppointments.where((a) => filter == 'upcoming'
          ? a.appointmentDate.isAfter(now)
          : a.appointmentDate.isBefore(now)).toList()
        ..sort((a, b) => filter == 'upcoming'
            ? a.appointmentDate.compareTo(b.appointmentDate)
            : b.appointmentDate.compareTo(a.appointmentDate));

      final start = (page - 1) * pageSize;
      final pageRows = start >= filtered.length
          ? <Appointment>[]
          : filtered.sublist(start, (start + pageSize).clamp(0, filtered.length));

      final entities = pageRows.map((a) => AppointmentEntity(
        id: a.id,
        title: a.title,
        appointmentDate: a.appointmentDate,
        hostPersonnel: HostPersonnelEntity(
          id: a.hostPersonnelId,
          userName: a.hostPersonnelUserName,
          facility: FacilityEntity(name: a.hostPersonnelFacilityName),
        ),
      )).toList();

      final totalPages = filtered.isEmpty ? 1 : (filtered.length / pageSize).ceil();

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
        return Right(remoteData);
      } catch (e) {
        return _fetchLocalNearestAppointment();
      }
    } else {
      return _fetchLocalNearestAppointment();
    }
  }

  Future<Either<String, AppointmentEntity?>> _fetchLocalNearestAppointment() async {
    try {
      final localApts = await db.appointmentsDao.getAllAppointments();
      final now = DateTime.now();
      
      final upcoming = localApts.where((a) => a.appointmentDate.isAfter(now)).toList()
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
  Stream<List<AppointmentEntity>> watchAppointments() {
    return db.appointmentsDao.watchAllAppointments().map((localApts) {
      return localApts.map((a) => AppointmentEntity(
        id: a.id,
        title: a.title,
        appointmentDate: a.appointmentDate,
        hostPersonnel: HostPersonnelEntity(
          id: a.hostPersonnelId,
          userName: a.hostPersonnelUserName,
          facility: FacilityEntity(name: a.hostPersonnelFacilityName),
        ),
      )).toList();
    });
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

  @override
  void invalidateCache() {
    _lastFetchTime = null;
  }
}

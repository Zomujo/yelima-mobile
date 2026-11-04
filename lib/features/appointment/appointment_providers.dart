import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/core_providers.dart';
import 'data/datasources/appointment_remote_datasource.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'domain/repositories/appointment_repository.dart';

part 'appointment_providers.g.dart';

/// Appointments from the server.
@Riverpod(keepAlive: true)
AppointmentRemoteDataSource appointmentRemoteDataSource(Ref ref) =>
    AppointmentRemoteDataSource(apiClient: ref.watch(apiClientProvider));

/// Appointments, cached on the phone.
@Riverpod(keepAlive: true)
AppointmentRepository appointmentRepository(Ref ref) =>
    AppointmentRepositoryImpl(
      remoteDataSource: ref.watch(appointmentRemoteDataSourceProvider),
      connectivityService: ref.watch(connectivityProvider),
      db: ref.watch(appDatabaseProvider),
      session: ref.watch(sessionEpochProvider),
      recent: ref.watch(recentFetchesProvider),
    );

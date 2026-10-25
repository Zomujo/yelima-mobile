import 'package:get_it/get_it.dart';

import '../../core/services/recent_fetches.dart';

import 'data/datasources/appointment_remote_datasource.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'domain/repositories/appointment_repository.dart';
import 'presentation/controllers/appointment_controller.dart';

/// Registers the appointments feature.
void initAppointment(GetIt sl) {
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
      () => AppointmentRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton<AppointmentRepository>(() =>
      AppointmentRepositoryImpl(
          remoteDataSource: sl(),
          connectivityService: sl(),
          db: sl(),
          session: sl(),
          recent: sl<RecentFetches>()));
  sl.registerFactory(() => AppointmentController(repository: sl()));
}

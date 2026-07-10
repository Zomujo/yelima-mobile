import 'package:get_it/get_it.dart';

import 'data/datasources/appointment_remote_datasource.dart';
import 'domain/repositories/appointment_repository.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'presentation/controllers/appointment_controller.dart';

void initAppointment(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
      () => AppointmentRemoteDataSourceImpl(apiClient: sl()));

  // Repository
  sl.registerLazySingleton<AppointmentRepository>(() =>
      AppointmentRepositoryImpl(
          remoteDataSource: sl(), connectivityService: sl(), db: sl()));

  // Controller
  sl.registerFactory(() => AppointmentController(repository: sl()));
}

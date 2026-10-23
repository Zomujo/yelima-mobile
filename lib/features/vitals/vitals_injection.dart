import 'package:get_it/get_it.dart';

import '../../core/managers/mutation_sync_manager.dart';
import 'data/datasources/vitals_local_datasource.dart';
import 'data/datasources/vitals_remote_datasource.dart';
import 'data/datasources/vitals_remote_mutation_source.dart';
import 'data/repositories/vitals_repository_impl.dart';
import 'domain/repositories/vitals_repository.dart';
import 'domain/usecases/save_vital_reading_usecase.dart';
import 'presentation/controllers/reading_logging_controller.dart';

void initVitals(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<VitalsRemoteDataSource>(
      () => VitalsRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<VitalsLocalDataSource>(
      () => VitalsLocalDataSourceImpl(database: sl()));

  // Repository
  sl.registerLazySingleton<VitalsRepository>(() => VitalsRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        connectivityService: sl(),
        session: sl(),
        db: sl(),
      ));

  // Use cases
  sl.registerLazySingleton<SaveVitalReadingUseCase>(
      () => SaveVitalReadingUseCase(sl()));

  // Controllers
  sl.registerFactory(() => ReadingLoggingController(
        repository: sl(),
        saveVitalReadingUseCase: sl(),
      ));

  // Registered last: the source needs this feature's datasources above.
  sl<MutationSyncManager>()
      .registerSource('vital_history', VitalsRemoteMutationSource(sl(), sl()));
}

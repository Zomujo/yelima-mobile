import 'package:get_it/get_it.dart';

import '../../core/managers/mutation_sync_manager.dart';
import 'data/datasources/vitals_remote_datasource.dart';
import 'data/datasources/vitals_remote_mutation_source.dart';
import 'data/repositories/vitals_repository_impl.dart';
import 'domain/repositories/vitals_repository.dart';

/// Registers the vitals feature.
void initVitals(GetIt sl) {
  sl.registerLazySingleton<VitalsRemoteDataSource>(
      () => VitalsRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton<VitalsRepository>(() => VitalsRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        session: sl(),
        db: sl(),
      ));

  // Registered last: the source needs this feature's datasources above.
  sl<MutationSyncManager>()
      .registerSource('vital_history', VitalsRemoteMutationSource(sl(), sl()));
}

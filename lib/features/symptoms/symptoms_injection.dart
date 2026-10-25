import 'package:get_it/get_it.dart';

import '../../core/services/recent_fetches.dart';

import '../../core/managers/mutation_sync_manager.dart';
import 'data/datasources/symptoms_remote_data_source.dart';
import 'data/datasources/symptoms_remote_mutation_source.dart';
import 'data/repositories/symptoms_repository_impl.dart';
import 'domain/repositories/symptoms_repository.dart';
import 'presentation/controllers/symptoms_controller.dart';

/// Registers the symptoms feature.
void initSymptoms(GetIt sl) {
  sl.registerLazySingleton<SymptomsRemoteDataSource>(
      () => SymptomsRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton<SymptomsRepository>(() => SymptomsRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        db: sl(),
        session: sl(),
        recent: sl<RecentFetches>(),
      ));
  sl.registerFactory(() => SymptomsController(repository: sl()));

  // Registered last: the source needs this feature's datasources above.
  sl<MutationSyncManager>()
      .registerSource('symptom', SymptomsRemoteMutationSource(sl(), sl()));
}

import 'package:get_it/get_it.dart';

import 'data/datasources/progress_remote_datasource.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'domain/repositories/progress_repository.dart';
import 'presentation/controllers/progress_controller.dart';

/// Registers the progress feature.
void initProgress(GetIt sl) {
  sl.registerLazySingleton(() => ProgressRemoteDataSource(sl()));
  sl.registerLazySingleton<ProgressRepository>(() => ProgressRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        db: sl(),
        session: sl(),
      ));
  sl.registerLazySingleton(() => ProgressController(sl()));
}

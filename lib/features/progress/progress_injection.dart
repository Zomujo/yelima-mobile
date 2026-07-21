import 'package:get_it/get_it.dart';
import 'data/datasources/progress_remote_datasource.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'domain/repositories/progress_repository.dart';
import 'presentation/controllers/progress_controller.dart';

void initProgress(GetIt sl) {
  sl.registerLazySingleton<ProgressRemoteDataSource>(
      () => ProgressRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ProgressRepository>(() => ProgressRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        db: sl(),
      ));
  sl.registerFactory(() => ProgressController(sl()));
}

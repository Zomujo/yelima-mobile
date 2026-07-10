import 'package:get_it/get_it.dart';

import 'data/datasources/home_metrics_remote_datasource.dart';
import 'data/datasources/home_metrics_local_datasource.dart';
import 'domain/repositories/home_metrics_repository.dart';
import 'data/repositories/home_metrics_repository_impl.dart';
import 'presentation/controllers/home_metrics_controller.dart';

void initHome(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<HomeMetricsRemoteDataSource>(
      () => HomeMetricsRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<HomeMetricsLocalDataSource>(
      () => HomeMetricsLocalDataSourceImpl(database: sl()));

  // Repository
  sl.registerLazySingleton<HomeMetricsRepository>(
      () => HomeMetricsRepositoryImpl(
            remoteDataSource: sl(),
            localDataSource: sl(),
            connectivityService: sl(),
          ));

  // Controller
  sl.registerFactory<HomeMetricsController>(
      () => HomeMetricsController(repository: sl()));
}

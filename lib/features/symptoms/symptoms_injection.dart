import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import 'data/datasources/symptoms_remote_data_source.dart';
import 'data/repositories/symptoms_repository_impl.dart';
import 'domain/repositories/symptoms_repository.dart';
import 'presentation/controllers/symptoms_controller.dart';

final sl = GetIt.instance;

void initSymptoms() {
  // Data sources
  sl.registerLazySingleton<SymptomsRemoteDataSource>(
    () => SymptomsRemoteDataSourceImpl(apiClient: sl<APIClient>()),
  );

  // Repository
  sl.registerLazySingleton<SymptomsRepository>(
    () => SymptomsRepositoryImpl(
      remoteDataSource: sl(),
      connectivityService: sl(),
      db: sl(),
    ),
  );

  // Controllers
  sl.registerFactory(
    () => SymptomsController(repository: sl()),
  );
}

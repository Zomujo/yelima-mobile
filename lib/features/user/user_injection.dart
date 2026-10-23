import 'package:get_it/get_it.dart';

import '../../core/managers/mutation_sync_manager.dart';
import 'data/datasources/user_remote_data_source.dart';
import 'data/datasources/user_remote_mutation_source.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/user_repository.dart';
import 'presentation/controllers/user_controller.dart';

/// Registers the user feature.
void initUser(GetIt sl) {
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSource(firebaseAuth: sl(), apiClient: sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        db: sl(),
        session: sl(),
      ));
  sl.registerLazySingleton<UserController>(
      () => UserController(repository: sl()));

  // Registered last: the source needs this feature's datasources above.
  sl<MutationSyncManager>()
      .registerSource('user_profile', UserRemoteMutationSource(sl()));
}

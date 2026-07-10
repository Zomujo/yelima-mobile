import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'data/datasources/user_remote_data_source.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/user_repository.dart';
import 'presentation/controllers/user_controller.dart';

void initUser(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSource(
        firebaseAuth: FirebaseAuth.instance,
        apiClient: sl(),
      ));

  // Repositories
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        db: sl(),
      ));

  // State Management
  sl.registerLazySingleton<UserController>(() => UserController(repository: sl()));
}

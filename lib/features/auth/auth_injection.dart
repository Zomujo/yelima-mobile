import 'package:get_it/get_it.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/controllers/auth_controller.dart';

import 'package:firebase_auth/firebase_auth.dart';

void initAuth(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(
        firebaseAuth: FirebaseAuth.instance,
      ));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService:
            sl(), // Using the singleton from injection_container instead of creating a new one
        db: sl(),
      ));

  // State Management
  sl.registerLazySingleton<AuthController>(
      () => AuthController(repository: sl(), sessionLifecycleService: sl()));
}

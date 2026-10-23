import 'package:get_it/get_it.dart';

import '../user/presentation/controllers/user_controller.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/controllers/auth_controller.dart';

/// Registers the auth feature.
void initAuth(GetIt sl) {
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(firebaseAuth: sl(), apiClient: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        db: sl(),
        notifications: sl(),
      ));
  sl.registerLazySingleton<AuthController>(() => AuthController(
        repository: sl(),
        session: sl(),
        syncManager: sl(),
        sessionExpiry: sl(),
        // Resolved lazily, so creating AuthController doesn't create UserController early.
        onUserChanged: (user) => sl<UserController>().onUserChanged(user),
      ));
}

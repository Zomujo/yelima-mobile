import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/core_providers.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';

export 'presentation/controllers/auth_controller.dart'
    show authControllerProvider;

part 'auth_providers.g.dart';

/// Firebase sign-in and the auth API.
@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) => AuthRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    apiClient: ref.watch(apiClientProvider));

/// Sign-in, sign-up and account deletion.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      remoteDataSource: ref.watch(authRemoteDataSourceProvider),
      connectivityService: ref.watch(connectivityProvider),
      db: ref.watch(appDatabaseProvider),
      notifications: ref.watch(notificationServiceProvider),
    );

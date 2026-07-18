import 'package:fpdart/fpdart.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/custom_types.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
  });

  @override
  AsyncResponse<void> signIn(String email, String password) {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        await remoteDataSource.signInWithEmail(email, password);
        return right(null);
      },
      connectivityService: connectivityService,
      operationName: 'AuthRepositoryImpl.signIn',
    );
  }

  @override
  AsyncResponse<void> register(String email, String password) {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        await remoteDataSource.signUpWithEmail(email, password);
        return right(null);
      },
      connectivityService: connectivityService,
      operationName: 'AuthRepositoryImpl.register',
    );
  }

  @override
  AsyncResponse<void> signInWithGoogle() {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        await remoteDataSource.signInWithGoogle();
        return right(null);
      },
      connectivityService: connectivityService,
      operationName: 'AuthRepositoryImpl.signInWithGoogle',
    );
  }

  @override
  AsyncResponse<void> signInWithApple() {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        await remoteDataSource.signInWithApple();
        return right(null);
      },
      connectivityService: connectivityService,
      operationName: 'AuthRepositoryImpl.signInWithApple',
    );
  }

  @override
  AsyncResponse<void> sendPasswordResetEmail(String email) {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        await remoteDataSource.sendPasswordResetEmail(email);
        return right(null);
      },
      connectivityService: connectivityService,
      operationName: 'AuthRepositoryImpl.sendPasswordResetEmail',
    );
  }

  @override
  AsyncResponse<void> signOut() {
    /// No network check here by design - AuthController.signOut() already
    /// requires connectivity and forces a completed mutation sync before
    /// calling this, so by the time we get here the device is expected to
    /// be online. This method itself stays network-check-free so it still
    /// degrades gracefully if called from anywhere else that doesn't do
    /// that pre-check (e.g. a forced/expired-session sign-out).
    return ExceptionWrapper.runAsync<void>(
      () async {
        await remoteDataSource.signOut();
        return right(null);
      },
      operationName: 'AuthRepositoryImpl.signOut',
    );
  }

  @override
  AsyncResponse<void> deleteAccount({String? password}) {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        await remoteDataSource.deleteAccount(password: password);
        return right(null);
      },
      connectivityService: connectivityService,
      operationName: 'AuthRepositoryImpl.deleteAccount',
    );
  }
}

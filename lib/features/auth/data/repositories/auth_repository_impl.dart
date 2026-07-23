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

  /// Authenticates a user using email and password credentials.
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

  /// Registers a new user account with the provided email and password.
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

  /// Authenticates a user using their Google account.
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

  /// Authenticates a user using their Apple ID.
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

  /// Sends a password reset link to the specified email address.
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

  /// Signs the current user out of the application.
  @override
  AsyncResponse<void> signOut() {
    return ExceptionWrapper.runAsync<void>(
      () async {
        await remoteDataSource.signOut();
        return right(null);
      },
      operationName: 'AuthRepositoryImpl.signOut',
    );
  }

  /// Permanently deletes the current user's account and associated data.
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

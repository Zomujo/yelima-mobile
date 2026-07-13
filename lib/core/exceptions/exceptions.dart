import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../utils/custom_types.dart';
import '../utils/logger.dart';
import '../services/connectivity_service.dart';

// --- Legacy Failure classes (for existing template logic) ---
abstract class Failure {
  final String message;
  final String? code;
  Failure(this.message, {this.code});
}

class ApiException extends ErrorException {
  final String? code;
  const ApiException(String? message, {this.code}) : super(message: message);

  factory ApiException.fromDioError(DioException e) {
    dynamic message;
    if (e.response?.data is Map) {
      final map = e.response!.data as Map;
      message = map['message'] ?? map['error'] ?? map['errors']?.toString();
    }
    message ??= e.message;
    return ApiException(message?.toString() ?? "An unexpected error occurred",
        code: e.response?.statusCode?.toString());
  }
}

class ServerFailure extends Failure {
  ServerFailure([super.message = "Server error", String? code])
      : super(code: code);
}

class NetworkFailure extends Failure {
  NetworkFailure([super.message = "No internet connection"]);
}

class CacheFailure extends Failure {
  CacheFailure([super.message = "Cache error"]);
}

class AuthFailure extends Failure {
  AuthFailure([super.message = "Authentication failed"]);
}

class ValidationFailure extends Failure {
  ValidationFailure([super.message = "Invalid input"]);
}

// --- New ExceptionWrapper Architecture (Coasted / Zyptyk) ---
class ErrorException extends Equatable implements Exception {
  final String? message;

  const ErrorException({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return message ?? super.toString();
  }
}

class UserCanceledException extends ErrorException {
  const UserCanceledException([String? message])
      : super(message: message ?? "User cancelled the operation.");
}

class NetworkException extends ErrorException {
  const NetworkException([String? message])
      : super(message: message ?? "No internet connection.");
}

class DuplicateAccountException extends ErrorException {
  const DuplicateAccountException([String? message]) : super(message: message);
}

class ReauthenticationCancelledException extends ErrorException {
  const ReauthenticationCancelledException([String? message])
      : super(message: message ?? "Re-authentication was cancelled.");
}

class UnauthenticatedException extends ErrorException {
  const UnauthenticatedException([String? message])
      : super(message: message ?? "User is unauthenticated.");
}

class ExceptionWrapper {
  ExceptionWrapper._();

  static AsyncResponse<T> runAsync<T>(
    Future<Either<String, T>> Function() func, {
    String? operationName,
  }) async {
    final name = operationName ?? 'AsyncOperation';
    AppLogger.log('⏳ Starting: $name...', type: LogType.debug);
    final stopwatch = Stopwatch()..start();

    try {
      final result = await func();
      stopwatch.stop();

      result.fold(
        (failure) => AppLogger.log(
          '❌ Failed: $name [${stopwatch.elapsedMilliseconds}ms]\nReason: $failure',
          type: LogType.warning,
        ),
        (success) => AppLogger.log(
          '✅ Completed: $name [${stopwatch.elapsedMilliseconds}ms]',
          type: LogType.success,
        ),
      );

      return result;
    } on AssertionError catch (e, stack) {
      stopwatch.stop();
      AppLogger.e('Assertion failed during $name', e, stack);
      return left(e.message?.toString() ?? 'Assertion failed');
    } on NetworkException catch (e) {
      stopwatch.stop();
      AppLogger.w('Network unavailable during $name');
      return left(e.message ?? 'No internet connection');
    } on SignInWithAppleAuthorizationException catch (e, stack) {
      stopwatch.stop();
      if (e.code == AuthorizationErrorCode.canceled) {
        AppLogger.w('Apple sign-in cancelled during $name');
        return left('Apple sign-in cancelled');
      }
      AppLogger.e('Apple Auth Exception during $name', e, stack);
      return left(e.message);
    } on PlatformException catch (e, stack) {
      stopwatch.stop();
      if (e.code == 'sign_in_canceled' || e.code == 'CANCELED') {
        AppLogger.w('Sign in cancelled during $name');
        return left('Sign in cancelled');
      }
      AppLogger.e('Platform Exception during $name', e, stack);
      return left(e.message ?? 'A platform error occurred');
    } on FirebaseAuthException catch (e, stack) {
      stopwatch.stop();
      AppLogger.e('Firebase Auth Exception during $name (${e.code})', e, stack);
      return left(_friendlyAuthMessage(e));
    } on FirebaseException catch (e, stack) {
      stopwatch.stop();
      if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        AppLogger.w('Network/Unavailable during $name: ${e.message}');
        return left(
            "Service unavailable. Please check your internet connection.");
      }
      AppLogger.e('Firebase Exception during $name', e, stack);
      return left(e.message ?? 'A Firebase error occurred');
    } on UserCanceledException catch (e) {
      stopwatch.stop();
      AppLogger.w('User cancelled during $name');
      return left(e.message.toString());
    } on DuplicateAccountException catch (e, stack) {
      stopwatch.stop();
      AppLogger.e('Duplicate Account Exception during $name', e, stack);
      return left(e.message.toString());
    } on ErrorException catch (e, stack) {
      stopwatch.stop();
      AppLogger.e('Error Exception during $name', e, stack);
      return left(e.message.toString());
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e('Unhandled Exception or Error during $name', e, stack);
      return left(e.toString());
    }
  }

  static String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'credential-already-in-use':
        return 'This credential is already linked to a different account.';
      case 'user-mismatch':
        return 'Please authenticate with the exact account linked to this profile.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'A network error has occurred. Please check your connection.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }

  /// Runs an async operation only if there is an active internet connection.
  /// Throws [NetworkException] internally if offline, which is caught and returned as a Left(failure).
  static AsyncResponse<T> runAsyncWithNetworkCheck<T>(
    Future<Either<String, T>> Function() func, {
    required ConnectivityService connectivityService,
    String? operationName,
  }) async {
    return runAsync<T>(
      () async {
        if (!await connectivityService.isConnected) {
          throw const NetworkException();
        }
        return await func();
      },
      operationName: operationName,
    );
  }

  static void runSync(void Function() func, {String? operationName}) {
    final name = operationName ?? 'SyncOperation';
    try {
      func();
    } catch (e, stack) {
      AppLogger.e('Sync operation "$name" failed', e, stack);
    }
  }
}

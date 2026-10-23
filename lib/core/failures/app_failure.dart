import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show DriftWrappedException;
import 'package:drift/native.dart' show SqliteException;
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../exceptions/exceptions.dart';

/// A result that is either an [AppFailure] or a value.
typedef AsyncResult<T> = Future<Either<AppFailure, T>>;

/// Everything that can go wrong in the app, as a value the UI can switch on.
sealed class AppFailure extends Equatable implements Exception {
  const AppFailure();

  /// Turns any thrown error into the failure it stands for.
  factory AppFailure.from(Object error) => switch (error) {
        AppFailure() => error,
        UserCanceledException() => const CancelledFailure(),
        SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled
        ) =>
          const CancelledFailure(),
        PlatformException(code: 'sign_in_canceled' || 'CANCELED') =>
          const CancelledFailure(),
        NetworkException() ||
        TimeoutException() ||
        SocketException() =>
          const NetworkFailure(),
        ApiException(:final code) =>
          _fromStatus(int.tryParse(code ?? ''), error.message),
        DioException() => _fromDio(error),
        FirebaseAuthException(code: 'network-request-failed') =>
          const NetworkFailure(),
        FirebaseAuthException(:final code) => AuthFailure(AuthError.from(code)),
        FirebaseException(code: 'unavailable' || 'network-request-failed') =>
          const NetworkFailure(),
        SqliteException() || DriftWrappedException() => const StorageFailure(),
        _ => UnexpectedFailure(error),
      };

  static AppFailure _fromDio(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          const NetworkFailure(),
        _ => _fromStatus(e.response?.statusCode, e.message),
      };

  static AppFailure _fromStatus(int? status, String? detail) =>
      switch (status) {
        401 || 403 => const UnauthorizedFailure(),
        404 => const NotFoundFailure(),
        _ => ServerFailure(status: status, detail: detail),
      };

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

/// No connection, or the request timed out.
final class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

/// The server says the user isn't signed in or isn't allowed (401/403).
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure();
}

/// The item doesn't exist, or belongs to someone else (404).
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

/// The server answered with an error. [detail] is the server's text, for logs only.
final class ServerFailure extends AppFailure {
  const ServerFailure({this.status, this.detail});

  final int? status;
  final String? detail;

  /// The server refused the request itself (4xx), so retrying won't help.
  bool get isRejected => status != null && status! >= 400 && status! < 500;

  @override
  List<Object?> get props => [status, detail];
}

/// Firebase sign-in or account errors.
final class AuthFailure extends AppFailure {
  const AuthFailure(this.error);

  final AuthError error;

  @override
  List<Object?> get props => [error];
}

/// The user closed a sign-in sheet or dialog; nothing to report.
final class CancelledFailure extends AppFailure {
  const CancelledFailure();
}

/// The local database couldn't be read or written.
final class StorageFailure extends AppFailure {
  const StorageFailure();
}

/// A bug: an error nobody planned for.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}

/// Base for failures a single feature defines, such as a dose that isn't due yet.
abstract base class FeatureFailure extends AppFailure {
  const FeatureFailure();
}

/// The Firebase sign-in errors the UI tells apart.
enum AuthError {
  userNotFound,
  wrongPassword,
  emailInUse,
  credentialInUse,
  userMismatch,
  weakPassword,
  invalidEmail,
  userDisabled,
  tooManyRequests,
  requiresRecentLogin,
  other;

  /// Maps a Firebase error code.
  static AuthError from(String code) => switch (code) {
        'user-not-found' => userNotFound,
        'wrong-password' || 'invalid-credential' => wrongPassword,
        'email-already-in-use' => emailInUse,
        'credential-already-in-use' ||
        'account-exists-with-different-credential' =>
          credentialInUse,
        'user-mismatch' => userMismatch,
        'weak-password' => weakPassword,
        'invalid-email' => invalidEmail,
        'user-disabled' => userDisabled,
        'too-many-requests' => tooManyRequests,
        'requires-recent-login' => requiresRecentLogin,
        _ => other,
      };
}

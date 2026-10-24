import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/failures/app_failure.dart';

/// Turns a failure into words for the user.
extension FailureMessage on AppFailure {
  /// What to tell the user, or null when there's nothing to say (they cancelled).
  /// Feature failures get the generic text here; their screens word them first.
  String? message(AppLocalizations l10n) => switch (this) {
        CancelledFailure() => null,
        NetworkFailure() => l10n.failureOffline,
        UnauthorizedFailure() => l10n.failureUnauthorized,
        NotFoundFailure() => l10n.failureNotFound,
        ServerFailure(isRateLimited: true) => l10n.authErrorTooManyRequests,
        ServerFailure(isRejected: true) => l10n.failureRejected,
        ServerFailure() => l10n.failureServer,
        StorageFailure() => l10n.failureStorage,
        AuthFailure(:final error) => error.message(l10n),
        UnexpectedFailure() || FeatureFailure() => l10n.failureUnexpected,
      };
}

extension on AuthError {
  String message(AppLocalizations l10n) => switch (this) {
        AuthError.userNotFound => l10n.authErrorUserNotFound,
        AuthError.wrongPassword => l10n.authErrorWrongPassword,
        AuthError.emailInUse => l10n.authErrorEmailInUse,
        AuthError.credentialInUse => l10n.authErrorCredentialInUse,
        AuthError.userMismatch => l10n.authErrorUserMismatch,
        AuthError.weakPassword => l10n.authErrorWeakPassword,
        AuthError.invalidEmail => l10n.authErrorInvalidEmail,
        AuthError.userDisabled => l10n.authErrorUserDisabled,
        AuthError.tooManyRequests => l10n.authErrorTooManyRequests,
        AuthError.requiresRecentLogin => l10n.authErrorRequiresRecentLogin,
        AuthError.other => l10n.failureUnexpected,
      };
}

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Form field checks for email and password.
class Validators {
  /// New passwords need at least this many characters.
  static const minPasswordLength = 8;

  /// Whether [email] looks like an email address.
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);

  /// Whether [password] is long enough for a new account.
  static bool isValidNewPassword(String password) =>
      password.length >= minPasswordLength;

  /// The error for a badly formed email, or null while empty or valid.
  static String? email(String? value, AppLocalizations l10n) =>
      value == null || value.isEmpty || isValidEmail(value.trim())
          ? null
          : l10n.authErrorInvalidEmail;

  /// The error for a new password that is too short, or null while empty or valid.
  static String? newPassword(String? value, AppLocalizations l10n) =>
      value == null || value.isEmpty || isValidNewPassword(value)
          ? null
          : l10n.passwordHint;
}

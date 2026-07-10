class Validators {
  /// Validates an email address format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Returns an error string if the email is invalid, otherwise null
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!isValidEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Checks if a password meets minimum requirements
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Returns an error string if the password is invalid, otherwise null
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!isValidPassword(value)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

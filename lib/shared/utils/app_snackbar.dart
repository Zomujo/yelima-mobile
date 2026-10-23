import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/globals.dart';

/// Floating success, error and info messages.
abstract final class AppSnackBar {
  /// Shows a green success message; a null [context] uses the app's messenger.
  static void showSuccess(BuildContext? context, {required String message}) =>
      _show(context, message, Icons.check_circle_outline, AppColors.emerald500,
          const Duration(seconds: 3));

  /// Shows a red error message.
  static void showError(BuildContext? context, {required String message}) =>
      _show(context, message, Icons.error_outline, AppColors.red500,
          const Duration(seconds: 4));

  /// Shows a blue note.
  static void showInfo(BuildContext? context, {required String message}) =>
      _show(context, message, Icons.info_outline, const Color(0xFF1E3A8A),
          const Duration(seconds: 4));

  static void _show(BuildContext? context, String message, IconData icon,
      Color color, Duration duration) {
    if (context != null && !context.mounted) return;
    final messenger = context != null
        ? ScaffoldMessenger.of(context)
        : scaffoldMessengerKey.currentState;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
        duration: duration,
      ));
  }
}

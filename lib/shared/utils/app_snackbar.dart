import 'package:flutter/material.dart';
import 'package:yelima/core/utils/globals.dart';

class AppSnackBar {
  static void showSuccess(BuildContext? context, {required String message}) {
    if (context != null && !context.mounted) return;
    
    final messenger = context != null 
        ? ScaffoldMessenger.of(context) 
        : scaffoldMessengerKey.currentState;
        
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981), // Emerald 500
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          elevation: 4,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void showError(BuildContext? context, {required String message}) {
    if (context != null && !context.mounted) return;
    
    final messenger = context != null 
        ? ScaffoldMessenger.of(context) 
        : scaffoldMessengerKey.currentState;
        
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444), // Red 500
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          elevation: 4,
          duration: const Duration(seconds: 4),
        ),
      );
  }
}

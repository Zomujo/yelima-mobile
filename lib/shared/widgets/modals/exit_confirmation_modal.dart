import 'dart:io';
import 'package:flutter/material.dart';
import '../layout/app_text.dart';
import '../layout/app_button.dart';
import 'app_modal.dart';

class ExitConfirmationModal extends StatelessWidget {
  const ExitConfirmationModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) => OverlayModal(
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 300),
        onDismiss: () => Navigator.of(context).pop(),
        child: const ExitConfirmationModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      title: 'Exit App',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppText.titleMedium(
            'Are you sure you want to exit the app?',
            color: Colors.black54,
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                  foregroundColor: const Color(0xFF475569), // Slate 600
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Exit',
                  backgroundColor: const Color(0xFFEF4444), // Red 500
                  onPressed: () {
                    Navigator.of(context).pop();
                    exit(0);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

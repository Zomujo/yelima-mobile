import 'dart:io';
import 'package:flutter/material.dart';
import '../layout/app_text.dart';
import '../layout/app_button.dart';
import 'app_modal.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

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
      title: context.l10n.exitAppTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleMedium(
            context.l10n.exitAppConfirmation,
            color: Colors.black54,
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: context.l10n.cancel,
                  backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                  foregroundColor: const Color(0xFF475569), // Slate 600
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: context.l10n.exit,
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

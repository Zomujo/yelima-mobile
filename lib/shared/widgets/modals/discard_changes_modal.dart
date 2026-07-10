import 'package:flutter/material.dart';
import 'app_modal.dart';
import '../layout/app_button.dart';
import '../layout/app_text.dart';

class DiscardChangesModal {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      useSafeArea: false,
      builder: (context) => OverlayModal(
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 300),
        onDismiss: () => Navigator.of(context).pop(false),
        child: ModalContainer(
          title: 'Discard Changes?',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppText.titleMedium(
                'You have unsaved changes. If you leave now, your changes will be lost.',
                color: Colors.black54,
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Keep Editing',
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF475569),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: 'Discard',
                      backgroundColor: const Color(0xFFEF4444),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

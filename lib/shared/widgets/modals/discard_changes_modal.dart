import 'package:flutter/material.dart';
import 'app_modal.dart';
import '../layout/app_button.dart';
import '../layout/app_text.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

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
          title: context.l10n.discardChangesTitle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText.titleMedium(
                context.l10n.discardChangesConfirmation,
                color: Colors.black54,
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: context.l10n.keepEditing,
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF475569),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: context.l10n.discard,
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

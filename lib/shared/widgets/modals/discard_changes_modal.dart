import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'app_modal.dart';
import '../layout/app_button.dart';
import '../layout/app_text.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Asks whether to drop unsaved changes; returns true to discard.
class DiscardChangesModal {
  static Future<bool?> show(BuildContext context) {
    return showAppDialog<bool>(
        context,
        // Built in the dialog's own context, so the buttons close the dialog.
        Builder(
          builder: (context) => ModalContainer(
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
                        backgroundColor: AppColors.slate100,
                        foregroundColor: AppColors.slate600,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: context.l10n.discard,
                        backgroundColor: AppColors.red500,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        dismissValue: false,
        barrierColor: Colors.black.withValues(alpha: 0.3));
  }
}

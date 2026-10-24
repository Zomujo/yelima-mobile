import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_button.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/modals/app_modal.dart';

/// Explains why reminders need "Alarms & reminders"; returns true to go and allow it.
class ExactRemindersModal {
  static Future<bool?> show(BuildContext context) => showAppDialog<bool>(
        context,
        // Built in the dialog's own context, so the buttons close the dialog.
        Builder(
          builder: (context) => ModalContainer(
            title: context.l10n.exactRemindersTitle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText.titleMedium(context.l10n.exactRemindersBody,
                    color: Colors.black54),
                const SizedBox(height: 36),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: context.l10n.notNow,
                        backgroundColor: AppColors.slate100,
                        foregroundColor: AppColors.slate600,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: context.l10n.allow,
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
      );
}

import 'package:yelima/core/theme/app_colors.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../layout/app_text.dart';
import '../layout/app_button.dart';
import 'app_modal.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Asks before closing the app with Back.
class ExitConfirmationModal extends StatelessWidget {
  const ExitConfirmationModal({super.key});

  static void show(BuildContext context) {
    showAppDialog(context, const ExitConfirmationModal());
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
                  backgroundColor: AppColors.slate100,
                  foregroundColor: AppColors.slate600,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: context.l10n.exit,
                  backgroundColor: AppColors.red500,
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

import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../../../../shared/widgets/modals/app_modal.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Asks before deleting a medication; returns true to delete.
class DeleteMedicationModal extends StatelessWidget {
  final String name;

  const DeleteMedicationModal({super.key, required this.name});

  static Future<bool?> show(BuildContext context, String name) {
    return showAppDialog<bool>(context, DeleteMedicationModal(name: name),
        dismissValue: false);
  }

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      title: context.l10n.deleteMedicationTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleMedium(
            context.l10n.deleteMedicationConfirmation(name),
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
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: context.l10n.delete,
                  backgroundColor: AppColors.red500,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

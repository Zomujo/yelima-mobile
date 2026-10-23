import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../../../../shared/widgets/modals/app_modal.dart';
import '../../../domain/entities/medication_entity.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class DeleteMedicationModal extends StatelessWidget {
  final MedicationEntity medication;

  const DeleteMedicationModal({
    super.key,
    required this.medication,
  });

  static Future<bool?> show(BuildContext context, MedicationEntity medication) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) => OverlayModal(
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 300),
        onDismiss: () => Navigator.of(context).pop(false),
        child: DeleteMedicationModal(medication: medication),
      ),
    );
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
            context.l10n.deleteMedicationConfirmation(medication.name),
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

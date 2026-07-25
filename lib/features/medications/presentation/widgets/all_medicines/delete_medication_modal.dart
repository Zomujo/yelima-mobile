import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../../../../shared/widgets/modals/app_modal.dart';
import '../../../domain/entities/medication_entity.dart';

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
      title: 'Delete Medication',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleMedium(
            'Are you sure you want to delete ${medication.name}?',
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
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Delete',
                  backgroundColor: const Color(0xFFEF4444), // Red 500
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

import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../../../../shared/utils/failure_message.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../controllers/medicine_details_form_controller.dart';
import '../all_medicines/delete_medication_modal.dart';

/// Deletes the medicine after asking, then leaves its screen.
class DeleteMedicineButton extends StatelessWidget {
  const DeleteMedicineButton({super.key, required this.controller});

  final MedicineDetailsFormController controller;

  Future<void> _delete(BuildContext context) async {
    final l10n = context.l10n;
    final name = controller.name;
    if (await DeleteMedicationModal.show(context, name) != true) return;
    final result = await controller.delete();
    if (!context.mounted) return;
    result.fold(
      (f) => AppSnackBar.showError(context, message: f.message(l10n) ?? ''),
      (_) {
        AppSnackBar.showSuccess(context, message: l10n.medicationDeleted(name));
        Navigator.of(context).maybePop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: context.l10n.deleteMedicationTitle,
      variant: AppButtonVariant.outlined,
      foregroundColor: AppColors.red500,
      outlineColor: AppColors.red500,
      width: double.infinity,
      prefixIcon: const Icon(Icons.delete_outline, color: AppColors.red500),
      onPressed: () => _delete(context),
    );
  }
}

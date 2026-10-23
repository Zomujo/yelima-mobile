import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../controllers/medicine_details_form_controller.dart';

class MedicineDetailsActionButton extends StatelessWidget {
  final MedicineDetailsFormController controller;
  final bool isSaving;

  const MedicineDetailsActionButton({
    super.key,
    required this.controller,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: InkWell(
          onTap: isSaving
              ? null
              : () async {
                  if (controller.state.isEditing) {
                    final error = await controller.save();
                    if (context.mounted) {
                      if (error == null) {
                        AppSnackBar.showSuccess(context,
                            message: context.l10n.medicationUpdatedSuccess);
                      } else {
                        AppSnackBar.showError(context, message: error);
                      }
                    }
                  } else {
                    controller.toggleEditing(true);
                  }
                },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: controller.state.isEditing
                  ? AppColors.orange300
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : AppText.bodyMedium(
                    controller.state.isEditing
                        ? context.l10n.save
                        : context.l10n.edit,
                    fontWeight: FontWeight.bold,
                    color: controller.state.isEditing
                        ? Colors.white
                        : AppColors.orange300,
                  ),
          ),
        ),
      ),
    );
  }
}

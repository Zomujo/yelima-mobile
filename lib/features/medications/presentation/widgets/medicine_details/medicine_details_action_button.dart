import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../controllers/medicine_details_form_controller.dart';
import '../../medication_failure_message.dart';

/// Edit, then Save, in the details app bar.
class MedicineDetailsActionButton extends ConsumerWidget {
  const MedicineDetailsActionButton({super.key, required this.medicationId});

  final String medicationId;

  MedicineDetailsFormControllerProvider get _form =>
      medicineDetailsFormControllerProvider(medicationId);

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(_form.notifier);
    if (!ref.read(_form).isEditing) return controller.setEditing(true);
    final l10n = context.l10n;
    final failure = await controller.save();
    if (!context.mounted) return;
    if (failure == null) {
      AppSnackBar.showSuccess(context, message: l10n.medicationUpdatedSuccess);
    } else {
      AppSnackBar.showError(context,
          message: failure.medicationMessage(l10n) ?? '');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_form);
    final isSaving = state.form.isSaving;
    final isEditing = state.isEditing;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: InkWell(
          onTap: isSaving ? null : () => _onTap(context, ref),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isEditing ? AppColors.orange300 : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : AppText.bodyMedium(
                    isEditing ? context.l10n.save : context.l10n.edit,
                    fontWeight: FontWeight.bold,
                    color: isEditing ? Colors.white : AppColors.orange300,
                  ),
          ),
        ),
      ),
    );
  }
}

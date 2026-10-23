import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/medicine_details_form_controller.dart';
import '../medication_form/unit_picker.dart';

/// Dosage, unit and notes: read-only, or editable in edit mode.
class MedicineDetailsFormFields extends StatelessWidget {
  const MedicineDetailsFormFields({super.key, required this.controller});

  final MedicineDetailsFormController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = controller.detail!;
    Widget heading(String text) => AppText.titleMedium(text,
        fontWeight: FontWeight.bold, color: AppColors.slate800);

    if (!controller.isEditing) {
      final notes = data.notes ?? '';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading(l10n.generalDosageAmount),
          const SizedBox(height: 12),
          AppText.bodyMedium(data.dosage, color: AppColors.slate600),
          const SizedBox(height: 32),
          heading(l10n.notesLabel),
          const SizedBox(height: 12),
          AppText.bodyMedium(notes.isEmpty ? l10n.noNotesProvided : notes,
              color: AppColors.slate600, height: 1.5),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          controller: controller.dosageController,
          label: l10n.dosageStrength,
          hintText: l10n.dosageStrengthHint,
          isRequired: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.requiredField : null,
        ),
        const SizedBox(height: 24),
        heading(l10n.medicationFormUnit),
        const SizedBox(height: 12),
        UnitPicker(value: controller.unit, onSelected: controller.setUnit),
        const SizedBox(height: 32),
        AppFormField(
          controller: controller.notesController,
          label: l10n.notesLabel,
          hintText: l10n.notesAfterMealsHint,
          maxLines: 4,
        ),
      ],
    );
  }
}

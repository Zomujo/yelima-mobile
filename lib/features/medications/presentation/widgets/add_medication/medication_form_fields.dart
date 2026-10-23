import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/add_medication_form_controller.dart';
import '../medication_form/unit_picker.dart';

/// Dosage (with suggestions for a picked medication), unit and notes.
class MedicationFormFields extends StatelessWidget {
  const MedicationFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddMedicationFormController>();
    final l10n = context.l10n;
    final suggestions = controller.picked?.possibleDosages ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          controller: controller.dosageController,
          label: l10n.dosageStrengthLabel,
          hintText: l10n.enterDosageStrength,
          isRequired: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.requiredField : null,
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final dosage in suggestions)
                _DosageChip(
                  dosage: dosage,
                  selected: controller.dosageController.text == dosage,
                  onSelected: (on) =>
                      controller.selectDosage(on ? dosage : null),
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        AppText.titleMedium(l10n.medicationFormUnit,
            fontWeight: FontWeight.bold, color: AppColors.slate800),
        const SizedBox(height: 12),
        UnitPicker(value: controller.unit, onSelected: controller.setUnit),
        const SizedBox(height: 24),
        AppFormField(
          controller: controller.notesController,
          label: l10n.notesInstructions,
          hintText: l10n.notesInstructionsHint,
          maxLines: 4,
        ),
      ],
    );
  }
}

class _DosageChip extends StatelessWidget {
  const _DosageChip(
      {required this.dosage, required this.selected, required this.onSelected});

  final String dosage;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: AppText.bodyMedium(dosage,
            color: selected ? Colors.white : AppColors.slate600),
        selected: selected,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
            color: selected ? AppColors.primary : AppColors.slate200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        checkmarkColor: Colors.white,
        onSelected: onSelected,
      );
}

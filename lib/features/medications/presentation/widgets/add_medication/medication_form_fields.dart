import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/add_medication_form_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class MedicationFormFields extends StatelessWidget {
  const MedicationFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddMedicationFormController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              controller: controller.dosageController,
              label: context.l10n.dosageStrengthLabel,
              hintText: context.l10n.enterDosageStrength,
              isRequired: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => v == null || v.trim().isEmpty
                  ? context.l10n.requiredField
                  : null,
            ),
            if (controller.state.selectedPreloadedMedication != null &&
                controller.state.selectedPreloadedMedication!.possibleDosages
                    .isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                children: controller
                    .state.selectedPreloadedMedication!.possibleDosages
                    .map((dosage) {
                  final isSelected = controller.dosageController.text == dosage;
                  return ChoiceChip(
                    label: AppText.bodyMedium(dosage,
                        color: isSelected ? Colors.white : AppColors.slate600),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.slate200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    checkmarkColor: Colors.white,
                    onSelected: (bool selected) {
                      if (selected) {
                        controller.selectDosage(dosage);
                      } else {
                        controller.clearDosage();
                      }
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            AppText.titleMedium(context.l10n.medicationFormUnit,
                fontWeight: FontWeight.bold, color: AppColors.slate800),
            const SizedBox(height: 12),
            PopupMenuButton<String>(
              initialValue: controller.state.selectedUnit,
              onSelected: controller.updateUnit,
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.slate200),
              ),
              color: Colors.white,
              elevation: 4.0,
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 48,
                maxWidth: MediaQuery.of(context).size.width - 48,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.bodyMedium(controller.state.selectedUnit,
                        color: AppColors.slate800),
                    const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.slate400),
                  ],
                ),
              ),
              itemBuilder: (BuildContext context) {
                final units = [
                  'tablet',
                  'capsule',
                  'ml',
                  'drops',
                  'mg',
                  'application'
                ];
                return [
                  for (var i = 0; i < units.length; i++) ...[
                    PopupMenuItem<String>(
                      value: units[i],
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AppText.bodyMedium(units[i],
                          color: AppColors.slate800),
                    ),
                    if (i < units.length - 1)
                      const PopupMenuItem<String>(
                        enabled: false,
                        height: 1,
                        padding: EdgeInsets.zero,
                        child: Divider(height: 1, color: AppColors.slate200),
                      ),
                  ]
                ];
              },
            ),
            const SizedBox(height: 24),
            AppFormField(
              controller: controller.notesController,
              label: context.l10n.notesInstructions,
              hintText: context.l10n.notesInstructionsHint,
              maxLines: 4,
            ),
          ],
        );
      },
    );
  }
}

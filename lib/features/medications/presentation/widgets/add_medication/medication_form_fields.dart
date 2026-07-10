import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/add_medication_form_controller.dart';

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
              label: 'Dosage Strength (e.g. 500mg, 10ml)',
              hintText: 'Enter dosage strength',
              isRequired: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            if (controller.state.selectedPreloadedMedication != null &&
                controller.state.selectedPreloadedMedication!.possibleDosages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                children: controller.state.selectedPreloadedMedication!.possibleDosages.map((dosage) {
                  final isSelected = controller.dosageController.text == dosage;
                  return ChoiceChip(
                    label: AppText.bodyMedium(dosage, color: isSelected ? Colors.white : const Color(0xFF475569)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            const AppText.titleMedium('Medication Form / Unit', fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            const SizedBox(height: 12),
            PopupMenuButton<String>(
              initialValue: controller.state.selectedUnit,
              onSelected: controller.updateUnit,
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              color: Colors.white,
              elevation: 4.0,
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 48,
                maxWidth: MediaQuery.of(context).size.width - 48,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.bodyMedium(controller.state.selectedUnit, color: const Color(0xFF1E293B)),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
              itemBuilder: (BuildContext context) {
                final units = ['tablet', 'capsule', 'ml', 'drops', 'mg', 'application'];
                return [
                  for (var i = 0; i < units.length; i++) ...[
                    PopupMenuItem<String>(
                      value: units[i],
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AppText.bodyMedium(units[i], color: const Color(0xFF1E293B)),
                    ),
                    if (i < units.length - 1)
                      const PopupMenuItem<String>(
                        enabled: false,
                        height: 1,
                        padding: EdgeInsets.zero,
                        child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                      ),
                  ]
                ];
              },
            ),
            const SizedBox(height: 24),
            AppFormField(
              controller: controller.notesController,
              label: 'Notes (Instructions)',
              hintText: 'e.g. To be taken before meals...',
              maxLines: 4,
            ),
          ],
        );
      },
    );
  }
}

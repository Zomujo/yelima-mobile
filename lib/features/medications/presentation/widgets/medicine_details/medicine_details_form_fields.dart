import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../controllers/medicine_details_form_controller.dart';
import '../../../data/models/medication_detail_model.dart';
import 'package:provider/provider.dart';

class MedicineDetailsFormFields extends StatelessWidget {
  final MedicationDetailModel data;

  const MedicineDetailsFormFields({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineDetailsFormController>(
      builder: (context, controller, child) {
        if (!controller.state.isEditing) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText.titleMedium('General Dosage Amount',
                  fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              const SizedBox(height: 12),
              AppText.bodyMedium(data.dosage, color: const Color(0xFF475569)),
              const SizedBox(height: 32),
              const AppText.titleMedium('Notes',
                  fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              const SizedBox(height: 12),
              AppText.bodyMedium(
                  (data.notes?.isEmpty ?? true)
                      ? 'No notes provided.'
                      : data.notes!,
                  color: const Color(0xFF475569),
                  height: 1.5),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              controller: controller.dosageController,
              label: 'Dosage Strength',
              hintText: 'e.g. 500mg, 10ml',
              isRequired: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const AppText.titleMedium('Medication Form / Unit',
                fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            const SizedBox(height: 12),
            PopupMenuButton<String>(
              initialValue: controller.state.selectedUnit,
              onSelected: controller.setUnit,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.bodyMedium(controller.state.selectedUnit,
                        color: const Color(0xFF1E293B)),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF94A3B8)),
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
                          color: const Color(0xFF1E293B)),
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
            const SizedBox(height: 32),
            AppFormField(
              controller: controller.notesController,
              label: 'Notes',
              hintText: 'e.g. To be taken after meals...',
              maxLines: 4,
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/medicine_details_form_controller.dart';
import 'medicine_details_header_card.dart';
import 'medicine_details_form_fields.dart';
import 'medicine_details_schedule_section.dart';

class MedicineDetailsBody extends StatelessWidget {
  final MedicineDetailsFormController controller;

  const MedicineDetailsBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingData) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFDBA74)));
    }

    final data = controller.medicationData;

    if (data == null) {
      if (controller.dataError != null) {
        return Center(
            child: AppText.bodyMedium('Error: ${controller.dataError}'));
      }
      return const Center(child: AppText.bodyMedium('Medication not found'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: 24.0 + MediaQuery.of(context).padding.bottom + 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicineDetailsHeaderCard(
              data: data, medicationId: controller.medicationId),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 24),
          MedicineDetailsFormFields(data: data),
          const SizedBox(height: 32),
          MedicineDetailsScheduleSection(data: data),
        ],
      ),
    );
  }
}

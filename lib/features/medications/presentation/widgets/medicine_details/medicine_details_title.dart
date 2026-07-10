import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/medicine_details_form_controller.dart';

class MedicineDetailsTitle extends StatelessWidget {
  final MedicineDetailsFormController controller;

  const MedicineDetailsTitle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText.headlineSmall(controller.titleName,
            fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        const SizedBox(width: 8),
        AppText.bodyMedium(controller.titleDosage,
            color: const Color(0xFF94A3B8)),
      ],
    );
  }
}

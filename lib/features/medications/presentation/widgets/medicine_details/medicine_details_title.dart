import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/medicine_details_form_controller.dart';

/// The medication's name and dosage in the app bar.
class MedicineDetailsTitle extends StatelessWidget {
  const MedicineDetailsTitle({super.key, required this.controller});

  final MedicineDetailsFormController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText.headlineSmall(controller.name,
            fontWeight: FontWeight.bold, color: AppColors.slate800),
        const SizedBox(width: 8),
        AppText.bodyMedium(controller.detail?.dosage ?? '',
            color: AppColors.slate400),
      ],
    );
  }
}

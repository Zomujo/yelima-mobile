import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/medicine_details_form_controller.dart';

/// The medication's name and dosage in the app bar.
class MedicineDetailsTitle extends ConsumerWidget {
  const MedicineDetailsTitle({super.key, required this.medicationId});

  final String medicationId;

  MedicineDetailsFormControllerProvider get _form =>
      medicineDetailsFormControllerProvider(medicationId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_form);
    return Row(
      children: [
        AppText.headlineSmall(state.name,
            fontWeight: FontWeight.bold, color: AppColors.slate800),
        const SizedBox(width: 8),
        AppText.bodyMedium(state.detail?.dosage ?? '',
            color: AppColors.slate400),
      ],
    );
  }
}

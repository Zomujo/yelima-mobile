import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/forms/unsaved_changes_guard.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../controllers/medicine_details_form_controller.dart';
import '../widgets/medicine_details/medicine_details_action_button.dart';
import '../widgets/medicine_details/medicine_details_body.dart';
import '../widgets/medicine_details/medicine_details_title.dart';

/// One medication: its dose history, details and an edit mode.
class MedicineDetailsScreen extends ConsumerWidget {
  const MedicineDetailsScreen({super.key, required this.medicationId});

  final String medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = medicineDetailsFormControllerProvider(medicationId);
    ref.watch(provider); // keeps the form alive while the screen is open
    return UnsavedChangesGuard(
      hasUnsavedChanges: () {
        final state = ref.read(provider);
        return state.isEditing && state.form.hasChanges;
      },
      child: Scaffold(
        backgroundColor: AppColors.globalBackground,
        appBar: AppHeader(
          titleWidget: MedicineDetailsTitle(medicationId: medicationId),
          actions: [MedicineDetailsActionButton(medicationId: medicationId)],
        ),
        body: MedicineDetailsBody(medicationId: medicationId),
      ),
    );
  }
}

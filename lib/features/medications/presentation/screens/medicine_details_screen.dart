import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/forms/unsaved_changes_guard.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../domain/repositories/medication_repository.dart';
import '../controllers/medicine_details_form_controller.dart';
import '../widgets/medicine_details/medicine_details_action_button.dart';
import '../widgets/medicine_details/medicine_details_body.dart';
import '../widgets/medicine_details/medicine_details_title.dart';

/// One medication: its dose history, details and an edit mode.
class MedicineDetailsScreen extends StatelessWidget {
  const MedicineDetailsScreen({super.key, required this.medicationId});

  final String medicationId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MedicineDetailsFormController(
        repository: context.read<MedicationRepository>(),
        medicationId: medicationId,
      )..init(),
      child: Consumer<MedicineDetailsFormController>(
        builder: (context, controller, _) => UnsavedChangesGuard(
          hasUnsavedChanges: () =>
              controller.isEditing && controller.hasChanges,
          child: Scaffold(
            backgroundColor: AppColors.globalBackground,
            appBar: AppHeader(
              titleWidget: MedicineDetailsTitle(controller: controller),
              actions: [MedicineDetailsActionButton(controller: controller)],
            ),
            body: MedicineDetailsBody(controller: controller),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/widgets/forms/unsaved_changes_guard.dart';
import '../../domain/usecases/update_medication_usecase.dart';
import '../controllers/all_medicines_controller.dart';
import '../controllers/medicine_details_form_controller.dart';
import '../widgets/medicine_details/medicine_details_title.dart';
import '../widgets/medicine_details/medicine_details_action_button.dart';
import '../widgets/medicine_details/medicine_details_body.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final String medicationId;

  const MedicineDetailsScreen({
    super.key,
    required this.medicationId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MedicineDetailsFormController(
        allMedicinesController: context.read<AllMedicinesController>(),
        updateMedicationUseCase: context.read<UpdateMedicationUseCase>(),
        medicationId: medicationId,
      )..init(),
      child: Consumer2<MedicineDetailsFormController, AllMedicinesController>(
        builder: (context, formController, listController, child) {
          final isSaving = listController.formSubmitState.isLoading;

          return UnsavedChangesGuard(
            hasUnsavedChanges: () => formController.state.hasUnsavedChanges,
            child: Scaffold(
              backgroundColor: AppColors.globalBackground,
              appBar: AppHeader(
                titleWidget: MedicineDetailsTitle(controller: formController),
                actions: [
                  MedicineDetailsActionButton(
                    controller: formController,
                    isSaving: isSaving,
                  ),
                ],
              ),
              body: MedicineDetailsBody(controller: formController),
            ),
          );
        },
      ),
    );
  }
}

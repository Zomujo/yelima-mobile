import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/widgets/forms/unsaved_changes_guard.dart';
import '../../../../shared/utils/app_snackbar.dart';
import '../../domain/usecases/create_medication_usecase.dart';
import '../controllers/all_medicines_controller.dart';
import '../controllers/add_medication_form_controller.dart';
import '../widgets/add_medication/medication_search_field.dart';
import '../widgets/add_medication/medication_dosing_schedule.dart';
import '../widgets/add_medication/medication_form_fields.dart';

class AddMedicationScreen extends StatelessWidget {
  const AddMedicationScreen({super.key});

  void _onSave(
      BuildContext context, AddMedicationFormController formController) async {
    final error = await formController.save();

    if (error == null && context.mounted) {
      // Refresh the list after creation
      context.read<AllMedicinesController>().fetchAllMedicines(forceRefresh: true);
      AppSnackBar.showSuccess(context, message: 'Medication added successfully!');
      context.pop();
    } else if (error != 'validation_failed' && context.mounted) {
      AppSnackBar.showError(context, message: error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddMedicationFormController(
        createMedicationUseCase: context.read<CreateMedicationUseCase>(),
      ),
      child: Consumer2<AddMedicationFormController, AllMedicinesController>(
        builder: (context, formController, allMedicinesController, child) {
          final isSaving = allMedicinesController.formSubmitState.isLoading;

          return UnsavedChangesGuard(
            hasUnsavedChanges: formController.hasUnsavedChanges,
            child: Scaffold(
              backgroundColor: AppColors.globalBackground,
              appBar: const AppHeader(title: 'Add Medication'),
              body: Form(
                key: formController.formKey,
                child: const SingleChildScrollView(
                  padding: EdgeInsets.only(
                      left: 24.0, right: 24.0, top: 24.0, bottom: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.titleMedium('Medication Details',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                      SizedBox(height: 16),
                      MedicationSearchField(),
                      SizedBox(height: 24),
                      MedicationFormFields(),
                      SizedBox(height: 40),
                      Divider(color: Color(0xFFE2E8F0)),
                      SizedBox(height: 32),
                      MedicationDosingSchedule(),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AppButton(
                    text: 'Save Medication',
                    isLoading: isSaving,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    borderRadius: 30,
                    onPressed: isSaving
                        ? null
                        : () => _onSave(context, formController),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

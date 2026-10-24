import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/app_snackbar.dart';
import '../../../../shared/widgets/forms/unsaved_changes_guard.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../domain/repositories/medication_repository.dart';
import '../controllers/add_medication_form_controller.dart';
import '../medication_failure_message.dart';
import '../widgets/add_medication/medication_form_fields.dart';
import '../widgets/exact_reminders_modal.dart';
import '../widgets/add_medication/medication_search_field.dart';
import '../widgets/medication_form/dose_schedule_editor.dart';

/// Adds a medication: name, dosage, unit, notes and dose times.
class AddMedicationScreen extends StatelessWidget {
  const AddMedicationScreen({super.key});

  Future<void> _save(
      BuildContext context, AddMedicationFormController form) async {
    final l10n = context.l10n;
    final failure = await form.save();
    if (!context.mounted || failure is CancelledFailure) return;
    if (failure == null) {
      AppSnackBar.showSuccess(context, message: l10n.medicationAddedSuccess);
      await _askForExactReminders(context);
      if (context.mounted) context.pop();
    } else {
      AppSnackBar.showError(context,
          message: failure.medicationMessage(l10n) ?? '');
    }
  }

  /// On newer Android, reminders are only on time once "Alarms & reminders" is allowed.
  Future<void> _askForExactReminders(BuildContext context) async {
    final medications = context.read<MedicationRepository>();
    if (await medications.remindersAreExact() || !context.mounted) return;
    if (await ExactRemindersModal.show(context) == true) {
      await medications.allowExactReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ChangeNotifierProvider(
      create: (context) => AddMedicationFormController(
          repository: context.read<MedicationRepository>()),
      child: Consumer<AddMedicationFormController>(
        builder: (context, form, _) => UnsavedChangesGuard(
          hasUnsavedChanges: () => form.hasChanges,
          child: Scaffold(
            backgroundColor: AppColors.globalBackground,
            appBar: AppHeader(title: l10n.addMedication),
            body: Form(
              key: form.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleMedium(l10n.medicationDetails,
                        fontWeight: FontWeight.bold, color: AppColors.slate800),
                    const SizedBox(height: 16),
                    const MedicationSearchField(),
                    const SizedBox(height: 24),
                    const MedicationFormFields(),
                    const SizedBox(height: 40),
                    const Divider(color: AppColors.slate200),
                    const SizedBox(height: 32),
                    AppText.titleLarge(l10n.dosingSchedule,
                        fontWeight: FontWeight.bold, color: AppColors.slate800),
                    const SizedBox(height: 8),
                    AppText.bodyMedium(l10n.selectWhenAndHowMuch,
                        color: AppColors.slate500),
                    const SizedBox(height: 24),
                    DoseScheduleEditor(controller: form),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(
                  text: l10n.saveMedication,
                  isLoading: form.isSaving,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  borderRadius: 30,
                  onPressed: form.isSaving ? null : () => _save(context, form),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

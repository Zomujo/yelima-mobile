import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/medicine_details_form_controller.dart';
import '../../../../../shared/widgets/motion/fade_switch.dart';
import '../medication_form/unit_picker.dart';

/// Dosage, unit and notes: read-only, or editable in edit mode.
class MedicineDetailsFormFields extends ConsumerWidget {
  const MedicineDetailsFormFields({super.key, required this.medicationId});

  final String medicationId;

  MedicineDetailsFormControllerProvider get _form =>
      medicineDetailsFormControllerProvider(medicationId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_form);
    // Plain children, so the one fading out keeps what it showed.
    return FadeSwitch(
      child: state.isEditing
          ? _EditableFields(
              controller: ref.read(_form.notifier), unit: state.form.unit)
          : _ReadOnlyFields(
              dosage: state.detail!.dosage, notes: state.detail!.notes ?? ''),
    );
  }
}

/// A bold section title.
class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => AppText.titleMedium(text,
      fontWeight: FontWeight.bold, color: AppColors.slate800);
}

/// Dosage and notes as text.
class _ReadOnlyFields extends StatelessWidget {
  const _ReadOnlyFields({required this.dosage, required this.notes});

  final String dosage;
  final String notes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(l10n.generalDosageAmount),
        const SizedBox(height: 12),
        AppText.bodyMedium(dosage, color: AppColors.slate600),
        const SizedBox(height: 32),
        _Heading(l10n.notesLabel),
        const SizedBox(height: 12),
        AppText.bodyMedium(notes.isEmpty ? l10n.noNotesProvided : notes,
            color: AppColors.slate600, height: 1.5),
      ],
    );
  }
}

/// Dosage, unit and notes as form fields.
class _EditableFields extends StatelessWidget {
  const _EditableFields({required this.controller, required this.unit});

  final MedicineDetailsFormController controller;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          controller: controller.dosageController,
          label: l10n.dosageStrength,
          hintText: l10n.dosageStrengthHint,
          isRequired: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.requiredField : null,
        ),
        const SizedBox(height: 24),
        _Heading(l10n.medicationFormUnit),
        const SizedBox(height: 12),
        UnitPicker(value: unit, onSelected: controller.setUnit),
        const SizedBox(height: 32),
        AppFormField(
          controller: controller.notesController,
          label: l10n.notesLabel,
          hintText: l10n.notesAfterMealsHint,
          maxLines: 4,
        ),
      ],
    );
  }
}

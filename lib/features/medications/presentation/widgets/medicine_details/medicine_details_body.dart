import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/utils/failure_message.dart';
import '../../controllers/medicine_details_form_controller.dart';
import 'delete_medicine_button.dart';
import 'medicine_details_header_card.dart';
import 'medicine_details_form_fields.dart';
import 'medicine_details_schedule_section.dart';

/// The details screen content: history card, fields, schedule and delete.
class MedicineDetailsBody extends ConsumerWidget {
  const MedicineDetailsBody({super.key, required this.medicationId});

  final String medicationId;

  MedicineDetailsFormControllerProvider get _form =>
      medicineDetailsFormControllerProvider(medicationId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_form);
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.orange300));
    }
    final data = state.detail;
    if (data == null) {
      return Center(
          child: AppText.bodyMedium(state.error?.message(context.l10n) ??
              context.l10n.medicationNotFound));
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
          MedicineDetailsHeaderCard(medicationId: medicationId),
          const SizedBox(height: 32),
          const Divider(color: AppColors.slate200, height: 1),
          const SizedBox(height: 24),
          MedicineDetailsFormFields(medicationId: medicationId),
          const SizedBox(height: 32),
          MedicineDetailsScheduleSection(medicationId: medicationId),
          if (!state.isEditing) ...[
            const SizedBox(height: 40),
            DeleteMedicineButton(medicationId: medicationId),
          ],
        ],
      ),
    );
  }
}

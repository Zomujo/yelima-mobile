import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/utils/failure_message.dart';
import '../../../../../shared/widgets/motion/entrance.dart';
import '../../controllers/medicine_details_form_controller.dart';
import '../../../../../shared/widgets/motion/fade_switch.dart';
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
          Entrance(
              child: MedicineDetailsHeaderCard(medicationId: medicationId)),
          const SizedBox(height: 32),
          const Entrance(
              index: 1, child: Divider(color: AppColors.slate200, height: 1)),
          const SizedBox(height: 24),
          Entrance(
              index: 1,
              child: MedicineDetailsFormFields(medicationId: medicationId)),
          const SizedBox(height: 32),
          Entrance(
              index: 2,
              child:
                  MedicineDetailsScheduleSection(medicationId: medicationId)),
          Entrance(
            index: 3,
            // Delete is hidden while editing.
            child: FadeSwitch(
              child: state.isEditing
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: DeleteMedicineButton(medicationId: medicationId),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

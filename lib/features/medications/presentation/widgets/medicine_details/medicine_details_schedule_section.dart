import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_section.dart';
import '../../controllers/medicine_details_form_controller.dart';
import '../../medication_section_label.dart';
import '../medication_form/dose_schedule_editor.dart';

/// The dose times: a summary, or the editor in edit mode.
class MedicineDetailsScheduleSection extends ConsumerWidget {
  const MedicineDetailsScheduleSection({super.key, required this.medicationId});

  final String medicationId;

  MedicineDetailsFormControllerProvider get _form =>
      medicineDetailsFormControllerProvider(medicationId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(_form);
    final slots = state.form.slots;
    final scheduled = MedicationSection.values.where((s) => slots[s]!.enabled);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.titleMedium(l10n.dosingSchedule,
            fontWeight: FontWeight.bold, color: AppColors.slate800),
        const SizedBox(height: 24),
        if (state.isEditing)
          DoseScheduleEditor(
              slots: slots, onChanged: ref.read(_form.notifier).setSlot)
        else if (scheduled.isEmpty)
          AppText.bodyMedium(l10n.noScheduleConfigured,
              color: AppColors.slate400)
        else
          for (final section in scheduled) ...[
            AppText.bodyLarge(section.label(l10n),
                fontWeight: FontWeight.bold, color: AppColors.slate800),
            const SizedBox(height: 8),
            AppText.bodyMedium(
                '${slots[section]!.time.format(context)} | '
                '${slots[section]!.quantity} ${state.form.unit}(s)',
                color: AppColors.slate600),
            const SizedBox(height: 24),
          ],
      ],
    );
  }
}

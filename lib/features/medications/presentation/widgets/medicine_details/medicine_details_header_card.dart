import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/utils/failure_message.dart';
import '../../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/medicine_details_form_controller.dart';
import 'adherence_calendar.dart';

/// Name, dosage and the month's dose calendar.
class MedicineDetailsHeaderCard extends ConsumerWidget {
  const MedicineDetailsHeaderCard({super.key, required this.medicationId});

  final String medicationId;

  MedicineDetailsFormControllerProvider get _form =>
      medicineDetailsFormControllerProvider(medicationId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_form);
    final history = state.history;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.bodyLarge(state.name,
                  fontWeight: FontWeight.bold, color: AppColors.slate800),
              const SizedBox(width: 8),
              AppText.titleMedium(state.detail?.dosage ?? '',
                  color: AppColors.slate400),
            ],
          ),
          const SizedBox(height: 24),
          if (history == null && state.historyError != null)
            Center(
                child: AppText.bodyMedium(
                    state.historyError!.message(context.l10n) ?? ''))
          else if (history == null)
            AppShimmer.box(
                height: 200, width: double.infinity, borderRadius: 16)
          else
            AdherenceCalendar(
                history: history,
                startDate: state.detail?.startDate,
                onMonthChanged: ref.read(_form.notifier).loadHistory),
        ],
      ),
    );
  }
}

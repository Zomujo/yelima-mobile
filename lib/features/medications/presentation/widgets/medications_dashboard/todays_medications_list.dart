import 'package:flutter/material.dart';
import 'package:yelima/core/utils/app_date_formats.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../controllers/medication_controller.dart';
import 'medication_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:clock/clock.dart';
import '../../../domain/dose_window.dart';
import '../../../domain/entities/medication_entity.dart';
import '../../../domain/medication_failures.dart';
import '../../medication_failure_message.dart';

/// Today's doses for the selected section, tappable to confirm.
class TodaysMedicationsList extends StatelessWidget {
  final MedicationController controller;

  const TodaysMedicationsList({super.key, required this.controller});

  /// Confirms [med]; an early tap gets a gentle note rather than an error.
  Future<void> _confirm(BuildContext context, MedicationEntity med) async {
    final l10n = context.l10n;
    final result = await controller.confirm(med);
    if (!context.mounted) return;
    result.fold((failure) {
      final text = failure.medicationMessage(l10n) ?? '';
      failure is DoseNotDueFailure
          ? AppSnackBar.showInfo(context, message: text)
          : AppSnackBar.showError(context, message: text);
    }, (_) {});
  }

  @override
  Widget build(BuildContext context) {
    final meds = controller.state.doses[controller.state.section];
    if (meds == null) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppShimmer.box(width: double.infinity, height: 100),
          ),
          childCount: 3,
        ),
      );
    }

    if (meds.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: AppEmptyState(
            title: context.l10n.noMedicationsScheduled,
            iconAsset: AppImages.pillIcon.assetName,
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final med = meds[index];
          final timeString = AppDateFormats.timeShort.format(med.toBeTakenAt);
          final canConfirm =
              DoseWindow.canConfirm(med.toBeTakenAt, clock.now());

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _confirm(context, med),
              child: MedicationCard(
                name: med.name,
                dosage: med.dosage,
                purpose: med.purpose,
                time: timeString,
                isTaken: med.taken,
                isOverdue: !med.taken && canConfirm,
                isEarly: !med.taken && !canConfirm,
                isConfirming:
                    controller.state.confirmingMedicationIds.contains(med.id),
                onConfirm: () => _confirm(context, med),
              ),
            ),
          );
        },
        childCount: meds.length,
      ),
    );
  }
}

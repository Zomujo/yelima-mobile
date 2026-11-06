import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/core/utils/app_date_formats.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../../shared/widgets/motion/entrance.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../controllers/medication_controller.dart';
import '../../../../../shared/widgets/motion/fade_switch.dart';
import 'medication_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:clock/clock.dart';
import '../../../domain/dose_window.dart';
import '../../../domain/entities/medication_entity.dart';
import '../../../domain/medication_failures.dart';
import '../../medication_failure_message.dart';

/// Today's doses for the selected section, tappable to confirm; the list
/// cross-fades when the section or its loading state changes.
class TodaysMedicationsList extends ConsumerWidget {
  const TodaysMedicationsList({super.key});

  /// Confirms [med]; an early tap gets a gentle note rather than an error.
  Future<void> _confirm(
      BuildContext context, WidgetRef ref, MedicationEntity med) async {
    final l10n = context.l10n;
    final confirming =
        ref.read(medicationControllerProvider).confirmingMedicationIds;
    // Taken or in-flight doses succeed without doing anything; no buzz then.
    final isNew = !med.taken && !confirming.contains(med.id);
    final result =
        await ref.read(medicationControllerProvider.notifier).confirm(med);
    if (!context.mounted) return;
    result.fold((failure) {
      final text = failure.medicationMessage(l10n) ?? '';
      failure is DoseNotDueFailure
          ? AppSnackBar.showInfo(context, message: text)
          : AppSnackBar.showError(context, message: text);
    }, (_) {
      if (isNew) HapticFeedback.lightImpact();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationControllerProvider);
    final (kind, content) = switch (state.doses[state.section]) {
      null => ('loading', const _LoadingDoses()),
      [] => (
          'empty',
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: AppEmptyState(
              title: context.l10n.noMedicationsScheduled,
              iconAsset: AppImages.pillIcon.assetName,
            ),
          ),
        ),
      final meds => (
          'doses',
          Column(children: [
            for (final (i, med) in meds.indexed)
              Entrance(
                key: ValueKey(med.id),
                index: i,
                child: _DoseTile(
                  med: med,
                  isConfirming: state.confirmingMedicationIds.contains(med.id),
                  onConfirm: () => _confirm(context, ref, med),
                ),
              ),
          ]),
        ),
    };
    return SliverToBoxAdapter(
      child: FadeSwitch(
        child:
            KeyedSubtree(key: ValueKey((state.section, kind)), child: content),
      ),
    );
  }
}

/// Placeholders while a section's doses load.
class _LoadingDoses extends StatelessWidget {
  const _LoadingDoses();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (var i = 0; i < 3; i++)
        const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: AppShimmer.box(width: double.infinity, height: 100),
        ),
    ]);
  }
}

/// One dose row; the whole card confirms on tap, like its button.
class _DoseTile extends StatelessWidget {
  const _DoseTile(
      {required this.med, required this.isConfirming, required this.onConfirm});

  final MedicationEntity med;
  final bool isConfirming;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final canConfirm = DoseWindow.canConfirm(med.toBeTakenAt, clock.now());
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onConfirm,
        child: MedicationCard(
          name: med.name,
          dosage: med.dosage,
          purpose: med.purpose,
          time: AppDateFormats.timeShort.format(med.toBeTakenAt),
          isTaken: med.taken,
          isOverdue: !med.taken && canConfirm,
          isEarly: !med.taken && !canConfirm,
          isConfirming: isConfirming,
          onConfirm: onConfirm,
        ),
      ),
    );
  }
}

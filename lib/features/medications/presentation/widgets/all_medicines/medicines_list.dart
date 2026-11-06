import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../../shared/widgets/motion/entrance.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../controllers/all_medicines_controller.dart';
import 'medicine_history_card.dart';
import 'delete_medication_modal.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../../shared/utils/failure_message.dart';

/// The medication list with swipe-to-delete; the first rows ease in.
class MedicinesList extends ConsumerStatefulWidget {
  const MedicinesList({super.key});

  @override
  ConsumerState<MedicinesList> createState() => _MedicinesListState();
}

class _MedicinesListState extends ConsumerState<MedicinesList> {
  // Only the rows on the first screen stagger in.
  static const _staggered = 8;
  static var _visits = 0;

  // One key per visit, so rows scrolled away and back don't replay.
  final _visit = 'allMedicines/${_visits++}';

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(allMedicinesControllerProvider);
    if (medications == null) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return const AppShimmer.box(
            height: 120,
            width: double.infinity,
            borderRadius: 16,
          );
        },
      );
    }

    if (medications.isEmpty) {
      return AppEmptyState(
        title: context.l10n.noMedicinesFound,
        iconAsset: AppImages.pillIcon.assetName,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];
        final row = Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Dismissible(
            key: Key(medication.id),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              final result =
                  await DeleteMedicationModal.show(context, medication.name);
              return result ?? false;
            },
            onDismissed: (_) async {
              final l10n = context.l10n;
              final result = await ref
                  .read(allMedicinesControllerProvider.notifier)
                  .delete(medication.id);
              if (!context.mounted) return;
              result.fold(
                (f) => AppSnackBar.showError(context,
                    message: f.message(l10n) ?? ''),
                (_) => AppSnackBar.showSuccess(context,
                    message: l10n.medicationDeleted(medication.name)),
              );
            },
            child: MedicineHistoryCard(
              medication: medication,
            ),
          ),
        );
        return index < _staggered
            ? Entrance(index: index, playOnce: '$_visit/$index', child: row)
            : row;
      },
    );
  }
}

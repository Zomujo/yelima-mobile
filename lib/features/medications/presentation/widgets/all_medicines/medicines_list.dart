import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../controllers/all_medicines_controller.dart';
import 'medicine_history_card.dart';
import 'delete_medication_modal.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class MedicinesList extends StatelessWidget {
  const MedicinesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AllMedicinesController>(
      builder: (context, controller, child) {
        final state = controller.listState;

        if (state.isLoading) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return AppShimmer.box(
                height: 120,
                width: double.infinity,
                borderRadius: 16,
              );
            },
          );
        }

        if (state.error != null) {
          return Center(child: AppText.bodyMedium('Error: ${state.error}'));
        }

        final medications = state.data?.rows ?? [];

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
            return Padding(
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
                      await DeleteMedicationModal.show(context, medication);
                  return result ?? false;
                },
                onDismissed: (direction) {
                  controller.deleteMedication(medication.id);
                  AppSnackBar.showSuccess(context,
                      message: '${medication.name} deleted');
                },
                child: MedicineHistoryCard(
                  medication: medication,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

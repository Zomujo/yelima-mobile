import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../../shared/widgets/layout/app_empty_state.dart';
import '../../controllers/all_medicines_controller.dart';
import 'medicine_history_card.dart';

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
            title: 'No medicines found.',
            iconAsset: AppImages.pillIcon.assetName,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: medications.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: MedicineHistoryCard(
                medication: medications[index],
              ),
            );
          },
        );
      },
    );
  }
}

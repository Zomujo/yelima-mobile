import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../controllers/medication_controller.dart';
import 'medication_card.dart';

class TodaysMedicationsList extends StatelessWidget {
  final MedicationController controller;

  const TodaysMedicationsList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final section = controller.state.selectedTabIndex == 0 ? 'MORNING' : controller.state.selectedTabIndex == 1 ? 'AFTERNOON' : 'EVENING';
    if (controller.state.sectionLoadingStatus[section] == true) {
      return Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppShimmer.box(width: double.infinity, height: 100),
          ),
        ),
      );
    }

    if (controller.state.sectionErrors[section] != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: AppText.bodyMedium(
            controller.state.sectionErrors[section]!,
            color: Colors.red,
          ),
        ),
      );
    }

    final meds = controller.state.medicationsBySection[section] ?? [];

    if (meds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: AppEmptyState(
          title: 'No medications scheduled.',
          iconAsset: AppImages.pillIcon.assetName,
        ),
      );
    }

    return Column(
      children: meds.map((med) {
        final timeString = DateFormat('h:mm a').format(med.toBeTakenAt);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () async {
              final error = await controller.toggleMedicationStatus(med.id);
              if (error != null && context.mounted) {
                AppSnackBar.showError(context, message: error);
              }
            },
            child: MedicationCard(
              name: med.name,
              dosage: med.dosage,
              purpose: med.purpose,
              time: timeString,
              isTaken: med.taken,
              isOverdue: !med.taken && DateTime.now().isAfter(med.toBeTakenAt),
              isConfirming: controller.state.confirmingMedicationId == med.id,
              onConfirm: () async {
                final error = await controller.toggleMedicationStatus(med.id);
                if (error != null && context.mounted) {
                  AppSnackBar.showError(context, message: error);
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

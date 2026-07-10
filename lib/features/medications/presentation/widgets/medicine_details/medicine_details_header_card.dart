import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../data/models/medication_detail_model.dart';
import 'adherence_calendar.dart';
import '../../controllers/all_medicines_controller.dart';
import 'package:provider/provider.dart';

class MedicineDetailsHeaderCard extends StatelessWidget {
  final MedicationDetailModel data;
  final String medicationId;

  const MedicineDetailsHeaderCard({
    super.key,
    required this.data,
    required this.medicationId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.bodyLarge(
                data.name,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
              const SizedBox(width: 8),
              AppText.titleMedium(data.dosage, color: const Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 24),
          Consumer<AllMedicinesController>(
            builder: (context, controller, child) {
              final historyState = controller.historyStates[medicationId];
              if (historyState == null || historyState.isLoading) {
                return AppShimmer.box(
                    height: 200, width: double.infinity, borderRadius: 16);
              } else if (historyState.error != null) {
                return Center(
                    child: AppText.bodyMedium('Error: ${historyState.error}'));
              } else if (historyState.data != null) {
                return AdherenceCalendar(
                    medicationId: medicationId, history: historyState.data!);
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

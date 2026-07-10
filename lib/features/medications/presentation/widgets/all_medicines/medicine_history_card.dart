import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_entity.dart';

class MedicineHistoryCard extends StatelessWidget {
  final MedicationEntity medication;

  const MedicineHistoryCard({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () {
          GoRouter.of(context).push('/medications/${medication.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppText.titleMedium(
                    medication.name,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                  const SizedBox(width: 8),
                  AppText.bodyMedium(
                    medication.dosage,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

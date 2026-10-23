import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_entity.dart';

/// A medication in the all-medicines list; opens its details.
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
        border: Border.all(color: AppColors.slate200),
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
                    color: AppColors.slate800,
                  ),
                  const SizedBox(width: 8),
                  AppText.bodyMedium(
                    medication.dosage,
                    color: AppColors.slate400,
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

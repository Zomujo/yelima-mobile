import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';

class NextClinicVisitCard extends StatelessWidget {
  final String date;
  final String time;
  final String location;

  const NextClinicVisitCard({
    super.key,
    required this.date,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.calendar_1,
            color: AppColors.textGrey,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppText.titleMedium(
                  'Next clinic visit',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
                const SizedBox(height: 4),
                AppText.labelMedium(
                  '$date, $time · $location',
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_button.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String purpose;
  final String time;
  final bool isTaken;
  final bool isOverdue;
  final bool isConfirming;
  final VoidCallback? onConfirm;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.purpose,
    required this.time,
    required this.isTaken,
    this.isOverdue = false,
    this.isConfirming = false,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isOverdue
        ? Colors.red.shade300
        : (isTaken ? const Color(0xFF82C76F) : Colors.transparent);
    final backgroundColor = isOverdue ? const Color(0xFFFEF2F2) : Colors.white;
    final timeColor = isOverdue ? Colors.red : AppColors.textGrey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          if (!isTaken)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isTaken) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isOverdue ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFF1F5F9), // Light grey/blue
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Image(
                  image: AppImages.mediIcon,
                  height: 20,
                  width: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: AppText.bodyLarge(name,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 4),
                    AppText.bodyMedium(dosage, color: AppColors.textGrey),
                  ],
                ),
                if (purpose.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText.labelMedium(
                    purpose,
                    color: const Color(0xFF8F9299),
                    fontWeight: FontWeight.w200,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: timeColor),
                    const SizedBox(width: 4),
                    AppText.labelMedium(time, color: timeColor),
                  ],
                ),
              ],
            ),
          ),
          if (isTaken)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF82C76F), width: 2),
              ),
              child:
                  const Icon(Icons.check, size: 18, color: Color(0xFF82C76F)),
            )
          else if (isConfirming)
            const SizedBox(
              width: 36,
              height: 36,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else
            AppButton(
              text: 'Confirm',
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: 20,
              onPressed: onConfirm ?? () {},
              fontSize: 14,
              backgroundColor: isOverdue ? Colors.red : AppColors.primary,
            ),
        ],
      ),
    );
  }
}

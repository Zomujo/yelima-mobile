import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';

class RecentMessageTile extends StatelessWidget {
  final String sender;
  final String time;
  final String message;
  final VoidCallback onTap;

  const RecentMessageTile({
    super.key,
    required this.sender,
    required this.time,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.titleMedium(
                  sender,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                AppText.labelMedium(
                  time,
                  color: AppColors.textGrey,
                ),
              ],
            ),
            const SizedBox(height: 4),
            AppText.bodyMedium(
              message,
              color: AppColors.textGrey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

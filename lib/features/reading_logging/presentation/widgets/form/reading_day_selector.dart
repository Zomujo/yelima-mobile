import 'package:flutter/material.dart';
import '../../../../../../shared/widgets/layout/app_text.dart';

class ReadingDaySelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const ReadingDaySelector({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Day',
          fontWeight: FontWeight.w600,
          variant: AppTextVariant.titleLarge,
          color: Color(0xFF1E293B),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                const SizedBox(width: 12),
                AppText.bodyLarge(
                  _formatDate(selectedDate),
                  color: isToday
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

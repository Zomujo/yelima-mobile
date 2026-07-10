import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';

class TimeOfDayTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final Map<String, int> counts;

  const TimeOfDayTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.counts,
  });

  Widget _buildTab(int index, String title, int count) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF64748B) : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.labelMedium(
              title,
              color: isSelected ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: AppText.labelSmall(
                  count.toString(),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab(0, 'MORNING', counts['MORNING'] ?? 0),
          const SizedBox(width: 24),
          _buildTab(1, 'AFTERNOON', counts['AFTERNOON'] ?? 0),
          const SizedBox(width: 24),
          _buildTab(2, 'EVENING', counts['EVENING'] ?? 0),
        ],
      ),
    );
  }
}


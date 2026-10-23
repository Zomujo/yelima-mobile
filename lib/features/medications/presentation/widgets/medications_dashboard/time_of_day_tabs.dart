import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_count.dart';
import '../../../domain/entities/medication_section.dart';

/// Morning / Afternoon / Evening tabs with a dose count on each.
class TimeOfDayTabs extends StatelessWidget {
  const TimeOfDayTabs({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.counts,
  });

  final MedicationSection selected;
  final ValueChanged<MedicationSection> onSelected;
  final MedicationCount? counts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (section, title, count) in [
            (MedicationSection.morning, l10n.morning, counts?.morning),
            (MedicationSection.afternoon, l10n.afternoon, counts?.afternoon),
            (MedicationSection.evening, l10n.evening, counts?.evening),
          ]) ...[
            if (section != MedicationSection.morning) const SizedBox(width: 24),
            _Tab(
              title: title,
              count: count ?? 0,
              isSelected: section == selected,
              onTap: () => onSelected(section),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(
      {required this.title,
      required this.count,
      required this.isSelected,
      required this.onTap});

  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: isSelected ? AppColors.slate500 : Colors.transparent),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.labelMedium(title,
                color: isSelected ? AppColors.slate500 : AppColors.slate400,
                fontWeight: FontWeight.w600),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: AppText.labelSmall('$count',
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

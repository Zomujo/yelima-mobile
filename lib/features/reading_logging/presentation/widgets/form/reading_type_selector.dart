import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'log_type_card.dart';

class ReadingTypeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTypeSelected;

  const ReadingTypeSelector({
    super.key,
    required this.selectedIndex,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onTypeSelected(0),
            child: LogTypeCard(
              title: 'Blood pressure',
              subtitle: 'Top & bottom number',
              icon: Icons.favorite_border,
              isSelected: selectedIndex == 0,
              iconColor:
                  selectedIndex == 0 ? AppColors.primary : AppColors.textGrey,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => onTypeSelected(1),
            child: LogTypeCard(
              title: 'Sugar',
              subtitle: 'mmol/L',
              icon: Icons.water_drop_outlined,
              isSelected: selectedIndex == 1,
              iconColor:
                  selectedIndex == 1 ? AppColors.primary : AppColors.textGrey,
            ),
          ),
        ),
      ],
    );
  }
}

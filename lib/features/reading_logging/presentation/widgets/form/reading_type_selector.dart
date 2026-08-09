import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'log_type_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeSelected(0),
              child: LogTypeCard(
                title: context.l10n.bloodPressure,
                subtitle: context.l10n.topBottomNumber,
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
                title: context.l10n.sugar,
                subtitle: context.l10n.mmolL,
                icon: Icons.water_drop_outlined,
                isSelected: selectedIndex == 1,
                iconColor:
                    selectedIndex == 1 ? AppColors.primary : AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

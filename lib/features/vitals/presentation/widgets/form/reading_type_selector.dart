import 'package:flutter/material.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/features/vitals/presentation/widgets/form/log_type_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/shared/widgets/motion/pressable.dart';

/// Blood pressure or blood sugar.
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
    final types = [
      (
        context.l10n.bloodPressure,
        context.l10n.topBottomNumber,
        Icons.favorite_border
      ),
      (context.l10n.sugar, context.l10n.mmolL, Icons.water_drop_outlined),
    ];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          for (final (i, (title, subtitle, icon)) in types.indexed)
            Expanded(
              child: Pressable(
                child: GestureDetector(
                  onTap: () => onTypeSelected(i),
                  child: LogTypeCard(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                    isSelected: selectedIndex == i,
                    iconColor: selectedIndex == i
                        ? AppColors.primary
                        : AppColors.textGrey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

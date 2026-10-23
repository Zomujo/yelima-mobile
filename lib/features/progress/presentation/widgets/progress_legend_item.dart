import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A coloured dot and its label.
class ProgressLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const ProgressLegendItem({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.slate500,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Systolic over diastolic in large type; shrinks to fit long labels or narrow screens.
class BloodPressureDisplay extends StatelessWidget {
  const BloodPressureDisplay({
    super.key,
    required this.systolic,
    required this.diastolic,
  });

  final String systolic;
  final String diastolic;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: _Value(context.l10n.systolic, systolic)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AppText.displaySmall('/', color: Colors.grey.shade300),
        ),
        Flexible(
          child: _Value(context.l10n.diastolic, diastolic,
              background: const Color(0xFFF4F8FF)),
        ),
      ],
    );
  }
}

class _Value extends StatelessWidget {
  const _Value(this.label, this.value, {this.background});

  final String label;
  final String value;
  final Color? background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: background == null
            ? null
            : BoxDecoration(
                color: background, borderRadius: BorderRadius.circular(16)),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              AppText.labelMedium(label, color: AppColors.textGrey),
              const SizedBox(height: 4),
              AppText.displaySmall(value,
                  color: AppColors.slate800, fontWeight: FontWeight.w500),
            ],
          ),
        ),
      );
}

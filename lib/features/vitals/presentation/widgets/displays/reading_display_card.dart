import 'package:flutter/material.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/core/constants/app_decoration.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// The frame around the reading being entered.
class ReadingDisplayCard extends StatelessWidget {
  const ReadingDisplayCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppDecoration.shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.labelLarge(
            context.l10n.readingFromMeter,
            color: AppColors.textGrey,
            fontWeight: FontWeight.normal,
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

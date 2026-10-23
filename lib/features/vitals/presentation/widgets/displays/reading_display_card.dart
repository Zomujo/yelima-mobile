import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/constants/app_decoration.dart';
import '../../../../../../shared/widgets/layout/app_text.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

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

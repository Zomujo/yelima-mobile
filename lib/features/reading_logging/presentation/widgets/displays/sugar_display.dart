import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../shared/widgets/layout/app_text.dart';

class SugarDisplay extends StatelessWidget {
  const SugarDisplay({
    super.key,
    required this.sugarLevel,
  });

  final String sugarLevel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const AppText.labelMedium(
            'MMOL/L',
            color: AppColors.textGrey,
            letterSpacing: 2,
          ),
          const SizedBox(height: 8),
          AppText.displayMedium(
            sugarLevel,
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 2,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

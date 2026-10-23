import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';

class HealthExpansionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const HealthExpansionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: AppText.bodyLarge(title, fontWeight: FontWeight.w500),
        leading: Icon(icon, color: AppColors.slate500),
        iconColor: AppColors.slate900,
        collapsedIconColor: AppColors.slate500,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: AppColors.slate200),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';

class ProgressGraphCard extends StatelessWidget {
  final String title;
  final String latestValue;
  final String latestSubtext;
  final String badgeText;
  final IconData badgeIcon;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData? badgeTrailingIcon;
  final String description;
  final Widget graph;
  final Widget? legend;
  final VoidCallback onExpand;

  const ProgressGraphCard({
    super.key,
    required this.title,
    required this.latestValue,
    required this.latestSubtext,
    required this.badgeText,
    required this.badgeIcon,
    required this.badgeColor,
    required this.badgeTextColor,
    this.badgeTrailingIcon,
    required this.description,
    required this.graph,
    this.legend,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText.titleLarge(
                  title,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    latestValue,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText.labelSmall(
                    latestSubtext,
                    color: AppColors.textGrey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppText.bodyMedium(
            description,
            color: AppColors.textGrey,
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: graph,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onExpand,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.fullscreen,
                        size: 24,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (legend != null) ...[
            const SizedBox(height: 16),
            legend!,
          ]
        ],
      ),
    );
  }
}

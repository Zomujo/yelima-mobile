import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../shared/widgets/motion/pressable.dart';
import 'counting_text.dart';

/// One home metric: title, value and its grade.
class MetricCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String? subValue;
  final String unit;
  final bool isLoading;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.mainValue,
    this.subValue,
    required this.unit,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.grey.withValues(alpha: 0.5), width: 0.7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (isLoading)
                    const AppShimmer.box(width: 80, height: 32)
                  else ...[
                    CountingText(
                      mainValue,
                      playOnce: 'count/home/$title',
                      builder: (text) => AppText.headlineMedium(
                        text,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate800,
                      ),
                    ),
                    if (subValue != null)
                      CountingText(
                        subValue!,
                        playOnce: 'count/home/$title/sub',
                        builder: (text) => AppText.titleMedium(
                          text,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textGrey,
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              AppText.labelLarge(
                title,
                fontWeight: FontWeight.normal,
                color: AppColors.textGrey,
              ),
              AppText.labelLarge(
                unit,
                color: AppColors.textGrey.withValues(alpha: 0.6),
                fontWeight: FontWeight.w100,
              ),
            ],
          ),
        ));
    // Only a card that does something on tap reacts to the press.
    return onTap == null ? card : Pressable(child: card);
  }
}

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../shared/widgets/layout/app_text.dart';

class CriticalHealthBanner extends StatelessWidget {
  final String title;
  final String message;
  final bool isCritical;

  const CriticalHealthBanner({
    super.key,
    required this.title,
    required this.message,
    this.isCritical = true,
  });

  @override
  Widget build(BuildContext context) {
    final stripeColor = isCritical
        ? const Color(0xFFDC2626)
        : const Color(0xFFEA580C); // Red 600 or Orange 600
    final bgColor = isCritical
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFFFEDD5); // Red 50 or Orange 50
    final titleColor = isCritical
        ? const Color(0xFF991B1B)
        : const Color(0xFF9A3412); // Red 800 or Orange 800
    final bodyColor = isCritical
        ? const Color(0xFFB91C1C)
        : const Color(0xFFC2410C); // Red 700 or Orange 700

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: stripeColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: stripeColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.warning_2,
                  color: stripeColor,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.titleMedium(
                        title,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                      const SizedBox(height: 4),
                      AppText.bodyMedium(
                        message,
                        color: bodyColor,
                        height: 1.4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

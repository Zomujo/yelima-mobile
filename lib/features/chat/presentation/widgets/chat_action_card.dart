import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';

class ChatActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final String? badgeText;

  const ChatActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
    required this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: badgeText != null ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: gradient,
        ),
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: AppText.titleMedium(
                                title,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (badgeText != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AppText.labelSmall(
                                  badgeText!,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        AppText.labelMedium(
                          subtitle,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                  ),
                  if (badgeText == null)
                    const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              AppText.bodyMedium(
                description,
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

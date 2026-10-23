import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class ProgressNoteBanner extends StatefulWidget {
  final String note;

  const ProgressNoteBanner({super.key, required this.note});

  @override
  State<ProgressNoteBanner> createState() => _ProgressNoteBannerState();
}

class _ProgressNoteBannerState extends State<ProgressNoteBanner> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.blue500,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 6), // 6px width for the side stripe
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.slate100, // Soft greyish-blue background
            borderRadius: BorderRadius.only(
              topLeft:
                  Radius.circular(10), // 16 - 6 = 10 (perfect uniform curve)
              bottomLeft: Radius.circular(10),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.health,
                          color: AppColors.blue500,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppText.titleMedium(
                            context.l10n.healthInsightsTitle,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.blue500,
                          size: 28,
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12, left: 36),
                              child: AppText.bodyMedium(
                                widget.note.trim(),
                                color: const Color(0xFF1E40AF),
                                height: 1.5,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

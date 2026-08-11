import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';

class SymptomCard extends StatefulWidget {
  final String content;

  const SymptomCard({
    super.key,
    required this.content,
  });

  @override
  State<SymptomCard> createState() => _SymptomCardState();
}

class _SymptomCardState extends State<SymptomCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textBlack,
            );
        final span = TextSpan(text: widget.content, style: textStyle);
        final tp = TextPainter(
          text: span,
          maxLines: 1,
          textDirection: TextDirection.ltr,
        );

        // Container padding (16*2) + SizedBox (8) + Icon (24) = 64
        final maxTextWidth = constraints.maxWidth - 64;
        tp.layout(maxWidth: maxTextWidth > 0 ? maxTextWidth : 0);
        final isOverflowing = tp.didExceedMaxLines;

        return GestureDetector(
          onTap: isOverflowing
              ? () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText.bodyMedium(
                          widget.content,
                          color: AppColors.textBlack,
                          maxLines: _isExpanded ? null : 1,
                          overflow: _isExpanded ? null : TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOverflowing) ...[
                        const SizedBox(width: 8),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textBlack,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

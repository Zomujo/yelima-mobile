import 'package:flutter/material.dart';

class AppLinearProgressBar extends StatelessWidget {
  /// Current progress from 0.0 to 1.0 (used for continuous mode).
  final double? percentage;

  /// Current step (1-indexed) for segmented mode.
  final int? currentStep;

  /// Total number of steps for segmented mode.
  final int? totalSteps;

  /// Whether to show the percentage label text.
  final bool showLabel;

  /// Height of the progress bar.
  final double height;

  /// Gap between segments in segmented mode.
  final double gap;

  /// Fill color for the progress.
  final Color? color;

  /// Background color for the track.
  final Color? backgroundColor;

  /// Border radius for the bar.
  final BorderRadius? borderRadius;

  const AppLinearProgressBar({
    super.key,
    this.percentage,
    this.currentStep,
    this.totalSteps,
    this.showLabel = false,
    this.height = 8,
    this.gap = 4,
    this.color,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSteps != null && totalSteps! > 1) {
      return _buildSegmented(context);
    }
    return _buildContinuous(context);
  }

  Widget _buildContinuous(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (percentage ?? 0.0).clamp(0.0, 1.0);
    final bar = LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: height,
          decoration: BoxDecoration(
            color:
                backgroundColor ?? theme.disabledColor.withValues(alpha: 0.1),
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: constraints.maxWidth * percent,
                decoration: BoxDecoration(
                  color: color ?? theme.primaryColor,
                  borderRadius:
                      borderRadius ?? BorderRadius.circular(height / 2),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (showLabel) {
      return Row(
        children: [
          Expanded(child: bar),
          const SizedBox(width: 12),
          Text(
            '${(percent * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      );
    }

    return bar;
  }

  Widget _buildSegmented(BuildContext context) {
    final theme = Theme.of(context);
    final step = currentStep ?? 0;
    final total = totalSteps!;

    return SizedBox(
      height: height,
      child: Row(
        children: List.generate(total, (index) {
          final isActive = index < step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < total - 1 ? gap : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? (color ?? theme.primaryColor)
                    : (backgroundColor ??
                        theme.disabledColor.withValues(alpha: 0.1)),
                borderRadius: borderRadius ?? BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

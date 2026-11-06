import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_motion.dart';
import '../../domain/entities/vital_trends.dart';

/// 24h / 1 week / 1 month tabs, with a white pill that slides to the chosen one.
class DurationSelector extends StatelessWidget {
  const DurationSelector(
      {super.key, required this.range, required this.onChanged});

  final ChartDateRange range;
  final ValueChanged<ChartDateRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      (ChartDateRange.today, l10n.twentyFourHours),
      (ChartDateRange.thisWeek, l10n.oneWeek),
      (ChartDateRange.thisMonth, l10n.oneMonth),
    ];
    final index = tabs.indexWhere((t) => t.$1 == range);
    final duration =
        AppMotion.duration(context, AppMotion.medium);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              // -1, 0, 1 across the three tabs.
              alignment: Alignment(index - 1.0, 0),
              duration: duration,
              curve: AppMotion.move,
              child: const FractionallySizedBox(
                  widthFactor: 1 / 3, heightFactor: 1, child: _Pill()),
            ),
          ),
          Row(
            children: [
              for (final (r, label) in tabs)
                Expanded(
                  child: _Tab(
                    label: label,
                    active: r == range,
                    duration: duration,
                    onTap: () => onChanged(r),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The white marker behind the chosen tab.
class _Pill extends StatelessWidget {
  const _Pill();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
          ],
        ),
      );
}

/// One tab label; its colour eases between chosen and not.
class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.active,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: duration,
            curve: AppMotion.move,
            style: DefaultTextStyle.of(context).style.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: active
                      ? const Color(0xFF1F2937)
                      : const Color(0xFF6B7280),
                ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      );
}

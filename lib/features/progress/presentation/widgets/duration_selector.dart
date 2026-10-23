import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../domain/entities/vital_trends.dart';

/// 24h / 1 week / 1 month tabs.
class DurationSelector extends StatelessWidget {
  const DurationSelector(
      {super.key, required this.range, required this.onChanged});

  final ChartDateRange range;
  final ValueChanged<ChartDateRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (final (r, label) in [
            (ChartDateRange.today, l10n.twentyFourHours),
            (ChartDateRange.thisWeek, l10n.oneWeek),
            (ChartDateRange.thisMonth, l10n.oneMonth),
          ])
            Expanded(child: _tab(r, label)),
        ],
      ),
    );
  }

  Widget _tab(ChartDateRange r, String label) {
    final active = r == range;
    return GestureDetector(
      onTap: () => onChanged(r),
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2))
                ]
              : const [],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: active ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

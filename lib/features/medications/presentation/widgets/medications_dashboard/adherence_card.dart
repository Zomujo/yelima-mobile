import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_adherence.dart';
import '../../../../../core/utils/app_date_formats.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:clock/clock.dart';

/// How a day of the week is drawn.
enum DayStatus { taken, missed, pending, future }

/// The weekly adherence rate and a dot per day.
class AdherenceCard extends StatelessWidget {
  final MedicationAdherence? adherence;

  const AdherenceCard({super.key, this.adherence});

  @override
  Widget build(BuildContext context) {
    if (adherence == null) return const SizedBox.shrink();

    final rate = adherence!.rate.toInt();

    final List<Widget> dayWidgets = adherence!.days.map((dayData) {
      final label =
          AppDateFormats.dayOfWeekShort.format(dayData.takenAt).substring(0, 1);

      final status = switch (dayData.taken) {
        true => DayStatus.taken,
        // A settled day with no doses scheduled isn't a miss.
        false when dayData.scheduledDoses == 0 => DayStatus.future,
        false => DayStatus.missed,
        null when dayData.takenAt.isAfter(clock.now()) => DayStatus.future,
        null => DayStatus.pending,
      };
      // Recent days can still change, so they show their count, not a tick or cross.
      final count =
          status == DayStatus.pending && dayData.scheduledDoses != null
              ? '${dayData.takenDoses ?? 0}/${dayData.scheduledDoses}'
              : null;
      return _DayCircle(label, status: status, count: count);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyMedium(
            context.l10n.thisWeeksAdherence,
            color: Colors.white,
          ),
          Text(
            '$rate%',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          AppText.bodyMedium(
            rate >= 80
                ? context.l10n.doingWellKeepItUp
                : context.l10n.adherenceImprove,
            color: Colors.white,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayWidgets.isNotEmpty
                ? dayWidgets.take(7).toList()
                : _buildDefaultDays(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDefaultDays() {
    return [
      const _DayCircle('M', status: DayStatus.future),
      const _DayCircle('T', status: DayStatus.future),
      const _DayCircle('W', status: DayStatus.future),
      const _DayCircle('T', status: DayStatus.future),
      const _DayCircle('F', status: DayStatus.future),
      const _DayCircle('S', status: DayStatus.future),
      const _DayCircle('S', status: DayStatus.future),
    ];
  }
}

class _DayCircle extends StatelessWidget {
  final String day;
  final DayStatus status;
  final String? count;

  const _DayCircle(this.day, {required this.status, this.count});

  @override
  Widget build(BuildContext context) {
    Widget icon;
    Color bgColor;

    switch (status) {
      case DayStatus.taken:
        bgColor = Colors.white;
        icon = const Icon(Icons.check, color: AppColors.primaryGreen, size: 16);
        break;
      case DayStatus.missed:
        bgColor = Colors.white.withValues(alpha: 0.3);
        icon = const Icon(Icons.close, color: Colors.white, size: 16);
        break;
      case DayStatus.pending:
        bgColor = Colors.white.withValues(alpha: 0.3);
        icon = count == null
            ? const SizedBox(width: 16, height: 16)
            : Text(count!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600));
        break;
      case DayStatus.future:
        bgColor = Colors.white.withValues(alpha: 0.2);
        icon = const SizedBox(width: 16, height: 16);
        break;
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: icon),
        ),
        const SizedBox(height: 3),
        AppText.labelSmall(
          day,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_adherence.dart';
import '../../../../../core/utils/app_date_formats.dart';

enum DayStatus { taken, missed, future }

class AdherenceCard extends StatelessWidget {
  final MedicationAdherence? adherence;

  const AdherenceCard({super.key, this.adherence});

  @override
  Widget build(BuildContext context) {
    if (adherence == null) return const SizedBox.shrink();

    final rate = adherence!.rate.toInt();
    
    // We map the backend days to our DayStatus UI
    final List<Widget> dayWidgets = adherence!.days.map((dayData) {
      final label = AppDateFormats.dayOfWeekShort.format(dayData.takenAt).substring(0, 1);
      
      // Determine status based on taken boolean and date
      DayStatus status;
      if (dayData.taken) {
        status = DayStatus.taken;
      } else {
        // If it's a future date, we mark it future, else missed
        final now = DateTime.now();
        if (dayData.takenAt.isAfter(now)) {
          status = DayStatus.future;
        } else {
          status = DayStatus.missed;
        }
      }
      return _DayCircle(label, status: status);
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
          const AppText.bodyMedium(
            "This week's adherence",
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
          const AppText.bodyMedium(
            "You're doing well — keep it up! 💪",
            color: Colors.white,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayWidgets.isNotEmpty ? dayWidgets : _buildDefaultDays(),
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

  const _DayCircle(this.day, {required this.status});

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

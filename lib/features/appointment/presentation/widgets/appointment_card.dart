import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/app_decoration.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';

import '../../../../core/utils/app_date_formats.dart';
import '../../domain/entities/appointment_entity.dart';
import 'package:clock/clock.dart';
import '../../../../core/extensions/l10n_extension.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.iconAsset,
    required this.isPast,
  });

  final AppointmentEntity appointment;
  final String iconAsset;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final iconColor = isPast ? AppColors.textGrey : AppColors.primary;
    final iconBgColor =
        isPast ? const Color(0xFFF1F5F9) : const Color(0xFFFFEDD5);

    final timeUntil = _relativeLabel(context, appointment.appointmentDate);

    final dateTime =
        AppDateFormats.appointmentCard.format(appointment.appointmentDate);
    final subtitle = context.l10n.appointmentWith(
        appointment.hostPersonnel.userName,
        appointment.hostPersonnel.facility.name);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: isPast ? null : AppDecoration.shadowXs),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  iconAsset,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.labelSmall(timeUntil, color: AppColors.textGrey),
                    const SizedBox(height: 4),
                    AppText.bodyLarge(
                      dateTime,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF1E293B),
                    ),
                    const SizedBox(height: 4),
                    AppText.bodyMedium(appointment.title,
                        color: const Color(0xFF475569)),
                    const SizedBox(height: 4),
                    AppText.labelSmall(
                      subtitle,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // if (!isPast) ...[
          //   const SizedBox(height: 20),
          //   Row(
          //     children: [
          //       Expanded(
          //         child: AppButton(
          //           text: 'Message clinic',
          //           variant: AppButtonVariant.outlined,
          //           backgroundColor: Colors.grey.shade300,
          //           foregroundColor: const Color(0xFF1E293B),
          //           padding: const EdgeInsets.symmetric(horizontal: 4),
          //           onPressed: () {},
          //           outlineColor: const Color(0xFFE2E1E1),
          //           height: 44,
          //           borderRadius: 24,
          //           fontSize: 14,
          //           fontWeight: FontWeight.w400,
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: AppButton(
          //           text: 'Reschedule',
          //           variant: AppButtonVariant.outlined,
          //           backgroundColor: Colors.grey.shade300,
          //           foregroundColor: const Color(0xFF1E293B),
          //           padding: const EdgeInsets.symmetric(horizontal: 4),
          //           onPressed: () {},
          //           outlineColor: const Color(0xFFE2E1E1),
          //           height: 44,
          //           borderRadius: 24,
          //           fontSize: 14,
          //           fontWeight: FontWeight.w400,
          //         ),
          //       ),
          //     ],
          //   ),
          // ],
        ],
      ),
    );
  }

  /// "in 3 days", "2 weeks ago", "today"... counted in calendar days from today.
  String _relativeLabel(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = DateTime(date.year, date.month, date.day)
        .difference(today)
        .inDays
        .abs();
    if (days == 0) return l10n.relToday;
    if (days == 1) return isPast ? l10n.relYesterday : l10n.relTomorrow;
    if (days < 7) return isPast ? l10n.relDaysAgo(days) : l10n.relInDays(days);
    if (days < 30) {
      return isPast ? l10n.relWeeksAgo(days ~/ 7) : l10n.relInWeeks(days ~/ 7);
    }
    return isPast
        ? l10n.relMonthsAgo(days ~/ 30)
        : l10n.relInMonths(days ~/ 30);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/app_decoration.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';

import 'package:intl/intl.dart';
import '../../domain/entities/appointment_entity.dart';

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

    final timeUntil = isPast 
        ? _formatPast(appointment.appointmentDate) 
        : _formatUpcoming(appointment.appointmentDate);
    
    final dateTime = DateFormat('EEE d MMM • HH:mm').format(appointment.appointmentDate);
    final subtitle = 'with ${appointment.hostPersonnel.userName} • ${appointment.hostPersonnel.facility.name}';

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
                    AppText.bodyMedium(appointment.title, color: const Color(0xFF475569)),
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

  String _formatUpcoming(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays == 0) return 'today';
    if (difference.inDays == 1) return 'tomorrow';
    if (difference.inDays < 7) return 'in ${difference.inDays} days';
    if (difference.inDays < 14) return 'in 1 week';
    if (difference.inDays < 30) return 'in ${difference.inDays ~/ 7} weeks';
    return 'in ${difference.inDays ~/ 30} months';
  }

  String _formatPast(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'today';
    if (difference.inDays == 1) return 'yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 14) return '1 week ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7} weeks ago';
    return '${difference.inDays ~/ 30} months ago';
  }
}

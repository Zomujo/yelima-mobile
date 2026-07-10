import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../controllers/appointment_controller.dart';
import '../states/appointment_state.dart';
import 'appointment_card.dart';

class PaginatedAppointmentList extends StatelessWidget {
  final PaginatedAppointmentState state;
  final bool isPast;
  final String emptyMessage;
  final String filter;
  final AppointmentController controller;

  const PaginatedAppointmentList({
    super.key,
    required this.state,
    required this.isPast,
    required this.emptyMessage,
    required this.filter,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return Column(
        children: List.generate(
          2,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppShimmer.box(
              height: 120,
              width: double.infinity,
              borderRadius: 16,
            ),
          ),
        ),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: AppText.bodyMedium('Error: ${state.error}'),
      );
    }

    if (state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppImages.appointmentIcon.assetName,
                width: 52,
                height: 52,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFCBD5E1),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              AppText.bodyMedium(
                emptyMessage,
                color: const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...state.items.map((appointment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppointmentCard(
              appointment: appointment,
              iconAsset: isPast
                  ? AppImages.calendarIcon.assetName
                  : AppImages.callIcon.assetName,
              isPast: isPast,
            ),
          );
        }),
        _PaginationControls(state: state, filter: filter, controller: controller),
      ],
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final PaginatedAppointmentState state;
  final String filter;
  final AppointmentController controller;

  const _PaginationControls({
    required this.state,
    required this.filter,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.bodyMedium(
            'Page ${state.page} of ${state.totalPages}',
            color: const Color(0xFF575F69),
            fontWeight: FontWeight.w600,
          ),
          Row(
            children: [
              _buildNavButton(
                icon: Icons.chevron_left,
                onPressed: state.page > 1
                    ? () => controller.fetchAppointments(
                          filter: filter,
                          targetPage: state.page - 1,
                        )
                    : null,
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                icon: Icons.chevron_right,
                onPressed: state.page < state.totalPages
                    ? () => controller.fetchAppointments(
                          filter: filter,
                          targetPage: state.page + 1,
                        )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback? onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFDBA74)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFFDBA74)),
        onPressed: onPressed,
      ),
    );
  }
}

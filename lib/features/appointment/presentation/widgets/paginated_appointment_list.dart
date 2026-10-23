import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../controllers/appointment_controller.dart';
import '../states/appointment_state.dart';
import 'appointment_card.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../../../shared/widgets/layout/page_navigator.dart';
import '../../../../shared/utils/failure_message.dart';

/// One appointment list with loading, empty and page controls.
class PaginatedAppointmentList extends StatelessWidget {
  final PaginatedAppointmentState state;
  final bool isPast;
  final String emptyMessage;
  final AppointmentFilter filter;
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
        child: AppText.bodyMedium(state.error!.message(context.l10n) ?? ''),
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
                  AppColors.slate300,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              AppText.bodyMedium(
                emptyMessage,
                color: AppColors.slate400,
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
        _PaginationControls(
            state: state, filter: filter, controller: controller),
      ],
    );
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls(
      {required this.state, required this.filter, required this.controller});

  final PaginatedAppointmentState state;
  final AppointmentFilter filter;
  final AppointmentController controller;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: PageNavigator(
          page: state.page,
          totalPages: state.totalPages,
          onPage: (page) =>
              controller.fetchAppointments(filter: filter, page: page),
        ),
      );
}

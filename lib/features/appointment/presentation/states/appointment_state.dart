import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/appointment_entity.dart';

part 'appointment_state.freezed.dart';

/// One paged appointment list.
@freezed
abstract class PaginatedAppointmentState with _$PaginatedAppointmentState {
  const factory PaginatedAppointmentState({
    @Default([]) List<AppointmentEntity> items,
    @Default(false) bool isLoading,
    AppFailure? error,
    @Default(1) int page,
    @Default(1) int totalPages,
  }) = _PaginatedAppointmentState;
}

/// The appointments screen and the home "next visit" card.
@freezed
abstract class AppointmentState with _$AppointmentState {
  const factory AppointmentState({
    @Default(PaginatedAppointmentState())
    PaginatedAppointmentState upcomingState,
    @Default(PaginatedAppointmentState()) PaginatedAppointmentState pastState,
    AppointmentEntity? nearestAppointment,
    @Default(false) bool isNearestLoading,
    AppFailure? nearestError,
  }) = _AppointmentState;
}

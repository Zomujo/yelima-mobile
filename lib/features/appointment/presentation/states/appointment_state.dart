import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/appointment_entity.dart';

part 'appointment_state.freezed.dart';

@freezed
abstract class PaginatedAppointmentState with _$PaginatedAppointmentState {
  const factory PaginatedAppointmentState({
    @Default([]) List<AppointmentEntity> items,
    @Default(false) bool isLoading,
    @Default(false) bool isFetchingMore,
    String? error,
    @Default(1) int page,
    @Default(1) int totalPages,
    @Default(true) bool hasNextPage,
  }) = _PaginatedAppointmentState;
}

@freezed
abstract class AppointmentState with _$AppointmentState {
  const factory AppointmentState({
    @Default(PaginatedAppointmentState()) PaginatedAppointmentState upcomingState,
    @Default(PaginatedAppointmentState()) PaginatedAppointmentState pastState,
    AppointmentEntity? nearestAppointment,
    @Default(false) bool isNearestLoading,
    String? nearestError,
    @Default(false) bool isRequestingAppointment,
  }) = _AppointmentState;

  const AppointmentState._();
}

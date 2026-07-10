import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../states/appointment_state.dart';

class AppointmentController extends ChangeNotifier with SafeNotifier {
  final AppointmentRepository repository;

  StreamSubscription<List<AppointmentEntity>>? _appointmentSubscription;

  AppointmentController({required this.repository}) {
    _initSubscription();
  }

  AppointmentState _state = const AppointmentState();
  AppointmentState get state => _state;

  set state(AppointmentState value) {
    _state = value;
    notifyListeners();
  }

  void _initSubscription() {
    _appointmentSubscription = repository.watchAppointments().listen((appointments) {
      final now = DateTime.now();

      final upcoming = appointments.where((a) => a.appointmentDate.isAfter(now)).toList();
      final past = appointments.where((a) => a.appointmentDate.isBefore(now)).toList();

      state = state.copyWith(
        upcomingState: state.upcomingState.copyWith(
          items: upcoming,
          isLoading: false,
        ),
        pastState: state.pastState.copyWith(
          items: past,
          isLoading: false,
        ),
      );
    });
  }

  @override
  void dispose() {
    _appointmentSubscription?.cancel();
    super.dispose();
  }

  final int pageSize = 10;

  Future<void> fetchNearestAppointment() async {
    state = state.copyWith(isNearestLoading: true, nearestError: null);

    final result = await repository.getNearestAppointment();

    result.fold(
      (error) {
        state = state.copyWith(isNearestLoading: false, nearestError: error);
      },
      (data) {
        state = state.copyWith(isNearestLoading: false, nearestAppointment: data);
      },
    );
  }

  Future<void> fetchAppointments({
    required String filter,
    bool isRefresh = false,
    int? targetPage,
  }) async {
    final isUpcoming = filter == 'upcoming';
    var currentPaginatedState = isUpcoming ? state.upcomingState : state.pastState;

    final pageToFetch = targetPage ?? (isRefresh ? 1 : currentPaginatedState.page + 1);

    if (isRefresh || targetPage != null) {
      currentPaginatedState = currentPaginatedState.copyWith(isLoading: true);
    } else {
      if (!currentPaginatedState.hasNextPage || currentPaginatedState.isLoading || currentPaginatedState.isFetchingMore) {
        return;
      }
      currentPaginatedState = currentPaginatedState.copyWith(isFetchingMore: true);
    }

    _updatePaginatedState(filter, currentPaginatedState);

    final result = await repository.getAppointments(
      page: pageToFetch,
      pageSize: pageSize,
      filter: filter,
    );

    result.fold(
      (error) {
        _updatePaginatedState(
          filter,
          currentPaginatedState.copyWith(
            isLoading: false,
            isFetchingMore: false,
            error: error,
          ),
        );
      },
      (data) {
        final newItems = (isRefresh || targetPage != null) ? data.rows : [...currentPaginatedState.items, ...data.rows];

        _updatePaginatedState(
          filter,
          currentPaginatedState.copyWith(
            error: null,
            isLoading: false,
            isFetchingMore: false,
            items: newItems,
            page: data.page,
            totalPages: data.totalPages,
            hasNextPage: data.nextPage != null,
          ),
        );
      },
    );
  }

  Future<bool> requestAppointment({
    required BuildContext context,
    required String note,
  }) async {
    if (state.isRequestingAppointment) return false;

    state = state.copyWith(isRequestingAppointment: true);

    final result = await repository.requestAppointment(note: note);

    state = state.copyWith(isRequestingAppointment: false);

    return result.fold(
      (error) {
        if (context.mounted) {
          context.showErrorSnackBar(error);
        }
        return false;
      },
      (_) {
        if (context.mounted) {
          context.showSuccessSnackBar('Appointment request sent successfully!');
        }
        return true;
      },
    );
  }

  void _updatePaginatedState(String filter, PaginatedAppointmentState newState) {
    if (filter == 'upcoming') {
      state = state.copyWith(upcomingState: newState);
    } else {
      state = state.copyWith(pastState: newState);
    }
  }

  void initialize() {
    fetchNearestAppointment();
    fetchAppointments(filter: 'upcoming', isRefresh: true);
    fetchAppointments(filter: 'past', isRefresh: true);
  }
}

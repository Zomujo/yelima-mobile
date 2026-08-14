import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../states/appointment_state.dart';

class AppointmentController extends ChangeNotifier with SafeNotifier {
  // --------------------------------------------------------------------------
  // |                                  State & Dependencies      |
  // --------------------------------------------------------------------------

  final AppointmentRepository repository;
  int _nearestFetchStamp = 0;

  // --------------------------------------------------------------------------
  // |                               Initialization & Lifecycle                |
  // --------------------------------------------------------------------------

  AppointmentController({required this.repository});

  AppointmentState _state = const AppointmentState();
  AppointmentState get state => _state;

  set state(AppointmentState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  /// Initializes the controller by fetching paginated appointments.
  void initialize() {
    fetchAppointments(filter: 'upcoming', isRefresh: true);
    fetchAppointments(filter: 'past', isRefresh: true);
  }


  // --------------------------------------------------------------------------
  // |                                   Actions & Methods                     |
  // --------------------------------------------------------------------------

  /// Fetches the single nearest upcoming appointment for the dashboard.

  Future<void> fetchNearestAppointment() async {
    final stamp = ++_nearestFetchStamp;
    
    // 1. Instantly display local cache if available
    final localResult = await repository.getLocalNearestAppointment();
    localResult.fold(
      (_) {},
      (data) {
        if (data != null) {
          state = state.copyWith(nearestAppointment: data, isNearestLoading: false);
        }
      },
    );

    // Show loading only if we have no local data
    if (state.nearestAppointment == null) {
      state = state.copyWith(isNearestLoading: true, nearestError: null);
    }

    // 2. Fetch from remote in background
    final result = await repository.getNearestAppointment();

    if (stamp != _nearestFetchStamp) return;

    state = result.fold(
      (error) => state.copyWith(isNearestLoading: false, nearestError: error),
      (data) =>
          state.copyWith(isNearestLoading: false, nearestAppointment: data, nearestError: null),
    );
  }

  /// Fetches a paginated list of appointments filtered by 'upcoming' or 'past'.
  Future<void> fetchAppointments({
    required String filter,
    bool isRefresh = false,
    int? targetPage,
  }) async {
    final isUpcoming = filter == 'upcoming';
    var currentPaginatedState =
        isUpcoming ? state.upcomingState : state.pastState;

    final pageToFetch =
        targetPage ?? (isRefresh ? 1 : currentPaginatedState.page + 1);

    if (isRefresh || targetPage != null) {
      // 1. SWR: Try to load instantly from local DB
      final localRes = await repository.getLocalAppointments(
          page: pageToFetch, pageSize: 3, filter: filter);
          
      localRes.fold((_) {}, (data) {
        if (data.rows.isNotEmpty) {
          currentPaginatedState = currentPaginatedState.copyWith(
            items: data.rows,
            isLoading: false,
            page: data.page,
            totalPages: data.totalPages,
            hasNextPage: data.nextPage != null,
          );
          _updatePaginatedState(filter, currentPaginatedState);
        }
      });

      // Show loading spinner only if local DB was empty
      if (currentPaginatedState.items.isEmpty) {
        currentPaginatedState = currentPaginatedState.copyWith(isLoading: true);
        _updatePaginatedState(filter, currentPaginatedState);
      }
    } else {
      if (!currentPaginatedState.hasNextPage ||
          currentPaginatedState.isLoading ||
          currentPaginatedState.isFetchingMore) {
        return;
      }
      currentPaginatedState =
          currentPaginatedState.copyWith(isFetchingMore: true);
      _updatePaginatedState(filter, currentPaginatedState);
    }

    final result = await repository.getAppointments(
      page: pageToFetch,
      pageSize: 3,
      filter: filter,
    );

    result.fold(
      (error) {
        _updatePaginatedState(
          filter,
          currentPaginatedState.copyWith(
              isLoading: false, isFetchingMore: false, error: error),
        );
      },
      (data) {
        final newItems = (isRefresh || targetPage != null)
            ? data.rows
            : [...currentPaginatedState.items, ...data.rows];

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

  /// Submits a request for a new appointment with the provided note.
  Future<String?> requestAppointment({required String note}) async {
    if (state.isRequestingAppointment) return null;

    state = state.copyWith(isRequestingAppointment: true);
    final result = await repository.requestAppointment(note: note);
    state = state.copyWith(isRequestingAppointment: false);

    return result.fold((error) => error, (_) => null);
  }

  void _updatePaginatedState(
      String filter, PaginatedAppointmentState newState) {
    if (filter == 'upcoming') {
      state = state.copyWith(upcomingState: newState);
    } else {
      state = state.copyWith(pastState: newState);
    }
  }
}

import 'package:flutter/foundation.dart';

import '../../../../core/utils/safe_notifier.dart';
import '../../../../core/utils/session_scoped.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_list_response.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../states/appointment_state.dart';

/// Upcoming and past appointment pages, and the next appointment for home.
class AppointmentController extends ChangeNotifier
    with SafeNotifier, SessionScoped {
  AppointmentController({required this.repository}) {
    joinSession();
  }

  final AppointmentRepository repository;
  static const _pageSize = 3;

  /// Bumped per nearest-appointment fetch, so a slow old answer can't win.
  int _nearestStamp = 0;

  AppointmentState _state = const AppointmentState();
  AppointmentState get state => _state;
  set state(AppointmentState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  @override
  String get serviceName => 'AppointmentController';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async => state = const AppointmentState();

  /// Loads the first page of both lists.
  void initialize() {
    for (final filter in AppointmentFilter.values) {
      fetchAppointments(filter: filter);
    }
  }

  /// Shows the cached next appointment at once, then the server's.
  Future<void> fetchNearestAppointment() async {
    final stamp = ++_nearestStamp;
    final cached =
        (await repository.getCachedNearestAppointment()).toNullable();
    state = state.copyWith(
        nearestAppointment: cached ?? state.nearestAppointment,
        isNearestLoading: (cached ?? state.nearestAppointment) == null);

    final result = await repository.getNearestAppointment();
    if (stamp != _nearestStamp) return;
    state = result.fold(
      (f) => state.copyWith(isNearestLoading: false, nearestError: f),
      (a) => state.copyWith(
          isNearestLoading: false, nearestAppointment: a, nearestError: null),
    );
  }

  /// Shows [page] of [filter]'s list: the phone's copy first, then the server's.
  Future<void> fetchAppointments(
      {required AppointmentFilter filter, int page = 1}) async {
    final cached = (await repository.getCachedAppointments(
            page: page, pageSize: _pageSize, filter: filter))
        .toNullable();
    if (cached != null && cached.rows.isNotEmpty) {
      _show(filter, cached);
    } else if (_list(filter).items.isEmpty) {
      _set(filter, _list(filter).copyWith(isLoading: true));
    }

    (await repository.getAppointments(
            page: page, pageSize: _pageSize, filter: filter))
        .fold(
      (f) => _set(filter, _list(filter).copyWith(isLoading: false, error: f)),
      (data) => _show(filter, data),
    );
  }

  PaginatedAppointmentState _list(AppointmentFilter filter) =>
      filter == AppointmentFilter.upcoming
          ? state.upcomingState
          : state.pastState;

  void _show(AppointmentFilter filter, AppointmentListResponse data) => _set(
      filter,
      PaginatedAppointmentState(
          items: data.rows, page: data.page, totalPages: data.totalPages));

  void _set(AppointmentFilter filter, PaginatedAppointmentState list) =>
      state = filter == AppointmentFilter.upcoming
          ? state.copyWith(upcomingState: list)
          : state.copyWith(pastState: list);
}

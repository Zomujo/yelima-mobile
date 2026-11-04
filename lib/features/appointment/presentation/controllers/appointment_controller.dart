import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/follow_session.dart';
import '../../appointment_providers.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_list_response.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../states/appointment_state.dart';

part 'appointment_controller.g.dart';

/// Upcoming and past appointment pages, and the next appointment for home.
@Riverpod(keepAlive: true)
class AppointmentController extends _$AppointmentController {
  late AppointmentRepository _repository;
  static const _pageSize = 3;

  /// Bumped per nearest-appointment fetch, so a slow old answer can't win.
  int _nearestStamp = 0;

  @override
  AppointmentState build() {
    _repository = ref.watch(appointmentRepositoryProvider);
    followSession(ref, onEnd: () => state = const AppointmentState());
    Future.microtask(initialize);
    return const AppointmentState();
  }

  @override
  bool updateShouldNotify(AppointmentState previous, AppointmentState next) =>
      previous != next;

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
        (await _repository.getCachedNearestAppointment()).toNullable();
    state = state.copyWith(
        nearestAppointment: cached ?? state.nearestAppointment,
        isNearestLoading: (cached ?? state.nearestAppointment) == null);

    final result = await _repository.getNearestAppointment();
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
    final cached = (await _repository.getCachedAppointments(
            page: page, pageSize: _pageSize, filter: filter))
        .toNullable();
    if (cached != null && cached.rows.isNotEmpty) {
      _show(filter, cached);
    } else if (_list(filter).items.isEmpty) {
      _set(filter, _list(filter).copyWith(isLoading: true));
    }

    (await _repository.getAppointments(
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

// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginatedAppointmentState {
  List<AppointmentEntity> get items;
  bool get isLoading;
  AppFailure? get error;
  int get page;
  int get totalPages;

  /// Create a copy of PaginatedAppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PaginatedAppointmentStateCopyWith<PaginatedAppointmentState> get copyWith =>
      _$PaginatedAppointmentStateCopyWithImpl<PaginatedAppointmentState>(
          this as PaginatedAppointmentState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PaginatedAppointmentState &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(items),
      isLoading,
      error,
      page,
      totalPages);

  @override
  String toString() {
    return 'PaginatedAppointmentState(items: $items, isLoading: $isLoading, error: $error, page: $page, totalPages: $totalPages)';
  }
}

/// @nodoc
abstract mixin class $PaginatedAppointmentStateCopyWith<$Res> {
  factory $PaginatedAppointmentStateCopyWith(PaginatedAppointmentState value,
          $Res Function(PaginatedAppointmentState) _then) =
      _$PaginatedAppointmentStateCopyWithImpl;
  @useResult
  $Res call(
      {List<AppointmentEntity> items,
      bool isLoading,
      AppFailure? error,
      int page,
      int totalPages});
}

/// @nodoc
class _$PaginatedAppointmentStateCopyWithImpl<$Res>
    implements $PaginatedAppointmentStateCopyWith<$Res> {
  _$PaginatedAppointmentStateCopyWithImpl(this._self, this._then);

  final PaginatedAppointmentState _self;
  final $Res Function(PaginatedAppointmentState) _then;

  /// Create a copy of PaginatedAppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? page = null,
    Object? totalPages = null,
  }) {
    return _then(_self.copyWith(
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<AppointmentEntity>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _PaginatedAppointmentState implements PaginatedAppointmentState {
  const _PaginatedAppointmentState(
      {final List<AppointmentEntity> items = const [],
      this.isLoading = false,
      this.error,
      this.page = 1,
      this.totalPages = 1})
      : _items = items;

  final List<AppointmentEntity> _items;
  @override
  @JsonKey()
  List<AppointmentEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final AppFailure? error;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int totalPages;

  /// Create a copy of PaginatedAppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PaginatedAppointmentStateCopyWith<_PaginatedAppointmentState>
      get copyWith =>
          __$PaginatedAppointmentStateCopyWithImpl<_PaginatedAppointmentState>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PaginatedAppointmentState &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      isLoading,
      error,
      page,
      totalPages);

  @override
  String toString() {
    return 'PaginatedAppointmentState(items: $items, isLoading: $isLoading, error: $error, page: $page, totalPages: $totalPages)';
  }
}

/// @nodoc
abstract mixin class _$PaginatedAppointmentStateCopyWith<$Res>
    implements $PaginatedAppointmentStateCopyWith<$Res> {
  factory _$PaginatedAppointmentStateCopyWith(_PaginatedAppointmentState value,
          $Res Function(_PaginatedAppointmentState) _then) =
      __$PaginatedAppointmentStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<AppointmentEntity> items,
      bool isLoading,
      AppFailure? error,
      int page,
      int totalPages});
}

/// @nodoc
class __$PaginatedAppointmentStateCopyWithImpl<$Res>
    implements _$PaginatedAppointmentStateCopyWith<$Res> {
  __$PaginatedAppointmentStateCopyWithImpl(this._self, this._then);

  final _PaginatedAppointmentState _self;
  final $Res Function(_PaginatedAppointmentState) _then;

  /// Create a copy of PaginatedAppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? items = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? page = null,
    Object? totalPages = null,
  }) {
    return _then(_PaginatedAppointmentState(
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<AppointmentEntity>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$AppointmentState {
  PaginatedAppointmentState get upcomingState;
  PaginatedAppointmentState get pastState;
  AppointmentEntity? get nearestAppointment;
  bool get isNearestLoading;
  AppFailure? get nearestError;

  /// Create a copy of AppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppointmentStateCopyWith<AppointmentState> get copyWith =>
      _$AppointmentStateCopyWithImpl<AppointmentState>(
          this as AppointmentState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppointmentState &&
            (identical(other.upcomingState, upcomingState) ||
                other.upcomingState == upcomingState) &&
            (identical(other.pastState, pastState) ||
                other.pastState == pastState) &&
            (identical(other.nearestAppointment, nearestAppointment) ||
                other.nearestAppointment == nearestAppointment) &&
            (identical(other.isNearestLoading, isNearestLoading) ||
                other.isNearestLoading == isNearestLoading) &&
            (identical(other.nearestError, nearestError) ||
                other.nearestError == nearestError));
  }

  @override
  int get hashCode => Object.hash(runtimeType, upcomingState, pastState,
      nearestAppointment, isNearestLoading, nearestError);

  @override
  String toString() {
    return 'AppointmentState(upcomingState: $upcomingState, pastState: $pastState, nearestAppointment: $nearestAppointment, isNearestLoading: $isNearestLoading, nearestError: $nearestError)';
  }
}

/// @nodoc
abstract mixin class $AppointmentStateCopyWith<$Res> {
  factory $AppointmentStateCopyWith(
          AppointmentState value, $Res Function(AppointmentState) _then) =
      _$AppointmentStateCopyWithImpl;
  @useResult
  $Res call(
      {PaginatedAppointmentState upcomingState,
      PaginatedAppointmentState pastState,
      AppointmentEntity? nearestAppointment,
      bool isNearestLoading,
      AppFailure? nearestError});

  $PaginatedAppointmentStateCopyWith<$Res> get upcomingState;
  $PaginatedAppointmentStateCopyWith<$Res> get pastState;
}

/// @nodoc
class _$AppointmentStateCopyWithImpl<$Res>
    implements $AppointmentStateCopyWith<$Res> {
  _$AppointmentStateCopyWithImpl(this._self, this._then);

  final AppointmentState _self;
  final $Res Function(AppointmentState) _then;

  /// Create a copy of AppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upcomingState = null,
    Object? pastState = null,
    Object? nearestAppointment = freezed,
    Object? isNearestLoading = null,
    Object? nearestError = freezed,
  }) {
    return _then(_self.copyWith(
      upcomingState: null == upcomingState
          ? _self.upcomingState
          : upcomingState // ignore: cast_nullable_to_non_nullable
              as PaginatedAppointmentState,
      pastState: null == pastState
          ? _self.pastState
          : pastState // ignore: cast_nullable_to_non_nullable
              as PaginatedAppointmentState,
      nearestAppointment: freezed == nearestAppointment
          ? _self.nearestAppointment
          : nearestAppointment // ignore: cast_nullable_to_non_nullable
              as AppointmentEntity?,
      isNearestLoading: null == isNearestLoading
          ? _self.isNearestLoading
          : isNearestLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      nearestError: freezed == nearestError
          ? _self.nearestError
          : nearestError // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
    ));
  }

  /// Create a copy of AppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginatedAppointmentStateCopyWith<$Res> get upcomingState {
    return $PaginatedAppointmentStateCopyWith<$Res>(_self.upcomingState,
        (value) {
      return _then(_self.copyWith(upcomingState: value));
    });
  }

  /// Create a copy of AppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginatedAppointmentStateCopyWith<$Res> get pastState {
    return $PaginatedAppointmentStateCopyWith<$Res>(_self.pastState, (value) {
      return _then(_self.copyWith(pastState: value));
    });
  }
}

/// @nodoc

class _AppointmentState implements AppointmentState {
  const _AppointmentState(
      {this.upcomingState = const PaginatedAppointmentState(),
      this.pastState = const PaginatedAppointmentState(),
      this.nearestAppointment,
      this.isNearestLoading = false,
      this.nearestError});

  @override
  @JsonKey()
  final PaginatedAppointmentState upcomingState;
  @override
  @JsonKey()
  final PaginatedAppointmentState pastState;
  @override
  final AppointmentEntity? nearestAppointment;
  @override
  @JsonKey()
  final bool isNearestLoading;
  @override
  final AppFailure? nearestError;

  /// Create a copy of AppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppointmentStateCopyWith<_AppointmentState> get copyWith =>
      __$AppointmentStateCopyWithImpl<_AppointmentState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppointmentState &&
            (identical(other.upcomingState, upcomingState) ||
                other.upcomingState == upcomingState) &&
            (identical(other.pastState, pastState) ||
                other.pastState == pastState) &&
            (identical(other.nearestAppointment, nearestAppointment) ||
                other.nearestAppointment == nearestAppointment) &&
            (identical(other.isNearestLoading, isNearestLoading) ||
                other.isNearestLoading == isNearestLoading) &&
            (identical(other.nearestError, nearestError) ||
                other.nearestError == nearestError));
  }

  @override
  int get hashCode => Object.hash(runtimeType, upcomingState, pastState,
      nearestAppointment, isNearestLoading, nearestError);

  @override
  String toString() {
    return 'AppointmentState(upcomingState: $upcomingState, pastState: $pastState, nearestAppointment: $nearestAppointment, isNearestLoading: $isNearestLoading, nearestError: $nearestError)';
  }
}

/// @nodoc
abstract mixin class _$AppointmentStateCopyWith<$Res>
    implements $AppointmentStateCopyWith<$Res> {
  factory _$AppointmentStateCopyWith(
          _AppointmentState value, $Res Function(_AppointmentState) _then) =
      __$AppointmentStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {PaginatedAppointmentState upcomingState,
      PaginatedAppointmentState pastState,
      AppointmentEntity? nearestAppointment,
      bool isNearestLoading,
      AppFailure? nearestError});

  @override
  $PaginatedAppointmentStateCopyWith<$Res> get upcomingState;
  @override
  $PaginatedAppointmentStateCopyWith<$Res> get pastState;
}

/// @nodoc
class __$AppointmentStateCopyWithImpl<$Res>
    implements _$AppointmentStateCopyWith<$Res> {
  __$AppointmentStateCopyWithImpl(this._self, this._then);

  final _AppointmentState _self;
  final $Res Function(_AppointmentState) _then;

  /// Create a copy of AppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? upcomingState = null,
    Object? pastState = null,
    Object? nearestAppointment = freezed,
    Object? isNearestLoading = null,
    Object? nearestError = freezed,
  }) {
    return _then(_AppointmentState(
      upcomingState: null == upcomingState
          ? _self.upcomingState
          : upcomingState // ignore: cast_nullable_to_non_nullable
              as PaginatedAppointmentState,
      pastState: null == pastState
          ? _self.pastState
          : pastState // ignore: cast_nullable_to_non_nullable
              as PaginatedAppointmentState,
      nearestAppointment: freezed == nearestAppointment
          ? _self.nearestAppointment
          : nearestAppointment // ignore: cast_nullable_to_non_nullable
              as AppointmentEntity?,
      isNearestLoading: null == isNearestLoading
          ? _self.isNearestLoading
          : isNearestLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      nearestError: freezed == nearestError
          ? _self.nearestError
          : nearestError // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
    ));
  }

  /// Create a copy of AppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginatedAppointmentStateCopyWith<$Res> get upcomingState {
    return $PaginatedAppointmentStateCopyWith<$Res>(_self.upcomingState,
        (value) {
      return _then(_self.copyWith(upcomingState: value));
    });
  }

  /// Create a copy of AppointmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginatedAppointmentStateCopyWith<$Res> get pastState {
    return $PaginatedAppointmentStateCopyWith<$Res>(_self.pastState, (value) {
      return _then(_self.copyWith(pastState: value));
    });
  }
}

// dart format on

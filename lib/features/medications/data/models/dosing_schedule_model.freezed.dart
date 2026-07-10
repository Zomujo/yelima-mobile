// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dosing_schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleTimeModel {
  int get hour;
  int get minutes;
  String get timeDesignators;

  /// Create a copy of ScheduleTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleTimeModelCopyWith<ScheduleTimeModel> get copyWith =>
      _$ScheduleTimeModelCopyWithImpl<ScheduleTimeModel>(
          this as ScheduleTimeModel, _$identity);

  /// Serializes this ScheduleTimeModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleTimeModel &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minutes, minutes) || other.minutes == minutes) &&
            (identical(other.timeDesignators, timeDesignators) ||
                other.timeDesignators == timeDesignators));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minutes, timeDesignators);

  @override
  String toString() {
    return 'ScheduleTimeModel(hour: $hour, minutes: $minutes, timeDesignators: $timeDesignators)';
  }
}

/// @nodoc
abstract mixin class $ScheduleTimeModelCopyWith<$Res> {
  factory $ScheduleTimeModelCopyWith(
          ScheduleTimeModel value, $Res Function(ScheduleTimeModel) _then) =
      _$ScheduleTimeModelCopyWithImpl;
  @useResult
  $Res call({int hour, int minutes, String timeDesignators});
}

/// @nodoc
class _$ScheduleTimeModelCopyWithImpl<$Res>
    implements $ScheduleTimeModelCopyWith<$Res> {
  _$ScheduleTimeModelCopyWithImpl(this._self, this._then);

  final ScheduleTimeModel _self;
  final $Res Function(ScheduleTimeModel) _then;

  /// Create a copy of ScheduleTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minutes = null,
    Object? timeDesignators = null,
  }) {
    return _then(_self.copyWith(
      hour: null == hour
          ? _self.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minutes: null == minutes
          ? _self.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int,
      timeDesignators: null == timeDesignators
          ? _self.timeDesignators
          : timeDesignators // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ScheduleTimeModel implements ScheduleTimeModel {
  const _ScheduleTimeModel(
      {required this.hour,
      required this.minutes,
      required this.timeDesignators});
  factory _ScheduleTimeModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleTimeModelFromJson(json);

  @override
  final int hour;
  @override
  final int minutes;
  @override
  final String timeDesignators;

  /// Create a copy of ScheduleTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleTimeModelCopyWith<_ScheduleTimeModel> get copyWith =>
      __$ScheduleTimeModelCopyWithImpl<_ScheduleTimeModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScheduleTimeModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleTimeModel &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minutes, minutes) || other.minutes == minutes) &&
            (identical(other.timeDesignators, timeDesignators) ||
                other.timeDesignators == timeDesignators));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minutes, timeDesignators);

  @override
  String toString() {
    return 'ScheduleTimeModel(hour: $hour, minutes: $minutes, timeDesignators: $timeDesignators)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleTimeModelCopyWith<$Res>
    implements $ScheduleTimeModelCopyWith<$Res> {
  factory _$ScheduleTimeModelCopyWith(
          _ScheduleTimeModel value, $Res Function(_ScheduleTimeModel) _then) =
      __$ScheduleTimeModelCopyWithImpl;
  @override
  @useResult
  $Res call({int hour, int minutes, String timeDesignators});
}

/// @nodoc
class __$ScheduleTimeModelCopyWithImpl<$Res>
    implements _$ScheduleTimeModelCopyWith<$Res> {
  __$ScheduleTimeModelCopyWithImpl(this._self, this._then);

  final _ScheduleTimeModel _self;
  final $Res Function(_ScheduleTimeModel) _then;

  /// Create a copy of ScheduleTimeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? hour = null,
    Object? minutes = null,
    Object? timeDesignators = null,
  }) {
    return _then(_ScheduleTimeModel(
      hour: null == hour
          ? _self.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minutes: null == minutes
          ? _self.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int,
      timeDesignators: null == timeDesignators
          ? _self.timeDesignators
          : timeDesignators // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ScheduleQuantityModel {
  int get value;
  String get unit;

  /// Create a copy of ScheduleQuantityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleQuantityModelCopyWith<ScheduleQuantityModel> get copyWith =>
      _$ScheduleQuantityModelCopyWithImpl<ScheduleQuantityModel>(
          this as ScheduleQuantityModel, _$identity);

  /// Serializes this ScheduleQuantityModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleQuantityModel &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, unit);

  @override
  String toString() {
    return 'ScheduleQuantityModel(value: $value, unit: $unit)';
  }
}

/// @nodoc
abstract mixin class $ScheduleQuantityModelCopyWith<$Res> {
  factory $ScheduleQuantityModelCopyWith(ScheduleQuantityModel value,
          $Res Function(ScheduleQuantityModel) _then) =
      _$ScheduleQuantityModelCopyWithImpl;
  @useResult
  $Res call({int value, String unit});
}

/// @nodoc
class _$ScheduleQuantityModelCopyWithImpl<$Res>
    implements $ScheduleQuantityModelCopyWith<$Res> {
  _$ScheduleQuantityModelCopyWithImpl(this._self, this._then);

  final ScheduleQuantityModel _self;
  final $Res Function(ScheduleQuantityModel) _then;

  /// Create a copy of ScheduleQuantityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? unit = null,
  }) {
    return _then(_self.copyWith(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ScheduleQuantityModel implements ScheduleQuantityModel {
  const _ScheduleQuantityModel({required this.value, required this.unit});
  factory _ScheduleQuantityModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleQuantityModelFromJson(json);

  @override
  final int value;
  @override
  final String unit;

  /// Create a copy of ScheduleQuantityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleQuantityModelCopyWith<_ScheduleQuantityModel> get copyWith =>
      __$ScheduleQuantityModelCopyWithImpl<_ScheduleQuantityModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScheduleQuantityModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleQuantityModel &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, unit);

  @override
  String toString() {
    return 'ScheduleQuantityModel(value: $value, unit: $unit)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleQuantityModelCopyWith<$Res>
    implements $ScheduleQuantityModelCopyWith<$Res> {
  factory _$ScheduleQuantityModelCopyWith(_ScheduleQuantityModel value,
          $Res Function(_ScheduleQuantityModel) _then) =
      __$ScheduleQuantityModelCopyWithImpl;
  @override
  @useResult
  $Res call({int value, String unit});
}

/// @nodoc
class __$ScheduleQuantityModelCopyWithImpl<$Res>
    implements _$ScheduleQuantityModelCopyWith<$Res> {
  __$ScheduleQuantityModelCopyWithImpl(this._self, this._then);

  final _ScheduleQuantityModel _self;
  final $Res Function(_ScheduleQuantityModel) _then;

  /// Create a copy of ScheduleQuantityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
    Object? unit = null,
  }) {
    return _then(_ScheduleQuantityModel(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$DosingScheduleModel {
  ScheduleTimeModel get time;
  ScheduleQuantityModel get quantity;

  /// Create a copy of DosingScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DosingScheduleModelCopyWith<DosingScheduleModel> get copyWith =>
      _$DosingScheduleModelCopyWithImpl<DosingScheduleModel>(
          this as DosingScheduleModel, _$identity);

  /// Serializes this DosingScheduleModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DosingScheduleModel &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, time, quantity);

  @override
  String toString() {
    return 'DosingScheduleModel(time: $time, quantity: $quantity)';
  }
}

/// @nodoc
abstract mixin class $DosingScheduleModelCopyWith<$Res> {
  factory $DosingScheduleModelCopyWith(
          DosingScheduleModel value, $Res Function(DosingScheduleModel) _then) =
      _$DosingScheduleModelCopyWithImpl;
  @useResult
  $Res call({ScheduleTimeModel time, ScheduleQuantityModel quantity});

  $ScheduleTimeModelCopyWith<$Res> get time;
  $ScheduleQuantityModelCopyWith<$Res> get quantity;
}

/// @nodoc
class _$DosingScheduleModelCopyWithImpl<$Res>
    implements $DosingScheduleModelCopyWith<$Res> {
  _$DosingScheduleModelCopyWithImpl(this._self, this._then);

  final DosingScheduleModel _self;
  final $Res Function(DosingScheduleModel) _then;

  /// Create a copy of DosingScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? quantity = null,
  }) {
    return _then(_self.copyWith(
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as ScheduleTimeModel,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as ScheduleQuantityModel,
    ));
  }

  /// Create a copy of DosingScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleTimeModelCopyWith<$Res> get time {
    return $ScheduleTimeModelCopyWith<$Res>(_self.time, (value) {
      return _then(_self.copyWith(time: value));
    });
  }

  /// Create a copy of DosingScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleQuantityModelCopyWith<$Res> get quantity {
    return $ScheduleQuantityModelCopyWith<$Res>(_self.quantity, (value) {
      return _then(_self.copyWith(quantity: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _DosingScheduleModel implements DosingScheduleModel {
  const _DosingScheduleModel({required this.time, required this.quantity});
  factory _DosingScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$DosingScheduleModelFromJson(json);

  @override
  final ScheduleTimeModel time;
  @override
  final ScheduleQuantityModel quantity;

  /// Create a copy of DosingScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DosingScheduleModelCopyWith<_DosingScheduleModel> get copyWith =>
      __$DosingScheduleModelCopyWithImpl<_DosingScheduleModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DosingScheduleModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DosingScheduleModel &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, time, quantity);

  @override
  String toString() {
    return 'DosingScheduleModel(time: $time, quantity: $quantity)';
  }
}

/// @nodoc
abstract mixin class _$DosingScheduleModelCopyWith<$Res>
    implements $DosingScheduleModelCopyWith<$Res> {
  factory _$DosingScheduleModelCopyWith(_DosingScheduleModel value,
          $Res Function(_DosingScheduleModel) _then) =
      __$DosingScheduleModelCopyWithImpl;
  @override
  @useResult
  $Res call({ScheduleTimeModel time, ScheduleQuantityModel quantity});

  @override
  $ScheduleTimeModelCopyWith<$Res> get time;
  @override
  $ScheduleQuantityModelCopyWith<$Res> get quantity;
}

/// @nodoc
class __$DosingScheduleModelCopyWithImpl<$Res>
    implements _$DosingScheduleModelCopyWith<$Res> {
  __$DosingScheduleModelCopyWithImpl(this._self, this._then);

  final _DosingScheduleModel _self;
  final $Res Function(_DosingScheduleModel) _then;

  /// Create a copy of DosingScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? time = null,
    Object? quantity = null,
  }) {
    return _then(_DosingScheduleModel(
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as ScheduleTimeModel,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as ScheduleQuantityModel,
    ));
  }

  /// Create a copy of DosingScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleTimeModelCopyWith<$Res> get time {
    return $ScheduleTimeModelCopyWith<$Res>(_self.time, (value) {
      return _then(_self.copyWith(time: value));
    });
  }

  /// Create a copy of DosingScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleQuantityModelCopyWith<$Res> get quantity {
    return $ScheduleQuantityModelCopyWith<$Res>(_self.quantity, (value) {
      return _then(_self.copyWith(quantity: value));
    });
  }
}

// dart format on

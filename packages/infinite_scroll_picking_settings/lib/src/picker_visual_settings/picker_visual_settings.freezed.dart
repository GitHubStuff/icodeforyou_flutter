// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'picker_visual_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PickerVisualSettings {

/// Visual and behavioral configuration for the wheel itself.
 WheelSettings get wheel;/// Index in the consumer-supplied `items` list to land on when the
/// picker first builds. Bounds-checked against `items.length` by the
/// mapper at runtime, since `items` doesn't live here.
 int get startingIndex;/// Corner radius of the outer frame surrounding the label and wheel.
 double get frameBorderRadius;/// Horizontal padding inside the outer frame.
 double get frameHorizontalPadding;/// Vertical padding inside the outer frame.
 double get frameVerticalPadding;
/// Create a copy of PickerVisualSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickerVisualSettingsCopyWith<PickerVisualSettings> get copyWith => _$PickerVisualSettingsCopyWithImpl<PickerVisualSettings>(this as PickerVisualSettings, _$identity);

  /// Serializes this PickerVisualSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PickerVisualSettings&&(identical(other.wheel, wheel) || other.wheel == wheel)&&(identical(other.startingIndex, startingIndex) || other.startingIndex == startingIndex)&&(identical(other.frameBorderRadius, frameBorderRadius) || other.frameBorderRadius == frameBorderRadius)&&(identical(other.frameHorizontalPadding, frameHorizontalPadding) || other.frameHorizontalPadding == frameHorizontalPadding)&&(identical(other.frameVerticalPadding, frameVerticalPadding) || other.frameVerticalPadding == frameVerticalPadding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wheel,startingIndex,frameBorderRadius,frameHorizontalPadding,frameVerticalPadding);

@override
String toString() {
  return 'PickerVisualSettings(wheel: $wheel, startingIndex: $startingIndex, frameBorderRadius: $frameBorderRadius, frameHorizontalPadding: $frameHorizontalPadding, frameVerticalPadding: $frameVerticalPadding)';
}


}

/// @nodoc
abstract mixin class $PickerVisualSettingsCopyWith<$Res>  {
  factory $PickerVisualSettingsCopyWith(PickerVisualSettings value, $Res Function(PickerVisualSettings) _then) = _$PickerVisualSettingsCopyWithImpl;
@useResult
$Res call({
 WheelSettings wheel, int startingIndex, double frameBorderRadius, double frameHorizontalPadding, double frameVerticalPadding
});


$WheelSettingsCopyWith<$Res> get wheel;

}
/// @nodoc
class _$PickerVisualSettingsCopyWithImpl<$Res>
    implements $PickerVisualSettingsCopyWith<$Res> {
  _$PickerVisualSettingsCopyWithImpl(this._self, this._then);

  final PickerVisualSettings _self;
  final $Res Function(PickerVisualSettings) _then;

/// Create a copy of PickerVisualSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wheel = null,Object? startingIndex = null,Object? frameBorderRadius = null,Object? frameHorizontalPadding = null,Object? frameVerticalPadding = null,}) {
  return _then(_self.copyWith(
wheel: null == wheel ? _self.wheel : wheel // ignore: cast_nullable_to_non_nullable
as WheelSettings,startingIndex: null == startingIndex ? _self.startingIndex : startingIndex // ignore: cast_nullable_to_non_nullable
as int,frameBorderRadius: null == frameBorderRadius ? _self.frameBorderRadius : frameBorderRadius // ignore: cast_nullable_to_non_nullable
as double,frameHorizontalPadding: null == frameHorizontalPadding ? _self.frameHorizontalPadding : frameHorizontalPadding // ignore: cast_nullable_to_non_nullable
as double,frameVerticalPadding: null == frameVerticalPadding ? _self.frameVerticalPadding : frameVerticalPadding // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of PickerVisualSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WheelSettingsCopyWith<$Res> get wheel {
  
  return $WheelSettingsCopyWith<$Res>(_self.wheel, (value) {
    return _then(_self.copyWith(wheel: value));
  });
}
}


/// Adds pattern-matching-related methods to [PickerVisualSettings].
extension PickerVisualSettingsPatterns on PickerVisualSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PickerVisualSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PickerVisualSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PickerVisualSettings value)  $default,){
final _that = this;
switch (_that) {
case _PickerVisualSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PickerVisualSettings value)?  $default,){
final _that = this;
switch (_that) {
case _PickerVisualSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WheelSettings wheel,  int startingIndex,  double frameBorderRadius,  double frameHorizontalPadding,  double frameVerticalPadding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PickerVisualSettings() when $default != null:
return $default(_that.wheel,_that.startingIndex,_that.frameBorderRadius,_that.frameHorizontalPadding,_that.frameVerticalPadding);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WheelSettings wheel,  int startingIndex,  double frameBorderRadius,  double frameHorizontalPadding,  double frameVerticalPadding)  $default,) {final _that = this;
switch (_that) {
case _PickerVisualSettings():
return $default(_that.wheel,_that.startingIndex,_that.frameBorderRadius,_that.frameHorizontalPadding,_that.frameVerticalPadding);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WheelSettings wheel,  int startingIndex,  double frameBorderRadius,  double frameHorizontalPadding,  double frameVerticalPadding)?  $default,) {final _that = this;
switch (_that) {
case _PickerVisualSettings() when $default != null:
return $default(_that.wheel,_that.startingIndex,_that.frameBorderRadius,_that.frameHorizontalPadding,_that.frameVerticalPadding);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PickerVisualSettings implements PickerVisualSettings {
  const _PickerVisualSettings({this.wheel = const WheelSettings(), this.startingIndex = 0, this.frameBorderRadius = 8.0, this.frameHorizontalPadding = 12.0, this.frameVerticalPadding = 6.0}): assert(startingIndex >= 0, 'startingIndex must be >= 0'),assert(frameBorderRadius >= 0, 'frameBorderRadius must be >= 0'),assert(frameHorizontalPadding >= 0, 'frameHorizontalPadding must be >= 0'),assert(frameVerticalPadding >= 0, 'frameVerticalPadding must be >= 0');
  factory _PickerVisualSettings.fromJson(Map<String, dynamic> json) => _$PickerVisualSettingsFromJson(json);

/// Visual and behavioral configuration for the wheel itself.
@override@JsonKey() final  WheelSettings wheel;
/// Index in the consumer-supplied `items` list to land on when the
/// picker first builds. Bounds-checked against `items.length` by the
/// mapper at runtime, since `items` doesn't live here.
@override@JsonKey() final  int startingIndex;
/// Corner radius of the outer frame surrounding the label and wheel.
@override@JsonKey() final  double frameBorderRadius;
/// Horizontal padding inside the outer frame.
@override@JsonKey() final  double frameHorizontalPadding;
/// Vertical padding inside the outer frame.
@override@JsonKey() final  double frameVerticalPadding;

/// Create a copy of PickerVisualSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PickerVisualSettingsCopyWith<_PickerVisualSettings> get copyWith => __$PickerVisualSettingsCopyWithImpl<_PickerVisualSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PickerVisualSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PickerVisualSettings&&(identical(other.wheel, wheel) || other.wheel == wheel)&&(identical(other.startingIndex, startingIndex) || other.startingIndex == startingIndex)&&(identical(other.frameBorderRadius, frameBorderRadius) || other.frameBorderRadius == frameBorderRadius)&&(identical(other.frameHorizontalPadding, frameHorizontalPadding) || other.frameHorizontalPadding == frameHorizontalPadding)&&(identical(other.frameVerticalPadding, frameVerticalPadding) || other.frameVerticalPadding == frameVerticalPadding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wheel,startingIndex,frameBorderRadius,frameHorizontalPadding,frameVerticalPadding);

@override
String toString() {
  return 'PickerVisualSettings(wheel: $wheel, startingIndex: $startingIndex, frameBorderRadius: $frameBorderRadius, frameHorizontalPadding: $frameHorizontalPadding, frameVerticalPadding: $frameVerticalPadding)';
}


}

/// @nodoc
abstract mixin class _$PickerVisualSettingsCopyWith<$Res> implements $PickerVisualSettingsCopyWith<$Res> {
  factory _$PickerVisualSettingsCopyWith(_PickerVisualSettings value, $Res Function(_PickerVisualSettings) _then) = __$PickerVisualSettingsCopyWithImpl;
@override @useResult
$Res call({
 WheelSettings wheel, int startingIndex, double frameBorderRadius, double frameHorizontalPadding, double frameVerticalPadding
});


@override $WheelSettingsCopyWith<$Res> get wheel;

}
/// @nodoc
class __$PickerVisualSettingsCopyWithImpl<$Res>
    implements _$PickerVisualSettingsCopyWith<$Res> {
  __$PickerVisualSettingsCopyWithImpl(this._self, this._then);

  final _PickerVisualSettings _self;
  final $Res Function(_PickerVisualSettings) _then;

/// Create a copy of PickerVisualSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wheel = null,Object? startingIndex = null,Object? frameBorderRadius = null,Object? frameHorizontalPadding = null,Object? frameVerticalPadding = null,}) {
  return _then(_PickerVisualSettings(
wheel: null == wheel ? _self.wheel : wheel // ignore: cast_nullable_to_non_nullable
as WheelSettings,startingIndex: null == startingIndex ? _self.startingIndex : startingIndex // ignore: cast_nullable_to_non_nullable
as int,frameBorderRadius: null == frameBorderRadius ? _self.frameBorderRadius : frameBorderRadius // ignore: cast_nullable_to_non_nullable
as double,frameHorizontalPadding: null == frameHorizontalPadding ? _self.frameHorizontalPadding : frameHorizontalPadding // ignore: cast_nullable_to_non_nullable
as double,frameVerticalPadding: null == frameVerticalPadding ? _self.frameVerticalPadding : frameVerticalPadding // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of PickerVisualSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WheelSettingsCopyWith<$Res> get wheel {
  
  return $WheelSettingsCopyWith<$Res>(_self.wheel, (value) {
    return _then(_self.copyWith(wheel: value));
  });
}
}

// dart format on

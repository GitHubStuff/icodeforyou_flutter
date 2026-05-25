// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wheel_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WheelSettings {

/// Height of a single item slot inside the wheel.
 double get itemExtent;/// Thickness of the top and bottom selection band lines.
 double get dividerThickness;/// Horizontal inset of the selection band lines from the wheel edges.
 double get dividerInset;/// Width of the wheel column.
 double get wheelWidth;/// Total height of the wheel (must accommodate the magnified center
/// item plus fade gradient at top and bottom).
 double get wheelHeight;/// `ListWheelScrollView.diameterRatio` — controls the 3D perspective.
/// Larger values make the wheel appear flatter; smaller values make
/// it appear more curved.
 double get perspectiveDiameter;/// Scale factor applied to the centered (selected) item.
 double get magnification;/// Corner radius of the wheel's container.
 double get wheelBorderRadius;/// Whether to draw a border around the wheel container.
 bool get showBorder;/// Debounce window for the picker's `onItemSelected` callback.
///
/// Defaults to [Duration.zero], which fires the callback synchronously
/// on every tick. Set to a non-zero duration to coalesce rapid scroll
/// changes — useful when the consumer performs expensive work in the
/// callback.
 Duration get selectionDebounce;
/// Create a copy of WheelSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WheelSettingsCopyWith<WheelSettings> get copyWith => _$WheelSettingsCopyWithImpl<WheelSettings>(this as WheelSettings, _$identity);

  /// Serializes this WheelSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WheelSettings&&(identical(other.itemExtent, itemExtent) || other.itemExtent == itemExtent)&&(identical(other.dividerThickness, dividerThickness) || other.dividerThickness == dividerThickness)&&(identical(other.dividerInset, dividerInset) || other.dividerInset == dividerInset)&&(identical(other.wheelWidth, wheelWidth) || other.wheelWidth == wheelWidth)&&(identical(other.wheelHeight, wheelHeight) || other.wheelHeight == wheelHeight)&&(identical(other.perspectiveDiameter, perspectiveDiameter) || other.perspectiveDiameter == perspectiveDiameter)&&(identical(other.magnification, magnification) || other.magnification == magnification)&&(identical(other.wheelBorderRadius, wheelBorderRadius) || other.wheelBorderRadius == wheelBorderRadius)&&(identical(other.showBorder, showBorder) || other.showBorder == showBorder)&&(identical(other.selectionDebounce, selectionDebounce) || other.selectionDebounce == selectionDebounce));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemExtent,dividerThickness,dividerInset,wheelWidth,wheelHeight,perspectiveDiameter,magnification,wheelBorderRadius,showBorder,selectionDebounce);

@override
String toString() {
  return 'WheelSettings(itemExtent: $itemExtent, dividerThickness: $dividerThickness, dividerInset: $dividerInset, wheelWidth: $wheelWidth, wheelHeight: $wheelHeight, perspectiveDiameter: $perspectiveDiameter, magnification: $magnification, wheelBorderRadius: $wheelBorderRadius, showBorder: $showBorder, selectionDebounce: $selectionDebounce)';
}


}

/// @nodoc
abstract mixin class $WheelSettingsCopyWith<$Res>  {
  factory $WheelSettingsCopyWith(WheelSettings value, $Res Function(WheelSettings) _then) = _$WheelSettingsCopyWithImpl;
@useResult
$Res call({
 double itemExtent, double dividerThickness, double dividerInset, double wheelWidth, double wheelHeight, double perspectiveDiameter, double magnification, double wheelBorderRadius, bool showBorder, Duration selectionDebounce
});




}
/// @nodoc
class _$WheelSettingsCopyWithImpl<$Res>
    implements $WheelSettingsCopyWith<$Res> {
  _$WheelSettingsCopyWithImpl(this._self, this._then);

  final WheelSettings _self;
  final $Res Function(WheelSettings) _then;

/// Create a copy of WheelSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemExtent = null,Object? dividerThickness = null,Object? dividerInset = null,Object? wheelWidth = null,Object? wheelHeight = null,Object? perspectiveDiameter = null,Object? magnification = null,Object? wheelBorderRadius = null,Object? showBorder = null,Object? selectionDebounce = null,}) {
  return _then(_self.copyWith(
itemExtent: null == itemExtent ? _self.itemExtent : itemExtent // ignore: cast_nullable_to_non_nullable
as double,dividerThickness: null == dividerThickness ? _self.dividerThickness : dividerThickness // ignore: cast_nullable_to_non_nullable
as double,dividerInset: null == dividerInset ? _self.dividerInset : dividerInset // ignore: cast_nullable_to_non_nullable
as double,wheelWidth: null == wheelWidth ? _self.wheelWidth : wheelWidth // ignore: cast_nullable_to_non_nullable
as double,wheelHeight: null == wheelHeight ? _self.wheelHeight : wheelHeight // ignore: cast_nullable_to_non_nullable
as double,perspectiveDiameter: null == perspectiveDiameter ? _self.perspectiveDiameter : perspectiveDiameter // ignore: cast_nullable_to_non_nullable
as double,magnification: null == magnification ? _self.magnification : magnification // ignore: cast_nullable_to_non_nullable
as double,wheelBorderRadius: null == wheelBorderRadius ? _self.wheelBorderRadius : wheelBorderRadius // ignore: cast_nullable_to_non_nullable
as double,showBorder: null == showBorder ? _self.showBorder : showBorder // ignore: cast_nullable_to_non_nullable
as bool,selectionDebounce: null == selectionDebounce ? _self.selectionDebounce : selectionDebounce // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [WheelSettings].
extension WheelSettingsPatterns on WheelSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WheelSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WheelSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WheelSettings value)  $default,){
final _that = this;
switch (_that) {
case _WheelSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WheelSettings value)?  $default,){
final _that = this;
switch (_that) {
case _WheelSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double itemExtent,  double dividerThickness,  double dividerInset,  double wheelWidth,  double wheelHeight,  double perspectiveDiameter,  double magnification,  double wheelBorderRadius,  bool showBorder,  Duration selectionDebounce)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WheelSettings() when $default != null:
return $default(_that.itemExtent,_that.dividerThickness,_that.dividerInset,_that.wheelWidth,_that.wheelHeight,_that.perspectiveDiameter,_that.magnification,_that.wheelBorderRadius,_that.showBorder,_that.selectionDebounce);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double itemExtent,  double dividerThickness,  double dividerInset,  double wheelWidth,  double wheelHeight,  double perspectiveDiameter,  double magnification,  double wheelBorderRadius,  bool showBorder,  Duration selectionDebounce)  $default,) {final _that = this;
switch (_that) {
case _WheelSettings():
return $default(_that.itemExtent,_that.dividerThickness,_that.dividerInset,_that.wheelWidth,_that.wheelHeight,_that.perspectiveDiameter,_that.magnification,_that.wheelBorderRadius,_that.showBorder,_that.selectionDebounce);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double itemExtent,  double dividerThickness,  double dividerInset,  double wheelWidth,  double wheelHeight,  double perspectiveDiameter,  double magnification,  double wheelBorderRadius,  bool showBorder,  Duration selectionDebounce)?  $default,) {final _that = this;
switch (_that) {
case _WheelSettings() when $default != null:
return $default(_that.itemExtent,_that.dividerThickness,_that.dividerInset,_that.wheelWidth,_that.wheelHeight,_that.perspectiveDiameter,_that.magnification,_that.wheelBorderRadius,_that.showBorder,_that.selectionDebounce);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WheelSettings implements WheelSettings {
  const _WheelSettings({this.itemExtent = 24.0, this.dividerThickness = 1.0, this.dividerInset = 4.0, this.wheelWidth = 56.0, this.wheelHeight = 48.0, this.perspectiveDiameter = 1.2, this.magnification = 1.25, this.wheelBorderRadius = 8.0, this.showBorder = true, this.selectionDebounce = Duration.zero}): assert(wheelHeight >= itemExtent * 1.1, 'wheelHeight must be at least 1.1x itemExtent to leave room for the selection band and fade.'),assert(magnification >= 1.0, 'magnification must be >= 1.0'),assert(perspectiveDiameter > 0, 'perspectiveDiameter must be > 0'),assert(dividerThickness >= 0, 'dividerThickness must be >= 0'),assert(dividerInset >= 0, 'dividerInset must be >= 0');
  factory _WheelSettings.fromJson(Map<String, dynamic> json) => _$WheelSettingsFromJson(json);

/// Height of a single item slot inside the wheel.
@override@JsonKey() final  double itemExtent;
/// Thickness of the top and bottom selection band lines.
@override@JsonKey() final  double dividerThickness;
/// Horizontal inset of the selection band lines from the wheel edges.
@override@JsonKey() final  double dividerInset;
/// Width of the wheel column.
@override@JsonKey() final  double wheelWidth;
/// Total height of the wheel (must accommodate the magnified center
/// item plus fade gradient at top and bottom).
@override@JsonKey() final  double wheelHeight;
/// `ListWheelScrollView.diameterRatio` — controls the 3D perspective.
/// Larger values make the wheel appear flatter; smaller values make
/// it appear more curved.
@override@JsonKey() final  double perspectiveDiameter;
/// Scale factor applied to the centered (selected) item.
@override@JsonKey() final  double magnification;
/// Corner radius of the wheel's container.
@override@JsonKey() final  double wheelBorderRadius;
/// Whether to draw a border around the wheel container.
@override@JsonKey() final  bool showBorder;
/// Debounce window for the picker's `onItemSelected` callback.
///
/// Defaults to [Duration.zero], which fires the callback synchronously
/// on every tick. Set to a non-zero duration to coalesce rapid scroll
/// changes — useful when the consumer performs expensive work in the
/// callback.
@override@JsonKey() final  Duration selectionDebounce;

/// Create a copy of WheelSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WheelSettingsCopyWith<_WheelSettings> get copyWith => __$WheelSettingsCopyWithImpl<_WheelSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WheelSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WheelSettings&&(identical(other.itemExtent, itemExtent) || other.itemExtent == itemExtent)&&(identical(other.dividerThickness, dividerThickness) || other.dividerThickness == dividerThickness)&&(identical(other.dividerInset, dividerInset) || other.dividerInset == dividerInset)&&(identical(other.wheelWidth, wheelWidth) || other.wheelWidth == wheelWidth)&&(identical(other.wheelHeight, wheelHeight) || other.wheelHeight == wheelHeight)&&(identical(other.perspectiveDiameter, perspectiveDiameter) || other.perspectiveDiameter == perspectiveDiameter)&&(identical(other.magnification, magnification) || other.magnification == magnification)&&(identical(other.wheelBorderRadius, wheelBorderRadius) || other.wheelBorderRadius == wheelBorderRadius)&&(identical(other.showBorder, showBorder) || other.showBorder == showBorder)&&(identical(other.selectionDebounce, selectionDebounce) || other.selectionDebounce == selectionDebounce));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemExtent,dividerThickness,dividerInset,wheelWidth,wheelHeight,perspectiveDiameter,magnification,wheelBorderRadius,showBorder,selectionDebounce);

@override
String toString() {
  return 'WheelSettings(itemExtent: $itemExtent, dividerThickness: $dividerThickness, dividerInset: $dividerInset, wheelWidth: $wheelWidth, wheelHeight: $wheelHeight, perspectiveDiameter: $perspectiveDiameter, magnification: $magnification, wheelBorderRadius: $wheelBorderRadius, showBorder: $showBorder, selectionDebounce: $selectionDebounce)';
}


}

/// @nodoc
abstract mixin class _$WheelSettingsCopyWith<$Res> implements $WheelSettingsCopyWith<$Res> {
  factory _$WheelSettingsCopyWith(_WheelSettings value, $Res Function(_WheelSettings) _then) = __$WheelSettingsCopyWithImpl;
@override @useResult
$Res call({
 double itemExtent, double dividerThickness, double dividerInset, double wheelWidth, double wheelHeight, double perspectiveDiameter, double magnification, double wheelBorderRadius, bool showBorder, Duration selectionDebounce
});




}
/// @nodoc
class __$WheelSettingsCopyWithImpl<$Res>
    implements _$WheelSettingsCopyWith<$Res> {
  __$WheelSettingsCopyWithImpl(this._self, this._then);

  final _WheelSettings _self;
  final $Res Function(_WheelSettings) _then;

/// Create a copy of WheelSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemExtent = null,Object? dividerThickness = null,Object? dividerInset = null,Object? wheelWidth = null,Object? wheelHeight = null,Object? perspectiveDiameter = null,Object? magnification = null,Object? wheelBorderRadius = null,Object? showBorder = null,Object? selectionDebounce = null,}) {
  return _then(_WheelSettings(
itemExtent: null == itemExtent ? _self.itemExtent : itemExtent // ignore: cast_nullable_to_non_nullable
as double,dividerThickness: null == dividerThickness ? _self.dividerThickness : dividerThickness // ignore: cast_nullable_to_non_nullable
as double,dividerInset: null == dividerInset ? _self.dividerInset : dividerInset // ignore: cast_nullable_to_non_nullable
as double,wheelWidth: null == wheelWidth ? _self.wheelWidth : wheelWidth // ignore: cast_nullable_to_non_nullable
as double,wheelHeight: null == wheelHeight ? _self.wheelHeight : wheelHeight // ignore: cast_nullable_to_non_nullable
as double,perspectiveDiameter: null == perspectiveDiameter ? _self.perspectiveDiameter : perspectiveDiameter // ignore: cast_nullable_to_non_nullable
as double,magnification: null == magnification ? _self.magnification : magnification // ignore: cast_nullable_to_non_nullable
as double,wheelBorderRadius: null == wheelBorderRadius ? _self.wheelBorderRadius : wheelBorderRadius // ignore: cast_nullable_to_non_nullable
as double,showBorder: null == showBorder ? _self.showBorder : showBorder // ignore: cast_nullable_to_non_nullable
as bool,selectionDebounce: null == selectionDebounce ? _self.selectionDebounce : selectionDebounce // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on

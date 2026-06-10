// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dom.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SinceWhen {

 int get identity; String get caption; int get timestamp;
/// Create a copy of SinceWhen
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SinceWhenCopyWith<SinceWhen> get copyWith => _$SinceWhenCopyWithImpl<SinceWhen>(this as SinceWhen, _$identity);

  /// Serializes this SinceWhen to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SinceWhen&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identity,caption,timestamp);

@override
String toString() {
  return 'SinceWhen(identity: $identity, caption: $caption, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $SinceWhenCopyWith<$Res>  {
  factory $SinceWhenCopyWith(SinceWhen value, $Res Function(SinceWhen) _then) = _$SinceWhenCopyWithImpl;
@useResult
$Res call({
 int identity, String caption, int timestamp
});




}
/// @nodoc
class _$SinceWhenCopyWithImpl<$Res>
    implements $SinceWhenCopyWith<$Res> {
  _$SinceWhenCopyWithImpl(this._self, this._then);

  final SinceWhen _self;
  final $Res Function(SinceWhen) _then;

/// Create a copy of SinceWhen
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identity = null,Object? caption = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as int,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SinceWhen].
extension SinceWhenPatterns on SinceWhen {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SinceWhen value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SinceWhen() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SinceWhen value)  $default,){
final _that = this;
switch (_that) {
case _SinceWhen():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SinceWhen value)?  $default,){
final _that = this;
switch (_that) {
case _SinceWhen() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int identity,  String caption,  int timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SinceWhen() when $default != null:
return $default(_that.identity,_that.caption,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int identity,  String caption,  int timestamp)  $default,) {final _that = this;
switch (_that) {
case _SinceWhen():
return $default(_that.identity,_that.caption,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int identity,  String caption,  int timestamp)?  $default,) {final _that = this;
switch (_that) {
case _SinceWhen() when $default != null:
return $default(_that.identity,_that.caption,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SinceWhen implements SinceWhen {
  const _SinceWhen({required this.identity, required this.caption, this.timestamp = 0});
  factory _SinceWhen.fromJson(Map<String, dynamic> json) => _$SinceWhenFromJson(json);

@override final  int identity;
@override final  String caption;
@override@JsonKey() final  int timestamp;

/// Create a copy of SinceWhen
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SinceWhenCopyWith<_SinceWhen> get copyWith => __$SinceWhenCopyWithImpl<_SinceWhen>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SinceWhenToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SinceWhen&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identity,caption,timestamp);

@override
String toString() {
  return 'SinceWhen(identity: $identity, caption: $caption, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$SinceWhenCopyWith<$Res> implements $SinceWhenCopyWith<$Res> {
  factory _$SinceWhenCopyWith(_SinceWhen value, $Res Function(_SinceWhen) _then) = __$SinceWhenCopyWithImpl;
@override @useResult
$Res call({
 int identity, String caption, int timestamp
});




}
/// @nodoc
class __$SinceWhenCopyWithImpl<$Res>
    implements _$SinceWhenCopyWith<$Res> {
  __$SinceWhenCopyWithImpl(this._self, this._then);

  final _SinceWhen _self;
  final $Res Function(_SinceWhen) _then;

/// Create a copy of SinceWhen
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identity = null,Object? caption = null,Object? timestamp = null,}) {
  return _then(_SinceWhen(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as int,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SinceWhenUser {

 int get userId; String get email; String get name; List<int> get sinceWhenList;
/// Create a copy of SinceWhenUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SinceWhenUserCopyWith<SinceWhenUser> get copyWith => _$SinceWhenUserCopyWithImpl<SinceWhenUser>(this as SinceWhenUser, _$identity);

  /// Serializes this SinceWhenUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SinceWhenUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.sinceWhenList, sinceWhenList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,email,name,const DeepCollectionEquality().hash(sinceWhenList));

@override
String toString() {
  return 'SinceWhenUser(userId: $userId, email: $email, name: $name, sinceWhenList: $sinceWhenList)';
}


}

/// @nodoc
abstract mixin class $SinceWhenUserCopyWith<$Res>  {
  factory $SinceWhenUserCopyWith(SinceWhenUser value, $Res Function(SinceWhenUser) _then) = _$SinceWhenUserCopyWithImpl;
@useResult
$Res call({
 int userId, String email, String name, List<int> sinceWhenList
});




}
/// @nodoc
class _$SinceWhenUserCopyWithImpl<$Res>
    implements $SinceWhenUserCopyWith<$Res> {
  _$SinceWhenUserCopyWithImpl(this._self, this._then);

  final SinceWhenUser _self;
  final $Res Function(SinceWhenUser) _then;

/// Create a copy of SinceWhenUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? email = null,Object? name = null,Object? sinceWhenList = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sinceWhenList: null == sinceWhenList ? _self.sinceWhenList : sinceWhenList // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [SinceWhenUser].
extension SinceWhenUserPatterns on SinceWhenUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SinceWhenUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SinceWhenUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SinceWhenUser value)  $default,){
final _that = this;
switch (_that) {
case _SinceWhenUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SinceWhenUser value)?  $default,){
final _that = this;
switch (_that) {
case _SinceWhenUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int userId,  String email,  String name,  List<int> sinceWhenList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SinceWhenUser() when $default != null:
return $default(_that.userId,_that.email,_that.name,_that.sinceWhenList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int userId,  String email,  String name,  List<int> sinceWhenList)  $default,) {final _that = this;
switch (_that) {
case _SinceWhenUser():
return $default(_that.userId,_that.email,_that.name,_that.sinceWhenList);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int userId,  String email,  String name,  List<int> sinceWhenList)?  $default,) {final _that = this;
switch (_that) {
case _SinceWhenUser() when $default != null:
return $default(_that.userId,_that.email,_that.name,_that.sinceWhenList);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SinceWhenUser implements SinceWhenUser {
  const _SinceWhenUser({required this.userId, required this.email, required this.name, final  List<int> sinceWhenList = const []}): _sinceWhenList = sinceWhenList;
  factory _SinceWhenUser.fromJson(Map<String, dynamic> json) => _$SinceWhenUserFromJson(json);

@override final  int userId;
@override final  String email;
@override final  String name;
 final  List<int> _sinceWhenList;
@override@JsonKey() List<int> get sinceWhenList {
  if (_sinceWhenList is EqualUnmodifiableListView) return _sinceWhenList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sinceWhenList);
}


/// Create a copy of SinceWhenUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SinceWhenUserCopyWith<_SinceWhenUser> get copyWith => __$SinceWhenUserCopyWithImpl<_SinceWhenUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SinceWhenUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SinceWhenUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._sinceWhenList, _sinceWhenList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,email,name,const DeepCollectionEquality().hash(_sinceWhenList));

@override
String toString() {
  return 'SinceWhenUser(userId: $userId, email: $email, name: $name, sinceWhenList: $sinceWhenList)';
}


}

/// @nodoc
abstract mixin class _$SinceWhenUserCopyWith<$Res> implements $SinceWhenUserCopyWith<$Res> {
  factory _$SinceWhenUserCopyWith(_SinceWhenUser value, $Res Function(_SinceWhenUser) _then) = __$SinceWhenUserCopyWithImpl;
@override @useResult
$Res call({
 int userId, String email, String name, List<int> sinceWhenList
});




}
/// @nodoc
class __$SinceWhenUserCopyWithImpl<$Res>
    implements _$SinceWhenUserCopyWith<$Res> {
  __$SinceWhenUserCopyWithImpl(this._self, this._then);

  final _SinceWhenUser _self;
  final $Res Function(_SinceWhenUser) _then;

/// Create a copy of SinceWhenUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? email = null,Object? name = null,Object? sinceWhenList = null,}) {
  return _then(_SinceWhenUser(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sinceWhenList: null == sinceWhenList ? _self._sinceWhenList : sinceWhenList // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$SinceWhenParent {

 List<SinceWhen> get sinceWhen; List<SinceWhenUser> get users;
/// Create a copy of SinceWhenParent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SinceWhenParentCopyWith<SinceWhenParent> get copyWith => _$SinceWhenParentCopyWithImpl<SinceWhenParent>(this as SinceWhenParent, _$identity);

  /// Serializes this SinceWhenParent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SinceWhenParent&&const DeepCollectionEquality().equals(other.sinceWhen, sinceWhen)&&const DeepCollectionEquality().equals(other.users, users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sinceWhen),const DeepCollectionEquality().hash(users));

@override
String toString() {
  return 'SinceWhenParent(sinceWhen: $sinceWhen, users: $users)';
}


}

/// @nodoc
abstract mixin class $SinceWhenParentCopyWith<$Res>  {
  factory $SinceWhenParentCopyWith(SinceWhenParent value, $Res Function(SinceWhenParent) _then) = _$SinceWhenParentCopyWithImpl;
@useResult
$Res call({
 List<SinceWhen> sinceWhen, List<SinceWhenUser> users
});




}
/// @nodoc
class _$SinceWhenParentCopyWithImpl<$Res>
    implements $SinceWhenParentCopyWith<$Res> {
  _$SinceWhenParentCopyWithImpl(this._self, this._then);

  final SinceWhenParent _self;
  final $Res Function(SinceWhenParent) _then;

/// Create a copy of SinceWhenParent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sinceWhen = null,Object? users = null,}) {
  return _then(_self.copyWith(
sinceWhen: null == sinceWhen ? _self.sinceWhen : sinceWhen // ignore: cast_nullable_to_non_nullable
as List<SinceWhen>,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<SinceWhenUser>,
  ));
}

}


/// Adds pattern-matching-related methods to [SinceWhenParent].
extension SinceWhenParentPatterns on SinceWhenParent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SinceWhenParent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SinceWhenParent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SinceWhenParent value)  $default,){
final _that = this;
switch (_that) {
case _SinceWhenParent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SinceWhenParent value)?  $default,){
final _that = this;
switch (_that) {
case _SinceWhenParent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SinceWhen> sinceWhen,  List<SinceWhenUser> users)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SinceWhenParent() when $default != null:
return $default(_that.sinceWhen,_that.users);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SinceWhen> sinceWhen,  List<SinceWhenUser> users)  $default,) {final _that = this;
switch (_that) {
case _SinceWhenParent():
return $default(_that.sinceWhen,_that.users);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SinceWhen> sinceWhen,  List<SinceWhenUser> users)?  $default,) {final _that = this;
switch (_that) {
case _SinceWhenParent() when $default != null:
return $default(_that.sinceWhen,_that.users);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SinceWhenParent implements SinceWhenParent {
  const _SinceWhenParent({final  List<SinceWhen> sinceWhen = const [], final  List<SinceWhenUser> users = const []}): _sinceWhen = sinceWhen,_users = users;
  factory _SinceWhenParent.fromJson(Map<String, dynamic> json) => _$SinceWhenParentFromJson(json);

 final  List<SinceWhen> _sinceWhen;
@override@JsonKey() List<SinceWhen> get sinceWhen {
  if (_sinceWhen is EqualUnmodifiableListView) return _sinceWhen;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sinceWhen);
}

 final  List<SinceWhenUser> _users;
@override@JsonKey() List<SinceWhenUser> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}


/// Create a copy of SinceWhenParent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SinceWhenParentCopyWith<_SinceWhenParent> get copyWith => __$SinceWhenParentCopyWithImpl<_SinceWhenParent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SinceWhenParentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SinceWhenParent&&const DeepCollectionEquality().equals(other._sinceWhen, _sinceWhen)&&const DeepCollectionEquality().equals(other._users, _users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sinceWhen),const DeepCollectionEquality().hash(_users));

@override
String toString() {
  return 'SinceWhenParent(sinceWhen: $sinceWhen, users: $users)';
}


}

/// @nodoc
abstract mixin class _$SinceWhenParentCopyWith<$Res> implements $SinceWhenParentCopyWith<$Res> {
  factory _$SinceWhenParentCopyWith(_SinceWhenParent value, $Res Function(_SinceWhenParent) _then) = __$SinceWhenParentCopyWithImpl;
@override @useResult
$Res call({
 List<SinceWhen> sinceWhen, List<SinceWhenUser> users
});




}
/// @nodoc
class __$SinceWhenParentCopyWithImpl<$Res>
    implements _$SinceWhenParentCopyWith<$Res> {
  __$SinceWhenParentCopyWithImpl(this._self, this._then);

  final _SinceWhenParent _self;
  final $Res Function(_SinceWhenParent) _then;

/// Create a copy of SinceWhenParent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sinceWhen = null,Object? users = null,}) {
  return _then(_SinceWhenParent(
sinceWhen: null == sinceWhen ? _self._sinceWhen : sinceWhen // ignore: cast_nullable_to_non_nullable
as List<SinceWhen>,users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<SinceWhenUser>,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'since_when_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SinceWhenRecord {

/// Auto-increment ID for internal database use.
 int get id;/// Unique identifier for this record (ISO8601 UTC).
 String get createdTimeStamp;/// Reference to parent record's [createdTimeStamp], if any.
 String? get parentTimeStamp;/// Timestamp of last review (ISO8601 UTC).
 String get reviewedTimeStamp;/// Timestamp of last edit (ISO8601 UTC).
 String get editedTimeStamp;/// Optional metadata timestamp (ISO8601 UTC).
 String? get metaTimeStamp;/// Metadata string (guideline: ~100 characters).
 String get metaData;/// User-defined ordering within sibling records.
/// Parent records have sequenceNumber 0.
 int get sequenceNumber;/// Primary data content (unlimited length).
 String get dataString;/// Free-form category classification.
 String get category;/// List of tags associated with this record.
 List<String> get tags;
/// Create a copy of SinceWhenRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SinceWhenRecordCopyWith<SinceWhenRecord> get copyWith => _$SinceWhenRecordCopyWithImpl<SinceWhenRecord>(this as SinceWhenRecord, _$identity);

  /// Serializes this SinceWhenRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SinceWhenRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.createdTimeStamp, createdTimeStamp) || other.createdTimeStamp == createdTimeStamp)&&(identical(other.parentTimeStamp, parentTimeStamp) || other.parentTimeStamp == parentTimeStamp)&&(identical(other.reviewedTimeStamp, reviewedTimeStamp) || other.reviewedTimeStamp == reviewedTimeStamp)&&(identical(other.editedTimeStamp, editedTimeStamp) || other.editedTimeStamp == editedTimeStamp)&&(identical(other.metaTimeStamp, metaTimeStamp) || other.metaTimeStamp == metaTimeStamp)&&(identical(other.metaData, metaData) || other.metaData == metaData)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.dataString, dataString) || other.dataString == dataString)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdTimeStamp,parentTimeStamp,reviewedTimeStamp,editedTimeStamp,metaTimeStamp,metaData,sequenceNumber,dataString,category,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'SinceWhenRecord(id: $id, createdTimeStamp: $createdTimeStamp, parentTimeStamp: $parentTimeStamp, reviewedTimeStamp: $reviewedTimeStamp, editedTimeStamp: $editedTimeStamp, metaTimeStamp: $metaTimeStamp, metaData: $metaData, sequenceNumber: $sequenceNumber, dataString: $dataString, category: $category, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $SinceWhenRecordCopyWith<$Res>  {
  factory $SinceWhenRecordCopyWith(SinceWhenRecord value, $Res Function(SinceWhenRecord) _then) = _$SinceWhenRecordCopyWithImpl;
@useResult
$Res call({
 int id, String createdTimeStamp, String? parentTimeStamp, String reviewedTimeStamp, String editedTimeStamp, String? metaTimeStamp, String metaData, int sequenceNumber, String dataString, String category, List<String> tags
});




}
/// @nodoc
class _$SinceWhenRecordCopyWithImpl<$Res>
    implements $SinceWhenRecordCopyWith<$Res> {
  _$SinceWhenRecordCopyWithImpl(this._self, this._then);

  final SinceWhenRecord _self;
  final $Res Function(SinceWhenRecord) _then;

/// Create a copy of SinceWhenRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdTimeStamp = null,Object? parentTimeStamp = freezed,Object? reviewedTimeStamp = null,Object? editedTimeStamp = null,Object? metaTimeStamp = freezed,Object? metaData = null,Object? sequenceNumber = null,Object? dataString = null,Object? category = null,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdTimeStamp: null == createdTimeStamp ? _self.createdTimeStamp : createdTimeStamp // ignore: cast_nullable_to_non_nullable
as String,parentTimeStamp: freezed == parentTimeStamp ? _self.parentTimeStamp : parentTimeStamp // ignore: cast_nullable_to_non_nullable
as String?,reviewedTimeStamp: null == reviewedTimeStamp ? _self.reviewedTimeStamp : reviewedTimeStamp // ignore: cast_nullable_to_non_nullable
as String,editedTimeStamp: null == editedTimeStamp ? _self.editedTimeStamp : editedTimeStamp // ignore: cast_nullable_to_non_nullable
as String,metaTimeStamp: freezed == metaTimeStamp ? _self.metaTimeStamp : metaTimeStamp // ignore: cast_nullable_to_non_nullable
as String?,metaData: null == metaData ? _self.metaData : metaData // ignore: cast_nullable_to_non_nullable
as String,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,dataString: null == dataString ? _self.dataString : dataString // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SinceWhenRecord].
extension SinceWhenRecordPatterns on SinceWhenRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SinceWhenRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SinceWhenRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SinceWhenRecord value)  $default,){
final _that = this;
switch (_that) {
case _SinceWhenRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SinceWhenRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SinceWhenRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String createdTimeStamp,  String? parentTimeStamp,  String reviewedTimeStamp,  String editedTimeStamp,  String? metaTimeStamp,  String metaData,  int sequenceNumber,  String dataString,  String category,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SinceWhenRecord() when $default != null:
return $default(_that.id,_that.createdTimeStamp,_that.parentTimeStamp,_that.reviewedTimeStamp,_that.editedTimeStamp,_that.metaTimeStamp,_that.metaData,_that.sequenceNumber,_that.dataString,_that.category,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String createdTimeStamp,  String? parentTimeStamp,  String reviewedTimeStamp,  String editedTimeStamp,  String? metaTimeStamp,  String metaData,  int sequenceNumber,  String dataString,  String category,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _SinceWhenRecord():
return $default(_that.id,_that.createdTimeStamp,_that.parentTimeStamp,_that.reviewedTimeStamp,_that.editedTimeStamp,_that.metaTimeStamp,_that.metaData,_that.sequenceNumber,_that.dataString,_that.category,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String createdTimeStamp,  String? parentTimeStamp,  String reviewedTimeStamp,  String editedTimeStamp,  String? metaTimeStamp,  String metaData,  int sequenceNumber,  String dataString,  String category,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _SinceWhenRecord() when $default != null:
return $default(_that.id,_that.createdTimeStamp,_that.parentTimeStamp,_that.reviewedTimeStamp,_that.editedTimeStamp,_that.metaTimeStamp,_that.metaData,_that.sequenceNumber,_that.dataString,_that.category,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SinceWhenRecord implements SinceWhenRecord {
  const _SinceWhenRecord({required this.id, required this.createdTimeStamp, this.parentTimeStamp, required this.reviewedTimeStamp, required this.editedTimeStamp, this.metaTimeStamp, required this.metaData, required this.sequenceNumber, required this.dataString, required this.category, required final  List<String> tags}): _tags = tags;
  factory _SinceWhenRecord.fromJson(Map<String, dynamic> json) => _$SinceWhenRecordFromJson(json);

/// Auto-increment ID for internal database use.
@override final  int id;
/// Unique identifier for this record (ISO8601 UTC).
@override final  String createdTimeStamp;
/// Reference to parent record's [createdTimeStamp], if any.
@override final  String? parentTimeStamp;
/// Timestamp of last review (ISO8601 UTC).
@override final  String reviewedTimeStamp;
/// Timestamp of last edit (ISO8601 UTC).
@override final  String editedTimeStamp;
/// Optional metadata timestamp (ISO8601 UTC).
@override final  String? metaTimeStamp;
/// Metadata string (guideline: ~100 characters).
@override final  String metaData;
/// User-defined ordering within sibling records.
/// Parent records have sequenceNumber 0.
@override final  int sequenceNumber;
/// Primary data content (unlimited length).
@override final  String dataString;
/// Free-form category classification.
@override final  String category;
/// List of tags associated with this record.
 final  List<String> _tags;
/// List of tags associated with this record.
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of SinceWhenRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SinceWhenRecordCopyWith<_SinceWhenRecord> get copyWith => __$SinceWhenRecordCopyWithImpl<_SinceWhenRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SinceWhenRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SinceWhenRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.createdTimeStamp, createdTimeStamp) || other.createdTimeStamp == createdTimeStamp)&&(identical(other.parentTimeStamp, parentTimeStamp) || other.parentTimeStamp == parentTimeStamp)&&(identical(other.reviewedTimeStamp, reviewedTimeStamp) || other.reviewedTimeStamp == reviewedTimeStamp)&&(identical(other.editedTimeStamp, editedTimeStamp) || other.editedTimeStamp == editedTimeStamp)&&(identical(other.metaTimeStamp, metaTimeStamp) || other.metaTimeStamp == metaTimeStamp)&&(identical(other.metaData, metaData) || other.metaData == metaData)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.dataString, dataString) || other.dataString == dataString)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdTimeStamp,parentTimeStamp,reviewedTimeStamp,editedTimeStamp,metaTimeStamp,metaData,sequenceNumber,dataString,category,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'SinceWhenRecord(id: $id, createdTimeStamp: $createdTimeStamp, parentTimeStamp: $parentTimeStamp, reviewedTimeStamp: $reviewedTimeStamp, editedTimeStamp: $editedTimeStamp, metaTimeStamp: $metaTimeStamp, metaData: $metaData, sequenceNumber: $sequenceNumber, dataString: $dataString, category: $category, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$SinceWhenRecordCopyWith<$Res> implements $SinceWhenRecordCopyWith<$Res> {
  factory _$SinceWhenRecordCopyWith(_SinceWhenRecord value, $Res Function(_SinceWhenRecord) _then) = __$SinceWhenRecordCopyWithImpl;
@override @useResult
$Res call({
 int id, String createdTimeStamp, String? parentTimeStamp, String reviewedTimeStamp, String editedTimeStamp, String? metaTimeStamp, String metaData, int sequenceNumber, String dataString, String category, List<String> tags
});




}
/// @nodoc
class __$SinceWhenRecordCopyWithImpl<$Res>
    implements _$SinceWhenRecordCopyWith<$Res> {
  __$SinceWhenRecordCopyWithImpl(this._self, this._then);

  final _SinceWhenRecord _self;
  final $Res Function(_SinceWhenRecord) _then;

/// Create a copy of SinceWhenRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdTimeStamp = null,Object? parentTimeStamp = freezed,Object? reviewedTimeStamp = null,Object? editedTimeStamp = null,Object? metaTimeStamp = freezed,Object? metaData = null,Object? sequenceNumber = null,Object? dataString = null,Object? category = null,Object? tags = null,}) {
  return _then(_SinceWhenRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdTimeStamp: null == createdTimeStamp ? _self.createdTimeStamp : createdTimeStamp // ignore: cast_nullable_to_non_nullable
as String,parentTimeStamp: freezed == parentTimeStamp ? _self.parentTimeStamp : parentTimeStamp // ignore: cast_nullable_to_non_nullable
as String?,reviewedTimeStamp: null == reviewedTimeStamp ? _self.reviewedTimeStamp : reviewedTimeStamp // ignore: cast_nullable_to_non_nullable
as String,editedTimeStamp: null == editedTimeStamp ? _self.editedTimeStamp : editedTimeStamp // ignore: cast_nullable_to_non_nullable
as String,metaTimeStamp: freezed == metaTimeStamp ? _self.metaTimeStamp : metaTimeStamp // ignore: cast_nullable_to_non_nullable
as String?,metaData: null == metaData ? _self.metaData : metaData // ignore: cast_nullable_to_non_nullable
as String,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,dataString: null == dataString ? _self.dataString : dataString // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

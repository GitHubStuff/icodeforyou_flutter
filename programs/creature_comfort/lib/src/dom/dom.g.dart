// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SinceWhen _$SinceWhenFromJson(Map<String, dynamic> json) => _SinceWhen(
  identity: (json['identity'] as num).toInt(),
  caption: json['caption'] as String,
  timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SinceWhenToJson(_SinceWhen instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'caption': instance.caption,
      'timestamp': instance.timestamp,
    };

_SinceWhenUser _$SinceWhenUserFromJson(Map<String, dynamic> json) =>
    _SinceWhenUser(
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      name: json['name'] as String,
      sinceWhenList:
          (json['sinceWhenList'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SinceWhenUserToJson(_SinceWhenUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'name': instance.name,
      'sinceWhenList': instance.sinceWhenList,
    };

_SinceWhenParent _$SinceWhenParentFromJson(Map<String, dynamic> json) =>
    _SinceWhenParent(
      sinceWhen:
          (json['sinceWhen'] as List<dynamic>?)
              ?.map((e) => SinceWhen.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      users:
          (json['users'] as List<dynamic>?)
              ?.map((e) => SinceWhenUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SinceWhenParentToJson(_SinceWhenParent instance) =>
    <String, dynamic>{'sinceWhen': instance.sinceWhen, 'users': instance.users};

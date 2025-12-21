// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'since_when_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SinceWhenRecord _$SinceWhenRecordFromJson(Map<String, dynamic> json) =>
    _SinceWhenRecord(
      id: (json['id'] as num).toInt(),
      createdTimeStamp: json['createdTimeStamp'] as String,
      parentTimeStamp: json['parentTimeStamp'] as String?,
      reviewedTimeStamp: json['reviewedTimeStamp'] as String,
      editedTimeStamp: json['editedTimeStamp'] as String,
      metaTimeStamp: json['metaTimeStamp'] as String?,
      metaData: json['metaData'] as String,
      sequenceNumber: (json['sequenceNumber'] as num).toInt(),
      dataString: json['dataString'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SinceWhenRecordToJson(_SinceWhenRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdTimeStamp': instance.createdTimeStamp,
      'parentTimeStamp': instance.parentTimeStamp,
      'reviewedTimeStamp': instance.reviewedTimeStamp,
      'editedTimeStamp': instance.editedTimeStamp,
      'metaTimeStamp': instance.metaTimeStamp,
      'metaData': instance.metaData,
      'sequenceNumber': instance.sequenceNumber,
      'dataString': instance.dataString,
      'category': instance.category,
      'tags': instance.tags,
    };

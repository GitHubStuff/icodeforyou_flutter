// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picker_visual_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PickerVisualSettings _$PickerVisualSettingsFromJson(
  Map<String, dynamic> json,
) => _PickerVisualSettings(
  wheel: json['wheel'] == null
      ? const WheelSettings()
      : WheelSettings.fromJson(json['wheel'] as Map<String, dynamic>),
  startingIndex: (json['startingIndex'] as num?)?.toInt() ?? 0,
  frameBorderRadius: (json['frameBorderRadius'] as num?)?.toDouble() ?? 8.0,
  frameHorizontalPadding:
      (json['frameHorizontalPadding'] as num?)?.toDouble() ?? 12.0,
  frameVerticalPadding:
      (json['frameVerticalPadding'] as num?)?.toDouble() ?? 6.0,
);

Map<String, dynamic> _$PickerVisualSettingsToJson(
  _PickerVisualSettings instance,
) => <String, dynamic>{
  'wheel': instance.wheel.toJson(),
  'startingIndex': instance.startingIndex,
  'frameBorderRadius': instance.frameBorderRadius,
  'frameHorizontalPadding': instance.frameHorizontalPadding,
  'frameVerticalPadding': instance.frameVerticalPadding,
};

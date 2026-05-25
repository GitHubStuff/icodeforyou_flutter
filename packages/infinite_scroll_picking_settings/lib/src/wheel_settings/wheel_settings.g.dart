// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wheel_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WheelSettings _$WheelSettingsFromJson(Map<String, dynamic> json) =>
    _WheelSettings(
      itemExtent: (json['itemExtent'] as num?)?.toDouble() ?? 24.0,
      dividerThickness: (json['dividerThickness'] as num?)?.toDouble() ?? 1.0,
      dividerInset: (json['dividerInset'] as num?)?.toDouble() ?? 4.0,
      wheelWidth: (json['wheelWidth'] as num?)?.toDouble() ?? 56.0,
      wheelHeight: (json['wheelHeight'] as num?)?.toDouble() ?? 48.0,
      perspectiveDiameter:
          (json['perspectiveDiameter'] as num?)?.toDouble() ?? 1.2,
      magnification: (json['magnification'] as num?)?.toDouble() ?? 1.25,
      wheelBorderRadius: (json['wheelBorderRadius'] as num?)?.toDouble() ?? 8.0,
      showBorder: json['showBorder'] as bool? ?? true,
      selectionDebounce: json['selectionDebounce'] == null
          ? Duration.zero
          : Duration(microseconds: (json['selectionDebounce'] as num).toInt()),
    );

Map<String, dynamic> _$WheelSettingsToJson(_WheelSettings instance) =>
    <String, dynamic>{
      'itemExtent': instance.itemExtent,
      'dividerThickness': instance.dividerThickness,
      'dividerInset': instance.dividerInset,
      'wheelWidth': instance.wheelWidth,
      'wheelHeight': instance.wheelHeight,
      'perspectiveDiameter': instance.perspectiveDiameter,
      'magnification': instance.magnification,
      'wheelBorderRadius': instance.wheelBorderRadius,
      'showBorder': instance.showBorder,
      'selectionDebounce': instance.selectionDebounce.inMicroseconds,
    };

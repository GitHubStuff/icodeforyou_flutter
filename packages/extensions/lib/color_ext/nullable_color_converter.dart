// extensions/lib/src/nullable_color_converter.dart
// ignore_for_file: always_use_package_imports, public_member_api_docs

import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';

import 'color_ext.dart';

class NullableColorConverter implements JsonConverter<Color?, int?> {
  const NullableColorConverter();

  @override
  Color? fromJson(int? json) => json == null ? null : Color(json);

  @override
  int? toJson(Color? color) => color?.toInt();
}

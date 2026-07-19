// extensions/lib/src/nullable_color_converter.dart
import 'package:extensions/color/color_ext.dart';
import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';

/// A [JsonConverter] that serializes a nullable [Color] to and from a nullable
/// ARGB integer.
///
/// Use this when a model field is an optional [Color] and you want
/// `json_serializable` to handle it transparently. The color is stored as its
/// 32-bit ARGB value (see [Color.toInt]) so that it round-trips cleanly through
/// JSON, while `null` is preserved on both sides of the conversion.
///
/// Annotate the field with the converter:
///
/// ```dart
/// @NullableColorConverter()
/// final Color? accentColor;
/// ```
class NullableColorConverter implements JsonConverter<Color?, int?> {
  /// Creates a [NullableColorConverter].
  const NullableColorConverter();

  /// Converts a nullable ARGB [json] integer into a [Color].
  ///
  /// Returns `null` when [json] is `null`; otherwise constructs a [Color] from
  /// the 32-bit ARGB value.
  @override
  Color? fromJson(int? json) => json == null ? null : Color(json);

  /// Converts a nullable [color] into its ARGB integer representation.
  ///
  /// Returns `null` when [color] is `null`; otherwise delegates to the
  /// `toInt` extension to produce the 32-bit ARGB value.
  @override
  int? toJson(Color? color) => color?.toInt();
}

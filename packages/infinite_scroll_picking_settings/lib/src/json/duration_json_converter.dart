// infinite_scroll_picking_settings/lib/src/json/duration_json_converter.dart

// ignore_for_file: public_member_api_docs

import 'package:json_annotation/json_annotation.dart';

/// Serializes a [Duration] as its [Duration.inMicroseconds] value.
///
/// Microseconds are used (rather than milliseconds) so sub-millisecond
/// values round-trip exactly. Stored as a JSON `int`, which is portable
/// across platforms and storage backends.
///
/// Apply at the class level on a freezed class so every [Duration] field
/// picks it up automatically:
///
/// ```dart
/// @freezed
/// @DurationJsonConverter()
/// abstract class MyConfig with _$MyConfig { ... }
/// ```
class DurationJsonConverter implements JsonConverter<Duration, int> {
  const DurationJsonConverter();

  @override
  Duration fromJson(int json) => Duration(microseconds: json);

  @override
  int toJson(Duration object) => object.inMicroseconds;
}

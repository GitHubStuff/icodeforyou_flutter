// packages/infinite_scroll_picking_settings/test/src/json/duration_json_converter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/json/duration_json_converter.dart'
    show DurationJsonConverter;

/// Converter under test — const so a single shared instance suffices.
const _kConverter = DurationJsonConverter();

void main() {
  group('DurationJsonConverter', () {
    test('fromJson builds a Duration from microseconds', () {
      expect(
        _kConverter.fromJson(1500),
        const Duration(microseconds: 1500),
      );
    });

    test('toJson emits Duration.inMicroseconds', () {
      expect(_kConverter.toJson(const Duration(milliseconds: 2)), 2000);
    });

    test('sub-millisecond values round-trip exactly', () {
      const original = Duration(microseconds: 750);
      expect(_kConverter.fromJson(_kConverter.toJson(original)), original);
    });

    test('Duration.zero round-trips as 0', () {
      expect(_kConverter.toJson(Duration.zero), 0);
      expect(_kConverter.fromJson(0), Duration.zero);
    });
  });
}

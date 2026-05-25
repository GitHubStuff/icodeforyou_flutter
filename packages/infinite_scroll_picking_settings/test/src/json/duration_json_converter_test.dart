// infinite_scroll_picking_settings/test/src/json/duration_json_converter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/json/duration_json_converter.dart'
    show DurationJsonConverter;

void main() {
  group('DurationJsonConverter', () {
    const converter = DurationJsonConverter();

    group('toJson', () {
      test('encodes Duration.zero as 0 microseconds', () {
        expect(converter.toJson(Duration.zero), 0);
      });

      test('encodes a millisecond duration as its microsecond value', () {
        expect(
          converter.toJson(const Duration(milliseconds: 250)),
          250 * 1000,
        );
      });

      test('encodes a sub-millisecond duration without truncation', () {
        // 1234 microseconds: would round to 1ms if encoded as ms.
        expect(converter.toJson(const Duration(microseconds: 1234)), 1234);
      });

      test('encodes a negative duration as a negative microsecond value', () {
        expect(converter.toJson(const Duration(seconds: -1)), -1000000);
      });
    });

    group('fromJson', () {
      test('decodes 0 as Duration.zero', () {
        expect(converter.fromJson(0), Duration.zero);
      });

      test('decodes a microsecond integer as a Duration', () {
        expect(converter.fromJson(1234), const Duration(microseconds: 1234));
      });

      test('decodes a negative integer as a negative Duration', () {
        expect(converter.fromJson(-1000000), const Duration(seconds: -1));
      });
    });

    group('round-trip', () {
      test('preserves sub-millisecond precision', () {
        const original = Duration(microseconds: 1234);
        expect(converter.fromJson(converter.toJson(original)), original);
      });

      test('preserves multi-component durations', () {
        const original = Duration(
          hours: 1,
          minutes: 23,
          seconds: 45,
          milliseconds: 678,
          microseconds: 9,
        );
        expect(converter.fromJson(converter.toJson(original)), original);
      });
    });
  });
}

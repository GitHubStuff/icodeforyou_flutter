// packages/extensions/test/json/nullable_color_converter_test.dart

import 'package:extensions/json/nullable_color_converter.dart'
    show NullableColorConverter;
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NullableColorConverter', () {
    const converter = NullableColorConverter();

    test('fromJson returns null for null input', () {
      expect(converter.fromJson(null), isNull);
    });

    test('fromJson builds a Color from a 32-bit ARGB value', () {
      expect(converter.fromJson(0xFF112233), const Color(0xFF112233));
    });

    test('toJson returns null for null input', () {
      expect(converter.toJson(null), isNull);
    });

    test('toJson emits the 32-bit ARGB value', () {
      expect(converter.toJson(const Color(0xFF112233)), 0xFF112233);
    });

    test('round-trips a color through JSON', () {
      const original = Color(0x80ABCDEF);
      expect(converter.fromJson(converter.toJson(original)), original);
    });
  });
}

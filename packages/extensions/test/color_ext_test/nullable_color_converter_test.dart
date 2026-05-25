// extensions/test/src/nullable_color_converter_test.dart

import 'package:extensions/extensions.dart'
    show ColorExtension, NullableColorConverter;
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NullableColorConverter', () {
    const converter = NullableColorConverter();

    group('fromJson', () {
      test('returns null when json is null', () {
        expect(converter.fromJson(null), isNull);
      });

      test('returns Color built from int value', () {
        const value = 0xFF112233;

        final result = converter.fromJson(value);

        expect(result, isA<Color>());
        expect(result, equals(const Color(value)));
      });

      test('handles fully transparent black (0x00000000)', () {
        final result = converter.fromJson(0x00000000);

        expect(result, equals(const Color(0x00000000)));
      });
    });

    group('toJson', () {
      test('returns null when color is null', () {
        expect(converter.toJson(null), isNull);
      });

      test('returns int produced by ColorExtension.toInt', () {
        const color = Color(0xFF445566);

        final result = converter.toJson(color);

        expect(result, isA<int>());
        expect(result, color.toInt());
      });
    });

    group('round-trip', () {
      test('toJson then fromJson reproduces an equivalent Color', () {
        const original = Color(0xFFAABBCC);

        final encoded = converter.toJson(original);
        final decoded = converter.fromJson(encoded);

        expect(decoded, equals(original));
      });

      test('null round-trips as null', () {
        final encoded = converter.toJson(null);
        final decoded = converter.fromJson(encoded);

        expect(encoded, isNull);
        expect(decoded, isNull);
      });
    });
  });
}

// packages/extensions/test/color_ext_test/color_ext_test.dart

import 'package:extensions/color_ext/color_ext.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorExtension.equals', () {
    test('true when all ARGB channels match', () {
      const a = Color(0xFF123456);
      const b = Color(0xFF123456);
      expect(a.equals(b), isTrue);
    });

    test('false when any channel differs', () {
      const base = Color(0xFF123456);
      expect(base.equals(const Color(0xFF123457)), isFalse); // b differs
      expect(base.equals(const Color(0xFF123556)), isFalse); // g differs
      expect(base.equals(const Color(0xFF124456)), isFalse); // r differs
      expect(base.equals(const Color(0x00123456)), isFalse); // a differs
    });
  });

  group('ColorExtension.contrastingTextColor', () {
    test('returns black on a light color (luminance > 0.5)', () {
      expect(
        const Color(0xFFFFFFFF).contrastingTextColor(),
        const Color(0xFF000000),
      );
    });

    test('returns white on a dark color (luminance <= 0.5)', () {
      expect(
        const Color(0xFF000000).contrastingTextColor(),
        const Color(0xFFFFFFFF),
      );
    });
  });

  group('ColorExtension.toInt', () {
    test('round-trips an opaque ARGB value', () {
      const color = Color(0xFF8040C0);
      expect(color.toInt(), 0xFF8040C0);
    });

    test('preserves a non-opaque alpha channel', () {
      const color = Color(0x80112233);
      expect(color.toInt(), 0x80112233);
    });

    test('zero color maps to 0x00000000', () {
      expect(const Color(0x00000000).toInt(), 0x00000000);
    });
  });

  group('ColorExtension.withAlphaValue', () {
    test('defaults to 0.25 when no alpha is supplied', () {
      final result = const Color(0xFF112233).withAlphaValue();
      expect(result.a, closeTo(0.25, 0.001));
      // RGB channels are untouched.
      expect(result.r, closeTo(const Color(0xFF112233).r, 0.001));
      expect(result.g, closeTo(const Color(0xFF112233).g, 0.001));
      expect(result.b, closeTo(const Color(0xFF112233).b, 0.001));
    });

    test('applies an explicit in-range alpha', () {
      final result = const Color(0xFF112233).withAlphaValue(0.6);
      expect(result.a, closeTo(0.6, 0.001));
    });

    test('accepts the inclusive bounds 0.0 and 1.0', () {
      expect(
        const Color(0xFF112233).withAlphaValue(0).a,
        closeTo(0.0, 0.001),
      );
      expect(
        const Color(0xFF112233).withAlphaValue(1).a,
        closeTo(1.0, 0.001),
      );
    });

    test('asserts when alpha is below 0.0', () {
      expect(
        () => const Color(0xFF112233).withAlphaValue(-0.1),
        throwsAssertionError,
      );
    });

    test('asserts when alpha is above 1.0', () {
      expect(
        () => const Color(0xFF112233).withAlphaValue(1.1),
        throwsAssertionError,
      );
    });
  });
}

// packages/extensions/test/color/color_ext_test.dart

import 'package:extensions/color/color_ext.dart' show ColorExt;
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorExt', () {
    group('equals', () {
      test('returns true for identical ARGB values', () {
        expect(
          const Color(0xFF112233).equals(const Color(0xFF112233)),
          isTrue,
        );
      });

      test('returns false when alpha differs', () {
        expect(
          const Color(0xFF112233).equals(const Color(0x80112233)),
          isFalse,
        );
      });

      test('returns false when red differs', () {
        expect(
          const Color(0xFF112233).equals(const Color(0xFF992233)),
          isFalse,
        );
      });

      test('returns false when green differs', () {
        expect(
          const Color(0xFF112233).equals(const Color(0xFF119933)),
          isFalse,
        );
      });

      test('returns false when blue differs', () {
        expect(
          const Color(0xFF112233).equals(const Color(0xFF112299)),
          isFalse,
        );
      });
    });

    group('contrastingTextColor', () {
      test('returns black on a light color', () {
        expect(
          const Color(0xFFFFFFFF).contrastingColor(),
          const Color(0xFF000000),
        );
      });

      test('returns white on a dark color', () {
        expect(
          const Color(0xFF000000).contrastingColor(),
          const Color(0xFFFFFFFF),
        );
      });
    });

    group('toInt', () {
      test('round-trips a 32-bit ARGB value', () {
        expect(const Color(0xFF112233).toInt(), 0xFF112233);
      });

      test('preserves a translucent alpha channel', () {
        expect(const Color(0x80FF0000).toInt(), 0x80FF0000);
      });
    });

    group('withAlphaValue', () {
      test('defaults to 0.25 opacity', () {
        final result = const Color(0xFF112233).withAlphaValue();
        expect(result.a, closeTo(0.25, 0.005));
      });

      test('applies an explicit opacity', () {
        final result = const Color(0xFF112233).withAlphaValue(0.5);
        expect(result.a, closeTo(0.5, 0.005));
      });

      test('asserts on an out-of-range opacity', () {
        expect(
          () => const Color(0xFF112233).withAlphaValue(1.5),
          throwsAssertionError,
        );
      });
    });
  });
}

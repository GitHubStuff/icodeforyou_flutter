// packages/extensions/test/color/color_ext_test.dart
import 'package:extensions/color/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorExt', () {
    group('equals', () {
      test('returns true for identical ARGB values', () {
        const a = Color(0xFF123456);
        const b = Color(0xFF123456);

        expect(a.equals(b), isTrue);
      });

      test('returns false when alpha differs', () {
        const a = Color(0xFF123456);
        const b = Color(0x80123456);

        expect(a.equals(b), isFalse);
      });

      test('returns false when red differs', () {
        const a = Color(0xFF123456);
        const b = Color(0xFF003456);

        expect(a.equals(b), isFalse);
      });

      test('returns false when green differs', () {
        const a = Color(0xFF123456);
        const b = Color(0xFF120056);

        expect(a.equals(b), isFalse);
      });

      test('returns false when blue differs', () {
        const a = Color(0xFF123456);
        const b = Color(0xFF123400);

        expect(a.equals(b), isFalse);
      });
    });

    group('contrastingColor', () {
      test('returns black for a light color by default', () {
        const light = Color(0xFFFFFFFF);

        expect(light.contrastingColor(), const Color(0xFF000000));
      });

      test('returns white for a dark color by default', () {
        const dark = Color(0xFF000000);

        expect(dark.contrastingColor(), const Color(0xFFFFFFFF));
      });

      test('returns forLight override for a light color', () {
        const light = Color(0xFFFFFFFF);
        const override = Color(0xFF112233);

        expect(light.contrastingColor(forLight: override), override);
      });

      test('returns forDark override for a dark color', () {
        const dark = Color(0xFF000000);
        const override = Color(0xFFAABBCC);

        expect(dark.contrastingColor(forDark: override), override);
      });

      test('ignores forDark override for a light color', () {
        const light = Color(0xFFFFFFFF);
        const override = Color(0xFFAABBCC);

        expect(
          light.contrastingColor(forDark: override),
          const Color(0xFF000000),
        );
      });

      test('ignores forLight override for a dark color', () {
        const dark = Color(0xFF000000);
        const override = Color(0xFF112233);

        expect(
          dark.contrastingColor(forLight: override),
          const Color(0xFFFFFFFF),
        );
      });
    });

    group('toInt', () {
      test('round-trips an opaque color', () {
        const color = Color(0xFF123456);

        expect(color.toInt(), 0xFF123456);
      });

      test('round-trips a translucent color', () {
        const color = Color(0x80ABCDEF);

        expect(color.toInt(), 0x80ABCDEF);
      });

      test('round-trips a fully transparent color', () {
        const color = Color(0x00000000);

        expect(color.toInt(), 0x00000000);
      });

      test('round-trips white', () {
        const color = Color(0xFFFFFFFF);

        expect(color.toInt(), 0xFFFFFFFF);
      });
    });

    group('withAlphaValue', () {
      test('defaults to 0.25 alpha', () {
        const color = Color(0xFF123456);

        final result = color.withAlphaValue();

        expect(result.a, closeTo(0.25, 0.001));
        expect(result.r, color.r);
        expect(result.g, color.g);
        expect(result.b, color.b);
      });

      test('applies an explicit alpha', () {
        const color = Color(0xFF123456);

        final result = color.withAlphaValue(0.5);

        expect(result.a, closeTo(0.5, 0.001));
      });

      test('accepts the lower bound of 0.0', () {
        const color = Color(0xFF123456);

        expect(color.withAlphaValue(0).a, 0.0);
      });

      test('accepts the upper bound of 1.0', () {
        const color = Color(0xFF123456);

        expect(color.withAlphaValue(1).a, 1.0);
      });

      test('asserts when alpha is below 0.0', () {
        const color = Color(0xFF123456);

        expect(() => color.withAlphaValue(-0.1), throwsAssertionError);
      });

      test('asserts when alpha is above 1.0', () {
        const color = Color(0xFF123456);

        expect(() => color.withAlphaValue(1.1), throwsAssertionError);
      });
    });

    group('toNeonAccent', () {
      test('returns a grey unchanged because it has no hue', () {
        const grey = Color(0xFF808080);

        expect(grey.toNeonAccent(), same(grey));
      });

      test('returns pure white unchanged', () {
        const white = Color(0xFFFFFFFF);

        expect(white.toNeonAccent(), same(white));
      });

      test('returns pure black unchanged', () {
        const black = Color(0xFF000000);

        expect(black.toNeonAccent(), same(black));
      });

      test('raises a saturated hue to full saturation and 0.62 lightness', () {
        final result = HSLColor.fromColor(Colors.green.toNeonAccent());

        expect(result.saturation, closeTo(1, 0.001));
        expect(result.lightness, closeTo(0.62, 0.001));
      });

      test('preserves the hue of the source color', () {
        final source = HSLColor.fromColor(Colors.blue);
        final result = HSLColor.fromColor(Colors.blue.toNeonAccent());

        expect(result.hue, closeTo(source.hue, 0.5));
      });

      test('does not return the same instance for a saturated color', () {
        final result = Colors.red.toNeonAccent();

        expect(result, isNot(same(Colors.red)));
      });
    });

    group('toNeonCore', () {
      test('defaults to a 0.45 tint between white and the accent', () {
        final accent = Colors.green.toNeonAccent();
        final expected = Color.lerp(Colors.white, accent, 0.45)!;

        expect(Colors.green.toNeonCore().equals(expected), isTrue);
      });

      test('returns white at a tint of 0.0', () {
        expect(Colors.green.toNeonCore(tint: 0).equals(Colors.white), isTrue);
      });

      test('returns the accent at a tint of 1.0', () {
        final accent = Colors.green.toNeonAccent();

        expect(Colors.green.toNeonCore(tint: 1).equals(accent), isTrue);
      });

      test('returns white for a grey because the accent is the grey', () {
        const grey = Color(0xFF808080);
        final expected = Color.lerp(Colors.white, grey, 0.45)!;

        expect(grey.toNeonCore().equals(expected), isTrue);
      });

      test('asserts when tint is below 0.0', () {
        expect(() => Colors.green.toNeonCore(tint: -0.1), throwsAssertionError);
      });

      test('asserts when tint is above 1.0', () {
        expect(() => Colors.green.toNeonCore(tint: 1.1), throwsAssertionError);
      });
    });
  });
}

import 'package:extensions/extensions.dart' show ColorExtension, IntExt;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Update this import to match your project structure.
// import 'package:your_package/color_extension.dart';

void main() {
  group('ColorExtension', () {
    group('toColor', () {
      test('converts int to Color', () {
        const argb = 0xFFFF0000;
        expect(argb.toColor(), equals(const Color(0xFFFF0000)));
      });
    });
    group('contrastingTextColor', () {
      test('returns black for light color', () {
        const color = Color(0xFFFFFFFF);
        expect(color.contrastingTextColor(), equals(const Color(0xFF000000)));
      });

      test('returns white for dark color', () {
        const color = Color(0xFF000000);
        expect(color.contrastingTextColor(), equals(const Color(0xFFFFFFFF)));
      });
    });

    group('toInt', () {
      test('converts opaque red correctly', () {
        const color = Color(0xFFFF0000);
        expect(color.toInt(), equals(0xFFFF0000));
      });

      test('converts transparent black correctly', () {
        const color = Color(0x00000000);
        expect(color.toInt(), equals(0x00000000));
      });

      test('converts arbitrary ARGB correctly', () {
        const color = Color(0xAABBCCDD);
        expect(color.toInt(), equals(0xAABBCCDD));
      });
    });
    group('equals', () {
      test('returns true for identical colors', () {
        const color1 = Color(0xFFFF0000);
        const color2 = Color(0xFFFF0000);
        expect(color1.equals(color2), isTrue);
      });

      test('returns false when alpha differs', () {
        const color1 = Color(0xFFFF0000);
        const color2 = Color(0x80FF0000);
        expect(color1.equals(color2), isFalse);
      });

      test('returns false when red differs', () {
        const color1 = Color(0xFF000000);
        const color2 = Color(0xFFFF0000);
        expect(color1.equals(color2), isFalse);
      });

      test('returns false when green differs', () {
        const color1 = Color(0xFF000000);
        const color2 = Color(0xFF00FF00);
        expect(color1.equals(color2), isFalse);
      });

      test('returns false when blue differs', () {
        const color1 = Color(0xFF000000);
        const color2 = Color(0xFF0000FF);
        expect(color1.equals(color2), isFalse);
      });

      test('returns true for same color via different constructors', () {
        const color1 = Color(0xFFFFFFFF);
        const color2 = Colors.white;
        expect(color1.equals(color2), isTrue);
      });

      test('returns true when comparing color to itself', () {
        const color = Color(0xAABBCCDD);
        expect(color.equals(color), isTrue);
      });
    });
  });
}

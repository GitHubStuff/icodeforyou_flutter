import 'package:extensions/color_ext/color_ext.dart' show ColorExtension;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Update this import to match your project structure.
// import 'package:your_package/color_extension.dart';

void main() {
  group('ColorExtension', () {
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

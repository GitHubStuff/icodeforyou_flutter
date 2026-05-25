// animated_widgets/test/src/length_colored_border_field/color_point_test.dart

// ignore_for_file: prefer_const_constructors

import 'package:animated_widgets/src/length_colored_border_field/color_point.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorPoint', () {
    test('constructs with the given point and color', () {
      final colorPoint = ColorPoint(point: 5, color: Color(0xFF112233));

      expect(colorPoint.point, 5);
      expect(colorPoint.color, const Color(0xFF112233));
    });

    test('equates by point and color', () {
      final a = ColorPoint(point: 5, color: Color(0xFF112233));
      final b = ColorPoint(point: 5, color: Color(0xFF112233));

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('differs when point differs', () {
      final a = ColorPoint(point: 5, color: Color(0xFF112233));
      final b = ColorPoint(point: 6, color: Color(0xFF112233));

      expect(a, isNot(equals(b)));
    });

    test('differs when color differs', () {
      final a = ColorPoint(point: 5, color: Color(0xFF112233));
      final b = ColorPoint(point: 5, color: Color(0xFF445566));

      expect(a, isNot(equals(b)));
    });

    test('exposes point and color via props', () {
      final colorPoint = ColorPoint(point: 7, color: Color(0xFFAABBCC));

      expect(colorPoint.props, [7, const Color(0xFFAABBCC)]);
    });
  });
}

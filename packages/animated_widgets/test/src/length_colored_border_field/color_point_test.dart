// animated_widgets/test/src/length_colored_border_field/color_point_test.dart
import 'package:animated_widgets/src/length_colored_border_field/color_point.dart'
    show ColorPoint;
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);

  group('ColorPoint', () {
    test('exposes the supplied point and color', () {
      // Built from a runtime value (deliberately not `const`) so the
      // constructor body actually executes. A `const ColorPoint(...)` is
      // canonicalised at compile time and never runs the constructor, which
      // leaves the constructor line uncovered in LCOV.
      final point = <int>[5].first;
      final colorPoint = ColorPoint(point: point, color: red);

      expect(colorPoint.point, 5);
      expect(colorPoint.color, red);
    });

    test('lists props as [point, color] in order', () {
      const colorPoint = ColorPoint(point: 5, color: red);

      expect(colorPoint.props, <Object?>[5, red]);
    });

    test('is equal to another instance with the same point and color', () {
      const a = ColorPoint(point: 5, color: red);
      const b = ColorPoint(point: 5, color: red);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('differs when the point differs', () {
      const a = ColorPoint(point: 5, color: red);
      const b = ColorPoint(point: 6, color: red);

      expect(a, isNot(equals(b)));
    });

    test('differs when the color differs', () {
      const a = ColorPoint(point: 5, color: red);
      const b = ColorPoint(point: 5, color: blue);

      expect(a, isNot(equals(b)));
    });
  });
}

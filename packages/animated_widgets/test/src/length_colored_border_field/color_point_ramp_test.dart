// animated_widgets/test/src/length_colored_border_field/color_point_ramp_test.dart
import 'package:animated_widgets/src/length_colored_border_field/color_point.dart'
    show ColorPoint;
import 'package:animated_widgets/src/length_colored_border_field/color_point_ramp.dart'
    show ColorPointRamp;
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);
  const green = Color(0xFF00FF00);

  ColorPointRamp buildRamp() => ColorPointRamp(const [
        ColorPoint(point: 0, color: red),
        ColorPoint(point: 5, color: blue),
        ColorPoint(point: 10, color: green),
      ]);

  group('ColorPointRamp', () {
    group('validation', () {
      test('builds from a valid ascending ramp starting at 0', () {
        final ramp = buildRamp();

        expect(ramp.points, hasLength(3));
        expect(ramp.points.first.point, 0);
      });

      test('throws when points is empty', () {
        expect(
          () => ColorPointRamp(const []),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when the first point is not 0', () {
        expect(
          () => ColorPointRamp(const [ColorPoint(point: 1, color: red)]),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws when points do not strictly ascend', () {
        expect(
          () => ColorPointRamp(const [
            ColorPoint(point: 0, color: red),
            ColorPoint(point: 5, color: blue),
            ColorPoint(point: 5, color: green),
          ]),
          throwsA(isA<AssertionError>()),
        );
      });

      test('exposes an unmodifiable points list', () {
        final ramp = buildRamp();

        expect(
          () => ramp.points.add(const ColorPoint(point: 20, color: red)),
          throwsUnsupportedError,
        );
      });
    });

    group('colorFor', () {
      test('returns the first color for lengths below the first threshold', () {
        expect(buildRamp().colorFor(-1), red);
      });

      test('returns the first color at length 0', () {
        expect(buildRamp().colorFor(0), red);
      });

      test('returns the matching color between thresholds', () {
        expect(buildRamp().colorFor(7), blue);
      });

      test('returns the color exactly at a threshold', () {
        final ramp = buildRamp();

        expect(ramp.colorFor(5), blue);
        expect(ramp.colorFor(10), green);
      });

      test('returns the last color for lengths above the final threshold', () {
        expect(buildRamp().colorFor(100), green);
      });
    });

    group('equality', () {
      test('lists props as [points]', () {
        final ramp = buildRamp();

        expect(ramp.props, [ramp.points]);
      });

      test('ramps with identical points compare equal', () {
        final a = buildRamp();
        final b = buildRamp();

        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('ramps with different points are not equal', () {
        final a = buildRamp();
        final b = ColorPointRamp(const [ColorPoint(point: 0, color: red)]);

        expect(a, isNot(equals(b)));
      });
    });
  });
}

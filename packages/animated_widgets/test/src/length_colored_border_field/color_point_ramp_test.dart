// animated_widgets/test/src/length_colored_border_field/color_point_ramp_test.dart

import 'package:animated_widgets/src/length_colored_border_field/color_point.dart';
import 'package:animated_widgets/src/length_colored_border_field/color_point_ramp.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _purple = Color(0xFF800080);
const _green = Color(0xFF00FF00);
const _yellow = Color(0xFFFFFF00);
const _red = Color(0xFFFF0000);

const _exampleRamp = <ColorPoint>[
  ColorPoint(point: 0, color: _purple),
  ColorPoint(point: 3, color: _green),
  ColorPoint(point: 6, color: _yellow),
  ColorPoint(point: 9, color: _red),
];

void main() {
  group('ColorPointRamp', () {
    group('validation', () {
      test('rejects empty list', () {
        expect(() => ColorPointRamp(const []), throwsAssertionError);
      });

      test('rejects first point != 0', () {
        expect(
          () => ColorPointRamp(const [
            ColorPoint(point: 1, color: _purple),
          ]),
          throwsAssertionError,
        );
      });

      test('rejects equal consecutive points', () {
        expect(
          () => ColorPointRamp(const [
            ColorPoint(point: 0, color: _purple),
            ColorPoint(point: 0, color: _green),
          ]),
          throwsAssertionError,
        );
      });

      test('rejects descending points', () {
        expect(
          () => ColorPointRamp(const [
            ColorPoint(point: 0, color: _purple),
            ColorPoint(point: 5, color: _green),
            ColorPoint(point: 3, color: _yellow),
          ]),
          throwsAssertionError,
        );
      });

      test('accepts single zero point', () {
        final subject = ColorPointRamp(const [
          ColorPoint(point: 0, color: _purple),
        ]);
        expect(subject.points, hasLength(1));
      });

      test('accepts strictly ascending points', () {
        final subject = ColorPointRamp(_exampleRamp);
        expect(subject.points, hasLength(4));
      });
    });

    group('immutability', () {
      test('points list rejects mutation', () {
        final subject = ColorPointRamp(_exampleRamp);
        expect(
          () => subject.points.add(
            const ColorPoint(point: 99, color: _red),
          ),
          throwsUnsupportedError,
        );
      });
    });

    group('colorFor', () {
      late ColorPointRamp subject;

      setUp(() {
        subject = ColorPointRamp(_exampleRamp);
      });

      test('returns first color at length 0', () {
        expect(subject.colorFor(0), equals(_purple));
      });

      test('returns first color at length below first threshold', () {
        // first threshold above 0 is 3; lengths 1 and 2 stay purple
        expect(subject.colorFor(1), equals(_purple));
        expect(subject.colorFor(2), equals(_purple));
      });

      test('returns next color exactly at threshold', () {
        expect(subject.colorFor(3), equals(_green));
        expect(subject.colorFor(6), equals(_yellow));
        expect(subject.colorFor(9), equals(_red));
      });

      test('returns same color through bucket interior', () {
        expect(subject.colorFor(4), equals(_green));
        expect(subject.colorFor(5), equals(_green));
        expect(subject.colorFor(7), equals(_yellow));
        expect(subject.colorFor(8), equals(_yellow));
      });

      test('returns last color past final threshold', () {
        expect(subject.colorFor(10), equals(_red));
        expect(subject.colorFor(50), equals(_red));
        expect(subject.colorFor(1000000), equals(_red));
      });

      test('falls back to first color for negative length', () {
        expect(subject.colorFor(-1), equals(_purple));
        expect(subject.colorFor(-100), equals(_purple));
      });

      test('single-point ramp returns its color for any length', () {
        final single = ColorPointRamp(const [
          ColorPoint(point: 0, color: _green),
        ]);
        expect(single.colorFor(0), equals(_green));
        expect(single.colorFor(42), equals(_green));
        expect(single.colorFor(-5), equals(_green));
      });
    });

    group('equality', () {
      test('equal when points match', () {
        final a = ColorPointRamp(_exampleRamp);
        final b = ColorPointRamp(_exampleRamp);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when points differ', () {
        final a = ColorPointRamp(_exampleRamp);
        final b = ColorPointRamp(const [
          ColorPoint(point: 0, color: _purple),
          ColorPoint(point: 4, color: _green),
        ]);
        expect(a, isNot(equals(b)));
      });
    });
  });
}

// packages/custom_widgets/test/src/orientation_flex/src/aspect_shape_test.dart

import 'dart:ui' show Size;

import 'package:custom_widgets/custom_widgets.dart' show AspectShape;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AspectShape.fromSize', () {
    test('classifies wider-than-tall as landscape', () {
      expect(AspectShape.fromSize(const Size(100, 50)), AspectShape.landscape);
    });

    test('classifies taller-than-wide as portrait', () {
      expect(AspectShape.fromSize(const Size(50, 100)), AspectShape.portrait);
    });

    test('classifies an exact 1:1 viewport as square', () {
      expect(AspectShape.fromSize(const Size(100, 100)), AspectShape.square);
    });

    test('classifies degenerate viewports as square', () {
      expect(AspectShape.fromSize(const Size(0, 100)), AspectShape.square);
      expect(AspectShape.fromSize(const Size(100, 0)), AspectShape.square);
      expect(AspectShape.fromSize(const Size(-10, 100)), AspectShape.square);
    });

    test('a near-square viewport is square within tolerance', () {
      expect(
        AspectShape.fromSize(const Size(1000, 997), squareTolerance: 0.05),
        AspectShape.square,
      );
    });

    test('the same near-square viewport is landscape at zero tolerance', () {
      expect(
        AspectShape.fromSize(const Size(1000, 997)),
        AspectShape.landscape,
      );
    });

    test('the tolerance boundary is inclusive', () {
      // Ratio 1250 / 1000 is exactly 1.25 in binary floating point, so
      // the boundary comparison 1.25 - 1.0 <= 0.25 evaluates without
      // rounding error. A decimal boundary such as 1.05 vs 0.05 is not
      // exactly representable and lands on the wrong side of <=.
      expect(
        AspectShape.fromSize(const Size(1250, 1000), squareTolerance: 0.25),
        AspectShape.square,
      );
    });

    test('portrait wins the tie-break just outside tolerance', () {
      expect(
        AspectShape.fromSize(const Size(1000, 1060), squareTolerance: 0.05),
        AspectShape.portrait,
      );
    });

    test('asserts on a negative tolerance', () {
      expect(
        () => AspectShape.fromSize(const Size(1, 1), squareTolerance: -0.1),
        throwsAssertionError,
      );
    });
  });
}

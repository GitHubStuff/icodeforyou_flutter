// animated_widgets/test/src/animated_checkbox/checkmark_path_builder_test.dart

import 'dart:ui';

import 'package:animated_widgets/src/animated_checkbox/src/_checkmark_path_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const width = 100.0;
  const start = Offset(0.0, 0.5);
  const mid = Offset(0.5, 1.0);
  const finish = Offset(1.0, 0.0);

  CheckmarkPathBuilder builder() => const CheckmarkPathBuilder(
    width: width,
    startOffset: start,
    midOffset: mid,
    finishOffset: finish,
  );

  group('CheckmarkPathBuilder.buildCheckmarkPath', () {
    test('builds a non-empty three-point path', () {
      final path = builder().buildCheckmarkPath();
      final metrics = path.computeMetrics().toList();
      expect(metrics, isNotEmpty);
      expect(metrics.first.length, greaterThan(0));
    });

    test('path bounds cover the scaled start, mid and finish points', () {
      final bounds = builder().buildCheckmarkPath().getBounds();
      // start.dx*width = 0, finish.dx*width = 100 → left 0, right 100.
      expect(bounds.left, closeTo(0, 1e-9));
      expect(bounds.right, closeTo(100, 1e-9));
      // finish.dy*width = 0 (top), mid.dy*width = 100 (bottom).
      expect(bounds.top, closeTo(0, 1e-9));
      expect(bounds.bottom, closeTo(100, 1e-9));
    });
  });

  group('CheckmarkPathBuilder.getPathSegments', () {
    test('computes first and second stroke lengths from scaled points', () {
      final segments = builder().getPathSegments();

      // start→mid: (50,100)-(0,50) → sqrt(50^2 + 50^2)
      final expectedFirst = (const Offset(50, 100) - const Offset(0, 50))
          .distance;
      // mid→finish: (100,0)-(50,100) → sqrt(50^2 + 100^2)
      final expectedSecond = (const Offset(100, 0) - const Offset(50, 100))
          .distance;

      expect(segments.firstLength, closeTo(expectedFirst, 1e-9));
      expect(segments.secondLength, closeTo(expectedSecond, 1e-9));
    });

    test('exposes the scaled key points', () {
      final points = builder().getPathSegments().points;
      expect(points.start, const Offset(0, 50));
      expect(points.middle, const Offset(50, 100));
      expect(points.finish, const Offset(100, 0));
    });

    test('totalLength is the sum of both stroke lengths', () {
      final segments = builder().getPathSegments();
      expect(
        segments.totalLength,
        closeTo(segments.firstLength + segments.secondLength, 1e-9),
      );
    });
  });

  group('CheckmarkPoints', () {
    test('stores the three offsets it is constructed with', () {
      const points = CheckmarkPoints(
        start: Offset(1, 2),
        middle: Offset(3, 4),
        finish: Offset(5, 6),
      );
      expect(points.start, const Offset(1, 2));
      expect(points.middle, const Offset(3, 4));
      expect(points.finish, const Offset(5, 6));
    });
  });

  group('PathSegments', () {
    test('stores lengths and points and derives totalLength', () {
      const points = CheckmarkPoints(
        start: Offset.zero,
        middle: Offset(3, 4),
        finish: Offset(6, 8),
      );
      const segments = PathSegments(
        firstLength: 5,
        secondLength: 5,
        points: points,
      );
      expect(segments.firstLength, 5);
      expect(segments.secondLength, 5);
      expect(segments.points, same(points));
      expect(segments.totalLength, 10);
    });
  });
}

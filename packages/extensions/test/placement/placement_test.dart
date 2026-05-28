// packages/extensions/test/placement/placement_test.dart

import 'package:extensions/placement/placement.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Placement', () {
    group('isHorizontal', () {
      test('returns true for left', () {
        expect(Placement.left.isHorizontal, isTrue);
      });

      test('returns true for right', () {
        expect(Placement.right.isHorizontal, isTrue);
      });

      test('returns false for top', () {
        expect(Placement.top.isHorizontal, isFalse);
      });

      test('returns false for bottom', () {
        expect(Placement.bottom.isHorizontal, isFalse);
      });

      test('returns false for center', () {
        expect(Placement.center.isHorizontal, isFalse);
      });
    });

    group('isVertical', () {
      test('returns true for top', () {
        expect(Placement.top.isVertical, isTrue);
      });

      test('returns true for bottom', () {
        expect(Placement.bottom.isVertical, isTrue);
      });

      test('returns false for left', () {
        expect(Placement.left.isVertical, isFalse);
      });

      test('returns false for right', () {
        expect(Placement.right.isVertical, isFalse);
      });

      test('returns false for center', () {
        expect(Placement.center.isVertical, isFalse);
      });
    });

    group('isCentered', () {
      test('returns true for center', () {
        expect(Placement.center.isCentered, isTrue);
      });

      test('returns false for top', () {
        expect(Placement.top.isCentered, isFalse);
      });

      test('returns false for bottom', () {
        expect(Placement.bottom.isCentered, isFalse);
      });

      test('returns false for left', () {
        expect(Placement.left.isCentered, isFalse);
      });

      test('returns false for right', () {
        expect(Placement.right.isCentered, isFalse);
      });
    });

    group('toAlignment', () {
      test('top maps to Alignment.topCenter', () {
        expect(Placement.top.toAlignment, Alignment.topCenter);
      });

      test('bottom maps to Alignment.bottomCenter', () {
        expect(Placement.bottom.toAlignment, Alignment.bottomCenter);
      });

      test('left maps to Alignment.centerLeft', () {
        expect(Placement.left.toAlignment, Alignment.centerLeft);
      });

      test('right maps to Alignment.centerRight', () {
        expect(Placement.right.toAlignment, Alignment.centerRight);
      });

      test('center maps to Alignment.center', () {
        expect(Placement.center.toAlignment, Alignment.center);
      });
    });
  });
}

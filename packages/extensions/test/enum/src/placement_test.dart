// test/enum/src/placement_test.dart

import 'package:extensions/enum/src/placement.dart' show Placement;
import 'package:flutter/widgets.dart' show Alignment;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Placement', () {
    test('isHorizontal is true only for left and right', () {
      expect(Placement.left.isHorizontal, isTrue);
      expect(Placement.right.isHorizontal, isTrue);
      expect(Placement.top.isHorizontal, isFalse);
      expect(Placement.bottom.isHorizontal, isFalse);
      expect(Placement.center.isHorizontal, isFalse);
    });

    test('isVertical is true only for top and bottom', () {
      expect(Placement.top.isVertical, isTrue);
      expect(Placement.bottom.isVertical, isTrue);
      expect(Placement.left.isVertical, isFalse);
      expect(Placement.right.isVertical, isFalse);
      expect(Placement.center.isVertical, isFalse);
    });

    test('isCentered is true only for center', () {
      expect(Placement.center.isCentered, isTrue);
      expect(Placement.top.isCentered, isFalse);
      expect(Placement.bottom.isCentered, isFalse);
      expect(Placement.left.isCentered, isFalse);
      expect(Placement.right.isCentered, isFalse);
    });

    test('toAlignment maps every value to its documented Alignment', () {
      expect(Placement.top.toAlignment, Alignment.topCenter);
      expect(Placement.bottom.toAlignment, Alignment.bottomCenter);
      expect(Placement.left.toAlignment, Alignment.centerLeft);
      expect(Placement.right.toAlignment, Alignment.centerRight);
      expect(Placement.center.toAlignment, Alignment.center);
    });
  });
}

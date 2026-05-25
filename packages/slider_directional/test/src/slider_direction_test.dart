// packages/slider_directional/test/src/slider_direction_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_directional/slider_directional.dart';

void main() {
  group('SliderDirection', () {
    group('isHorizontal', () {
      test('is true for left', () {
        expect(SliderDirection.left.isHorizontal, isTrue);
      });

      test('is true for right', () {
        expect(SliderDirection.right.isHorizontal, isTrue);
      });

      test('is false for top', () {
        expect(SliderDirection.top.isHorizontal, isFalse);
      });

      test('is false for bottom', () {
        expect(SliderDirection.bottom.isHorizontal, isFalse);
      });
    });

    group('isVertical', () {
      test('is false for left', () {
        expect(SliderDirection.left.isVertical, isFalse);
      });

      test('is false for right', () {
        expect(SliderDirection.right.isVertical, isFalse);
      });

      test('is true for top', () {
        expect(SliderDirection.top.isVertical, isTrue);
      });

      test('is true for bottom', () {
        expect(SliderDirection.bottom.isVertical, isTrue);
      });
    });

    group('axis', () {
      test('is Axis.horizontal for left', () {
        expect(SliderDirection.left.axis, Axis.horizontal);
      });

      test('is Axis.horizontal for right', () {
        expect(SliderDirection.right.axis, Axis.horizontal);
      });

      test('is Axis.vertical for top', () {
        expect(SliderDirection.top.axis, Axis.vertical);
      });

      test('is Axis.vertical for bottom', () {
        expect(SliderDirection.bottom.axis, Axis.vertical);
      });
    });

    group('isReversed', () {
      test('is false for left (natural reading direction)', () {
        expect(SliderDirection.left.isReversed, isFalse);
      });

      test('is true for right (opposite of natural)', () {
        expect(SliderDirection.right.isReversed, isTrue);
      });

      test('is true for top (opposite of chart Y-axis natural)', () {
        expect(SliderDirection.top.isReversed, isTrue);
      });

      test('is false for bottom (chart Y-axis natural)', () {
        expect(SliderDirection.bottom.isReversed, isFalse);
      });
    });
  });
}

// packages/prism_bubble_widget/test/src/bubble_animation_enum_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/src/bubble_animation_enum.dart';

void main() {
  group('BubbleAnimationEnum', () {
    test('contains all expected enum values in order', () {
      expect(
        BubbleAnimationEnum.values,
        equals([
          BubbleAnimationEnum.breathing,
          BubbleAnimationEnum.liquidRotation,
          BubbleAnimationEnum.combined,
        ]),
      );
    });

    test('verifies enum values and names', () {
      expect(BubbleAnimationEnum.breathing.name, equals('breathing'));
      expect(
        BubbleAnimationEnum.liquidRotation.name,
        equals('liquidRotation'),
      );
      expect(BubbleAnimationEnum.combined.name, equals('combined'));
    });
  });
}

// animated_widgets/test/src/combination_animation/extensions/combination_animation_extension_coverage_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CombinationAnimationX', () {
    const child = SizedBox(key: Key('child'));

    test('combinationAnimation wraps the receiver in a CombinationAnimation', () {
      final wrapped = child.combinationAnimation(scale: AnimationTween.up());

      expect(wrapped, isA<CombinationAnimation>());
      expect((wrapped as CombinationAnimation).child, same(child));
    });

    test('combinationAnimationSequenced wraps it in a CombinationAnimationSequenced', () {
      final wrapped = child.combinationAnimationSequenced(
        [CombinationAnimationStep(scale: AnimationTween.up())],
      );

      expect(wrapped, isA<CombinationAnimationSequenced>());
      expect((wrapped as CombinationAnimationSequenced).child, same(child));
    });
  });
}

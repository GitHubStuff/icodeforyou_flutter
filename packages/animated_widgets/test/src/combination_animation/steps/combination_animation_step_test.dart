// test/src/combination_animation/steps/combination_animation_step_test.dart

import 'package:animated_widgets/src/combination_animation/steps/combination_animation_step.dart';
import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AnimationTween buildTween({double start = 0, double finish = 1}) {
    return AnimationTween(start: start, finish: finish);
  }

  const shortDuration = Duration(milliseconds: 100);
  const longDuration = Duration(milliseconds: 200);

  group('CombinationAnimationStep', () {
    test('props lists scale, opacity, duration and curve in order', () {
      final scale = buildTween();
      final opacity = buildTween(finish: 0.5);

      final step = CombinationAnimationStep(
        scale: scale,
        opacity: opacity,
        duration: longDuration,
        curve: Curves.easeInOut,
      );

      expect(
        step.props,
        <Object?>[scale, opacity, longDuration, Curves.easeInOut],
      );
    });

    test('carries a null opacity into props when omitted', () {
      final scale = buildTween();

      final step = CombinationAnimationStep(
        scale: scale,
        duration: longDuration,
        curve: Curves.linear,
      );

      expect(step.props, <Object?>[scale, null, longDuration, Curves.linear]);
    });

    test('two steps with identical fields are equal', () {
      final scale = buildTween();
      final opacity = buildTween(finish: 0.5);

      final first = CombinationAnimationStep(
        scale: scale,
        opacity: opacity,
        duration: longDuration,
        curve: Curves.easeIn,
      );
      final second = CombinationAnimationStep(
        scale: scale,
        opacity: opacity,
        duration: longDuration,
        curve: Curves.easeIn,
      );

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
    });

    test('steps differing only by duration are not equal', () {
      final scale = buildTween();

      final first = CombinationAnimationStep(
        scale: scale,
        duration: shortDuration,
        curve: Curves.easeIn,
      );
      final second = CombinationAnimationStep(
        scale: scale,
        duration: longDuration,
        curve: Curves.easeIn,
      );

      expect(first, isNot(equals(second)));
    });
  });
}

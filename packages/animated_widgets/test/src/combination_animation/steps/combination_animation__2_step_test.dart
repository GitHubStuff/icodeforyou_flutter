// packages/animated_widgets/test/src/combination_animation/steps/combination_animation_step_test.dart

import 'package:animated_widgets/src/combination_animation/constants/combination_animation_constants.dart'
    show
        kCombinationAnimationDefaultCurve,
        kCombinationAnimationDefaultDuration;
import 'package:animated_widgets/src/combination_animation/steps/combination_animation_step.dart'
    show CombinationAnimationStep;
import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart'
    show AnimationTween;
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CombinationAnimationStep', () {
    group('construction', () {
      test('falls back to AnimationTween.none when scale is omitted', () {
        const step = CombinationAnimationStep();

        expect(step.scaling, AnimationTween.none);
        expect(step.opacity, isNull);
        expect(step.duration, kCombinationAnimationDefaultDuration);
        expect(step.curve, kCombinationAnimationDefaultCurve);
        expect(step.onComplete, isNull);
      });

      test('assigns the provided scale to scaling', () {
        const step = CombinationAnimationStep(scale: AnimationTween.none);

        expect(step.scaling, AnimationTween.none);
      });

      test('retains every explicitly provided property', () {
        const duration = Duration(milliseconds: 750);
        const curve = Curves.easeInOut;

        const step = CombinationAnimationStep(
          opacity: AnimationTween.none,
          duration: duration,
          curve: curve,
        );

        expect(step.opacity, AnimationTween.none);
        expect(step.duration, duration);
        expect(step.curve, curve);
      });

      test('stores onComplete and invokes it on demand', () {
        var called = false;
        final step = CombinationAnimationStep(onComplete: () => called = true);

        step.onComplete?.call();

        expect(called, isTrue);
      });
    });

    group('value equality', () {
      test('props lists scaling, opacity, duration and curve in order', () {
        const step = CombinationAnimationStep(opacity: AnimationTween.none);

        expect(step.props, <Object?>[
          step.scaling,
          step.opacity,
          step.duration,
          step.curve,
        ]);
      });

      test('two steps with identical value props compare equal', () {
        const a = CombinationAnimationStep();
        const b = CombinationAnimationStep();

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('excludes onComplete so differing callbacks stay equal', () {
        final a = CombinationAnimationStep(onComplete: () {});
        final b = CombinationAnimationStep(onComplete: () {});

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('differs when opacity differs', () {
        const withOpacity = CombinationAnimationStep(
          opacity: AnimationTween.none,
        );
        const withoutOpacity = CombinationAnimationStep();

        expect(withOpacity, isNot(withoutOpacity));
      });

      test('differs when duration differs', () {
        const fast = CombinationAnimationStep(
          duration: Duration(milliseconds: 100),
        );
        const slow = CombinationAnimationStep(duration: Duration(seconds: 1));

        expect(fast, isNot(slow));
      });

      test('differs when curve differs', () {
        const linear = CombinationAnimationStep(curve: Curves.linear);
        const eased = CombinationAnimationStep(curve: Curves.easeIn);

        expect(linear, isNot(eased));
      });
    });
  });
}

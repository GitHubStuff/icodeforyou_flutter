// packages/animated_widgets/test/src/combination_animation/extensions/animates_widget_test.dart

import 'package:animated_widgets/src/combination_animation/extensions/animates_widget.dart'
    show
        AnimatedSteps,
        AnimatesWidgetExt,
        AnimationSequence,
        CombinationAnimationSequenced;
import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart'
    show AnimationTween;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Widget target = SizedBox(key: Key('target'));

  group('AnimatesWidgetExt', () {
    test('animatedSteps yields one step', () {
      final AnimatedSteps result = target.animatedSteps();

      expect(result, isA<AnimatedSteps>());
      expect(result.steps, hasLength(1));
    });

    test('animatedSteps applies overrides', () {
      final AnimatedSteps result = target.animatedSteps(
        scale: AnimationTween.none,
        opacity: AnimationTween.none,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeIn,
        onComplete: () {},
      );

      expect(result.steps, hasLength(1));
    });

    test('animationSequence yields one step', () {
      final AnimationSequence result = target.animationSequence();

      expect(result, isA<AnimationSequence>());
      expect(result.steps, hasLength(1));
    });

    test('combinationAnimationSequenced wraps the child', () {
      final AnimatedSteps source = target.animatedSteps();

      final Widget result = target.combinationAnimationSequenced(
        source.steps,
        onComplete: () {},
        key: const Key('sequenced'),
      );

      expect(result, isA<CombinationAnimationSequenced>());
      expect(result.key, const Key('sequenced'));
    });
  });

  group('AnimatedSteps', () {
    test('step appends without mutating the original', () {
      final AnimatedSteps one = target.animatedSteps();
      final AnimatedSteps two = one.step(
        scale: AnimationTween.none,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
        onComplete: () {},
      );

      expect(one.steps, hasLength(1));
      expect(two.steps, hasLength(2));
      expect(identical(one, two), isFalse);
    });

    testWidgets('build mounts the sequenced widget', (tester) async {
      final AnimatedSteps widget = target.animatedSteps(
        duration: const Duration(milliseconds: 10),
      );

      await tester.pumpWidget(MaterialApp(home: widget));

      expect(find.byType(CombinationAnimationSequenced), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });

  group('AnimationSequence', () {
    test('step appends without mutating the original', () {
      final AnimationSequence one = target.animationSequence();
      final AnimationSequence two = one.step(
        opacity: AnimationTween.none,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
        onComplete: () {},
      );

      expect(one.steps, hasLength(1));
      expect(two.steps, hasLength(2));
      expect(identical(one, two), isFalse);
    });

    test('animate returns the sequenced widget', () {
      final Widget result = target
          .animationSequence()
          .step(duration: const Duration(milliseconds: 10))
          .animate(key: const Key('sequence'));

      expect(result, isA<CombinationAnimationSequenced>());
      expect(result.key, const Key('sequence'));
    });
  });
}

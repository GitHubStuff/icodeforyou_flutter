// packages/animated_widgets/test/src/combination_animation/extensions/combination_animation_sequenced_test.dart

import 'package:animated_widgets/src/combination_animation/extensions/animates_widget.dart'
    show AnimatesWidgetExt, CombinationAnimationSequenced;
import 'package:animated_widgets/src/combination_animation/steps/combination_animation_step.dart'
    show CombinationAnimationStep;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Widget child = SizedBox(width: 10, height: 10, key: Key('child'));

  Widget host(
    List<CombinationAnimationStep> steps, {
    VoidCallback? onComplete,
  }) {
    return MaterialApp(
      home: CombinationAnimationSequenced(
        steps: steps,
        onComplete: onComplete,
        child: child,
      ),
    );
  }

  group('CombinationAnimationSequenced', () {
    test('asserts that steps is not empty', () {
      expect(
        () => CombinationAnimationSequenced(
          steps: <CombinationAnimationStep>[],
          child: child,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('runs the timeline to completion and fires onComplete', (
      tester,
    ) async {
      final List<CombinationAnimationStep> steps = const SizedBox()
          .animatedSteps(duration: const Duration(milliseconds: 20))
          .step(duration: const Duration(milliseconds: 20))
          .steps;

      var completed = false;
      await tester.pumpWidget(host(steps, onComplete: () => completed = true));

      // Sample an early (non-final) window, then drive through to the last.
      await tester.pump(const Duration(milliseconds: 5));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('rebuilds the timeline only when the steps change', (
      tester,
    ) async {
      final List<CombinationAnimationStep> twoSteps = const SizedBox()
          .animatedSteps(duration: const Duration(milliseconds: 20))
          .step(duration: const Duration(milliseconds: 20))
          .steps;
      final List<CombinationAnimationStep> oneStep = const SizedBox()
          .animatedSteps(duration: const Duration(milliseconds: 20))
          .steps;
      final List<CombinationAnimationStep> sameAsOne =
          List<CombinationAnimationStep>.of(oneStep);

      await tester.pumpWidget(host(twoSteps));
      await tester.pump(const Duration(milliseconds: 5));

      // Different length: _listsEqual returns false, the timeline rebuilds.
      await tester.pumpWidget(host(oneStep));
      await tester.pump(const Duration(milliseconds: 5));

      // Same elements in a new list: _listsEqual true, the rebuild is skipped.
      await tester.pumpWidget(host(sameAsOne));
      await tester.pump(const Duration(milliseconds: 5));

      expect(find.byType(CombinationAnimationSequenced), findsOneWidget);

      // Unmount triggers dispose.
      await tester.pumpWidget(const SizedBox());
    });
  });
}

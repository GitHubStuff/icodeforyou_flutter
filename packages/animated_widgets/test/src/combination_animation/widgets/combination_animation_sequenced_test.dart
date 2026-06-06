// test/src/combination_animation/widgets/combination_animation_sequenced_test.dart

import 'package:animated_widgets/src/combination_animation/steps/combination_animation_step.dart';
import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart';
import 'package:animated_widgets/src/combination_animation/widgets/combination_animation_sequenced.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _stepDuration = Duration(milliseconds: 100);

void main() {
  CombinationAnimationStep buildStep({
    Duration duration = _stepDuration,
    double scaleStart = 0,
    double scaleFinish = 1,
    AnimationTween? opacity,
    Curve curve = Curves.linear,
  }) {
    return CombinationAnimationStep(
      scale: AnimationTween(start: scaleStart, finish: scaleFinish),
      opacity: opacity,
      duration: duration,
      curve: curve,
    );
  }

  Widget buildSubject({
    required List<CombinationAnimationStep> steps,
    VoidCallback? onComplete,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CombinationAnimationSequenced(
        steps: steps,
        onComplete: onComplete,
        child: const SizedBox(width: 100, height: 100),
      ),
    );
  }

  group('CombinationAnimationSequenced', () {
    testWidgets('asserts when steps is empty', (tester) async {
      expect(
        () => CombinationAnimationSequenced(
          steps: const <CombinationAnimationStep>[],
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets(
      'runs every window of the timeline and fires onComplete',
      (tester) async {
        var completed = false;

        await tester.pumpWidget(
          buildSubject(
            steps: [
              buildStep(scaleFinish: 1),
              buildStep(scaleStart: 1, scaleFinish: 0, curve: Curves.easeIn),
            ],
            onComplete: () => completed = true,
          ),
        );

        // Land a frame inside the first window, then inside the last window,
        // so both the loop hit and the terminal return are exercised.
        await tester.pump(const Duration(milliseconds: 40));
        await tester.pump(const Duration(milliseconds: 120));
        await tester.pumpAndSettle();

        expect(completed, isTrue);
      },
    );

    testWidgets('completes without an onComplete callback', (tester) async {
      await tester.pumpWidget(buildSubject(steps: [buildStep()]));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('treats an all-zero-duration timeline as a unit span', (
      tester,
    ) async {
      var completed = false;

      await tester.pumpWidget(
        buildSubject(
          steps: [buildStep(duration: Duration.zero)],
          onComplete: () => completed = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('restarts the timeline when a step value changes', (
      tester,
    ) async {
      var completions = 0;

      await tester.pumpWidget(
        buildSubject(
          steps: [buildStep(), buildStep(scaleStart: 1, scaleFinish: 0)],
          onComplete: () => completions++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        buildSubject(
          steps: [buildStep(), buildStep(scaleStart: 1, scaleFinish: 0.5)],
          onComplete: () => completions++,
        ),
      );
      await tester.pumpAndSettle();

      expect(completions, 2);
    });

    testWidgets('restarts the timeline when the step count changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(steps: [buildStep(), buildStep()]),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(buildSubject(steps: [buildStep()]));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not restart when an equal step list is supplied', (
      tester,
    ) async {
      var completions = 0;

      await tester.pumpWidget(
        buildSubject(
          steps: [buildStep(), buildStep(scaleStart: 1, scaleFinish: 0)],
          onComplete: () => completions++,
        ),
      );
      await tester.pumpAndSettle();

      // A fresh list whose elements are value-equal to the previous run.
      await tester.pumpWidget(
        buildSubject(
          steps: [buildStep(), buildStep(scaleStart: 1, scaleFinish: 0)],
          onComplete: () => completions++,
        ),
      );
      await tester.pump();

      expect(completions, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes the controller when removed', (tester) async {
      await tester.pumpWidget(buildSubject(steps: [buildStep()]));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());

      expect(tester.takeException(), isNull);
    });
  });
}

// packages/widget_animation_framework/test/src/animation_combiner_on_widget/animation_controller_widget_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_animation_framework/src/animation_combiner_on_widget/animation_controller_widget.dart';

void main() {
  group('AnimationControllerWidget', () {
    Widget harness({
      required Duration duration,
      required Curve curve,
      required VoidCallback onCompleted,
      required ValueChanged<Animation<double>> capture,
    }) {
      return AnimationControllerWidget(
        duration: duration,
        curve: curve,
        onCompleted: onCompleted,
        builder: (context, animation) {
          capture(animation);
          return const SizedBox.shrink();
        },
      );
    }

    testWidgets('plays forward once on mount and reports completion once', (
      tester,
    ) async {
      var completions = 0;
      late Animation<double> animation;

      await tester.pumpWidget(
        harness(
          duration: const Duration(seconds: 1),
          curve: Curves.linear,
          onCompleted: () => completions++,
          capture: (a) => animation = a,
        ),
      );

      expect(animation.value, 0);
      expect(animation.status, AnimationStatus.forward);

      await tester.pump(const Duration(milliseconds: 500));
      expect(animation.value, closeTo(0.5, 0.001));
      expect(completions, 0);

      await tester.pump(const Duration(milliseconds: 600));
      expect(animation.value, 1);
      expect(animation.status, AnimationStatus.completed);
      expect(completions, 1);

      await tester.pump(const Duration(seconds: 1));
      expect(completions, 1);
    });

    testWidgets('changing curve re-eases the live timeline mid-flight', (
      tester,
    ) async {
      late Animation<double> animation;

      await tester.pumpWidget(
        harness(
          duration: const Duration(seconds: 1),
          curve: Curves.linear,
          onCompleted: () {},
          capture: (a) => animation = a,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(animation.value, closeTo(0.5, 0.001));

      await tester.pumpWidget(
        harness(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInExpo,
          onCompleted: () {},
          capture: (a) => animation = a,
        ),
      );

      // expect(animation.value, closeTo(0.03125, 0.001));
      expect(
        animation.value,
        closeTo(Curves.easeInExpo.transform(0.5), 0.001),
      );
    });

    testWidgets('changing duration retargets the next run only', (
      tester,
    ) async {
      var completions = 0;
      late Animation<double> animation;

      await tester.pumpWidget(
        harness(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
          onCompleted: () => completions++,
          capture: (a) => animation = a,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(
        harness(
          duration: const Duration(seconds: 10),
          curve: Curves.linear,
          onCompleted: () => completions++,
          capture: (a) => animation = a,
        ),
      );

      await tester.pump(const Duration(milliseconds: 250));
      expect(animation.status, AnimationStatus.completed);
      expect(completions, 1);
    });

    testWidgets('identical rebuild swaps the completion callback in place', (
      tester,
    ) async {
      var oldCompletions = 0;
      var newCompletions = 0;
      late Animation<double> animation;

      await tester.pumpWidget(
        harness(
          duration: const Duration(seconds: 1),
          curve: Curves.linear,
          onCompleted: () => oldCompletions++,
          capture: (a) => animation = a,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.pumpWidget(
        harness(
          duration: const Duration(seconds: 1),
          curve: Curves.linear,
          onCompleted: () => newCompletions++,
          capture: (a) => animation = a,
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));
      expect(animation.status, AnimationStatus.completed);
      expect(oldCompletions, 0);
      expect(newCompletions, 1);
    });

    testWidgets('dispose cancels the timeline without reporting completion', (
      tester,
    ) async {
      var completions = 0;

      await tester.pumpWidget(
        harness(
          duration: const Duration(seconds: 1),
          curve: Curves.linear,
          onCompleted: () => completions++,
          capture: (_) {},
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));

      expect(completions, 0);
      expect(tester.takeException(), isNull);
    });
  });
}

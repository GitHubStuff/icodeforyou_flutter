// test/src/combination_animation/widgets/combination_animation_single_test.dart

import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart';
import 'package:animated_widgets/src/combination_animation/widgets/combination_animation_single.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _duration = Duration(milliseconds: 100);

void main() {
  Widget buildSubject({
    AnimationTween? scale,
    AnimationTween? opacity,
    Duration duration = _duration,
    Curve curve = Curves.linear,
    VoidCallback? onComplete,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CombinationAnimation(
        scale: scale ?? AnimationTween(start: 0, finish: 1),
        opacity: opacity,
        duration: duration,
        curve: curve,
        onComplete: onComplete,
        child: const SizedBox(width: 100, height: 100),
      ),
    );
  }

  group('CombinationAnimation', () {
    testWidgets('builds and ticks frames through the tween', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts a valid opacity tween', (tester) async {
      await tester.pumpWidget(
        buildSubject(opacity: AnimationTween(start: 0, finish: 1)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('fires onComplete when the tween ends', (tester) async {
      var completed = false;

      await tester.pumpWidget(
        buildSubject(onComplete: () => completed = true),
      );
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('asserts when the opacity tween leaves [0.0, 1.0]', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(opacity: AnimationTween(start: 0, finish: 1.5)),
      );

      expect(tester.takeException(), isA<AssertionError>());
    });
  });
}

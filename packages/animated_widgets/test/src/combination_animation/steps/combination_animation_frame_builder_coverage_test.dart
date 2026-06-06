// animated_widgets/test/src/combination_animation/steps/combination_animation_frame_builder_coverage_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildCombinationAnimationFrame', () {
    const child = SizedBox(key: Key('child'));

    test('omits Opacity and returns just the scaled child when opacity is null', () {
      final frame = buildCombinationAnimationFrame(
        t: 0.5,
        scale: AnimationTween.up(),
        opacity: null,
        child: child,
      );

      expect(frame, isA<Transform>());
      expect((frame as Transform).child, same(child));
    });

    test('wraps the scaled child in a clamped Opacity when opacity is given', () {
      final frame = buildCombinationAnimationFrame(
        t: 0.5,
        scale: AnimationTween.up(),
        // start/finish outside [0,1] proves the clamp actually clamps.
        opacity: const AnimationTween(start: 2, finish: 2),
        child: child,
      );

      expect(frame, isA<Opacity>());
      final opacity = frame as Opacity;
      expect(opacity.opacity, 1.0); // 2.0 lerped then clamped to the max
      expect(opacity.child, isA<Transform>());
    });
  });
}

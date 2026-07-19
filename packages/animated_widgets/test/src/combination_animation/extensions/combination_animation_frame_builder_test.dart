// packages/animated_widgets/test/src/combination_animation/extensions/combination_animation_frame_builder_test.dart

import 'package:animated_widgets/src/combination_animation/extensions/animates_widget.dart'
    show buildCombinationAnimationFrame;
import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart'
    show AnimationTween;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Widget child = SizedBox(key: Key('child'));

  group('buildCombinationAnimationFrame', () {
    test('returns a bare Transform when opacity is null', () {
      final Widget result = buildCombinationAnimationFrame(
        t: 0.5,
        scale: null,
        opacity: null,
        child: child,
      );

      expect(result, isA<Transform>());
    });

    test('clamps and wraps in Opacity when opacity is supplied', () {
      final Widget result = buildCombinationAnimationFrame(
        t: 0.5,
        scale: AnimationTween.none,
        opacity: AnimationTween.none,
        child: child,
      );

      expect(result, isA<Opacity>());

      final Opacity opacity = result as Opacity;
      expect(opacity.opacity, inInclusiveRange(0.0, 1.0));
      expect(opacity.child, isA<Transform>());
    });
  });
}

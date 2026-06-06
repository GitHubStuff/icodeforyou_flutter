// animated_widgets/test/src/combination_animation/tweens/animation_tween_coverage_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimationTween', () {
    test('default constructor stores start and finish', () {
      const tween = AnimationTween(start: 0.2, finish: 0.8);

      expect(tween.start, 0.2);
      expect(tween.finish, 0.8);
    });

    test('up() ascends 0.0 -> 1.0 by default', () {
      final tween = AnimationTween.up();

      expect(tween.start, 0.0);
      expect(tween.finish, 1.0);
    });

    test('down() descends 1.0 -> 0.0 by default', () {
      final tween = AnimationTween.down();

      expect(tween.start, 1.0);
      expect(tween.finish, 0.0);
    });

    test('isValidOpacity is true only when both ends sit within [0, 1]', () {
      expect(AnimationTween.up().isValidOpacity, isTrue);
      expect(const AnimationTween(start: 2, finish: 0.5).isValidOpacity, isFalse);
      expect(const AnimationTween(start: 0.5, finish: 2).isValidOpacity, isFalse);
    });

    test('lerp interpolates linearly between start and finish', () {
      const tween = AnimationTween(start: 0, finish: 10);

      expect(tween.lerp(0), 0.0);
      expect(tween.lerp(0.5), 5.0);
      expect(tween.lerp(1), 10.0);
    });

    test('value equality is driven by start and finish (props)', () {
      expect(AnimationTween.up(), const AnimationTween(start: 0, finish: 1));
      expect(AnimationTween.up() == AnimationTween.down(), isFalse);
      expect(AnimationTween.up().props, <Object?>[0.0, 1.0]);
    });
  });
}

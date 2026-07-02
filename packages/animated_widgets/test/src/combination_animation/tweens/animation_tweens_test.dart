// packages/animated_widgets/test/src/combination_animation/tweens/animation_tween_test.dart

import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart'
    show AnimationTween;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimationTween', () {
    group('construction', () {
      test('default constructor stores start and finish', () {
        const tween = AnimationTween(start: 0.25, finish: 0.75);

        expect(tween.start, 0.25);
        expect(tween.finish, 0.75);
      });

      test('up defaults to the ascending 0 -> 1 range', () {
        final tween = AnimationTween.up();

        expect(tween.start, 0.0);
        expect(tween.finish, 1.0);
      });

      test('up honours an explicit ascending range', () {
        final tween = AnimationTween.up(start: 0.2, finish: 0.8);

        expect(tween.start, 0.2);
        expect(tween.finish, 0.8);
      });

      test('down defaults to the descending 1 -> 0 range', () {
        final tween = AnimationTween.down();

        expect(tween.start, 1.0);
        expect(tween.finish, 0.0);
      });

      test('down honours an explicit descending range', () {
        final tween = AnimationTween.down(start: 0.9, finish: 0.1);

        expect(tween.start, 0.9);
        expect(tween.finish, 0.1);
      });

      test('none is the identity tween 1 -> 1', () {
        expect(AnimationTween.none.start, 1.0);
        expect(AnimationTween.none.finish, 1.0);
      });
    });

    group('lerp', () {
      test('yields start at t == 0', () {
        const tween = AnimationTween(start: 0, finish: 1);

        expect(tween.lerp(0), 0.0);
      });

      test('yields finish at t == 1', () {
        const tween = AnimationTween(start: 0, finish: 1);

        expect(tween.lerp(1), 1.0);
      });

      test('interpolates linearly at the midpoint', () {
        const tween = AnimationTween(start: 0, finish: 1);

        expect(tween.lerp(0.5), 0.5);
      });

      test('extrapolates for t outside the [0, 1] range', () {
        const tween = AnimationTween(start: 0, finish: 1);

        expect(tween.lerp(2), 2.0);
      });
    });

    group('isNormalized', () {
      test('is true when both bounds lie within [0, 1]', () {
        const tween = AnimationTween(start: 0, finish: 1);

        expect(tween.isNormalized, isTrue);
      });

      test('is false when start falls below 0', () {
        const tween = AnimationTween(start: -0.1, finish: 1);

        expect(tween.isNormalized, isFalse);
      });

      test('is false when finish rises above 1', () {
        const tween = AnimationTween(start: 0, finish: 1.1);

        expect(tween.isNormalized, isFalse);
      });
    });

    group('debugAssertNormalized', () {
      test('returns true for a null tween', () {
        expect(AnimationTween.debugAssertNormalized(null), isTrue);
      });

      test('returns true for a normalized tween', () {
        expect(
          AnimationTween.debugAssertNormalized(AnimationTween.none),
          isTrue,
        );
      });

      test('asserts and names start when start is out of range', () {
        expect(
          () => AnimationTween.debugAssertNormalized(
            const AnimationTween(start: 2, finish: 1),
          ),
          throwsA(
            isA<AssertionError>().having(
              (error) => error.message.toString(),
              'message',
              contains('start is invalid: 2.0'),
            ),
          ),
        );
      });

      test('asserts and names finish when finish is out of range', () {
        expect(
          () => AnimationTween.debugAssertNormalized(
            const AnimationTween(start: 1, finish: 2),
          ),
          throwsA(
            isA<AssertionError>().having(
              (error) => error.message.toString(),
              'message',
              contains('finish is invalid: 2.0'),
            ),
          ),
        );
      });

      test('asserts and names both bounds when both are out of range', () {
        expect(
          () => AnimationTween.debugAssertNormalized(
            const AnimationTween(start: -1, finish: 2),
          ),
          throwsA(
            isA<AssertionError>().having(
              (error) => error.message.toString(),
              'message',
              allOf(
                contains('start is invalid: -1.0'),
                contains('finish is invalid: 2.0'),
              ),
            ),
          ),
        );
      });
    });

    group('value equality', () {
      test('props lists start and finish in order', () {
        const tween = AnimationTween(start: 0.3, finish: 0.7);

        expect(tween.props, <Object?>[0.3, 0.7]);
      });

      test('tweens with identical bounds compare equal', () {
        const a = AnimationTween(start: 0, finish: 1);
        const b = AnimationTween(start: 0, finish: 1);

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('tweens with differing bounds compare unequal', () {
        const a = AnimationTween(start: 0, finish: 1);
        const b = AnimationTween(start: 0, finish: 0.5);

        expect(a, isNot(b));
      });
    });
  });
}

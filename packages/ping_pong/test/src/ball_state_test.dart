// packages/ping_pong/test/src/ball_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong/src/ball_spec.dart';
import 'package:ping_pong/src/ball_state.dart';

void main() {
  const spec = BallSpec(radius: 10, speed: 50);

  BallState ballAt(Offset center, {int index = 0, double radius = 10}) =>
      BallState(
        index: index,
        spec: BallSpec(radius: radius, speed: 50),
        center: center,
        velocity: Offset.zero,
      );

  group('BallState', () {
    test('exposes its fields', () {
      const state = BallState(
        index: 3,
        spec: spec,
        center: Offset(1, 2),
        velocity: Offset(3, 4),
      );

      expect(state.index, 3);
      expect(state.spec, spec);
      expect(state.center, const Offset(1, 2));
      expect(state.velocity, const Offset(3, 4));
    });

    test('delegates radius and speed to its spec', () {
      const state = BallState(
        index: 0,
        spec: spec,
        center: Offset.zero,
        velocity: Offset.zero,
      );

      expect(state.radius, spec.radius);
      expect(state.speed, spec.speed);
    });

    group('copyWith', () {
      const original = BallState(
        index: 7,
        spec: spec,
        center: Offset(1, 1),
        velocity: Offset(2, 2),
      );

      test('replaces center only', () {
        final copy = original.copyWith(center: const Offset(9, 9));

        expect(copy.center, const Offset(9, 9));
        expect(copy.velocity, original.velocity);
        expect(copy.index, original.index);
        expect(copy.spec, original.spec);
      });

      test('replaces velocity only', () {
        final copy = original.copyWith(velocity: const Offset(9, 9));

        expect(copy.velocity, const Offset(9, 9));
        expect(copy.center, original.center);
        expect(copy.index, original.index);
        expect(copy.spec, original.spec);
      });

      test('with no arguments returns an equal state', () {
        expect(original.copyWith(), equals(original));
      });
    });

    group('overlaps', () {
      test('is true when circles intersect', () {
        final a = ballAt(Offset.zero);
        final b = ballAt(const Offset(15, 0), index: 1);

        expect(a.overlaps(b), isTrue);
        expect(b.overlaps(a), isTrue);
      });

      test('is false when circles are exactly touching', () {
        final a = ballAt(Offset.zero);
        final b = ballAt(const Offset(20, 0), index: 1);

        expect(a.overlaps(b), isFalse);
      });

      test('is false when circles are apart', () {
        final a = ballAt(Offset.zero);
        final b = ballAt(const Offset(30, 0), index: 1);

        expect(a.overlaps(b), isFalse);
      });

      test('accounts for differing radii', () {
        final a = ballAt(Offset.zero, radius: 5);
        final b = ballAt(const Offset(14, 0), index: 1);

        expect(a.overlaps(b), isTrue);
      });

      test('is true for concentric circles', () {
        final a = ballAt(Offset.zero);
        final b = ballAt(Offset.zero, index: 1);

        expect(a.overlaps(b), isTrue);
      });
    });

    group('equality', () {
      const state = BallState(
        index: 1,
        spec: spec,
        center: Offset(1, 2),
        velocity: Offset(3, 4),
      );

      test('is equal to a state with the same values', () {
        const same = BallState(
          index: 1,
          spec: spec,
          center: Offset(1, 2),
          velocity: Offset(3, 4),
        );

        expect(state, equals(same));
        expect(state.hashCode, equals(same.hashCode));
      });

      test('differs when index differs', () {
        expect(
          state,
          isNot(
            equals(
              const BallState(
                index: 2,
                spec: spec,
                center: Offset(1, 2),
                velocity: Offset(3, 4),
              ),
            ),
          ),
        );
      });

      test('differs when spec differs', () {
        expect(
          state,
          isNot(
            equals(
              const BallState(
                index: 1,
                spec: BallSpec(radius: 11, speed: 50),
                center: Offset(1, 2),
                velocity: Offset(3, 4),
              ),
            ),
          ),
        );
      });

      test('differs when center differs', () {
        expect(
          state,
          isNot(equals(state.copyWith(center: Offset.zero))),
        );
      });

      test('differs when velocity differs', () {
        expect(
          state,
          isNot(equals(state.copyWith(velocity: Offset.zero))),
        );
      });

      test('props lists index, spec, center, velocity', () {
        expect(
          state.props,
          [1, spec, const Offset(1, 2), const Offset(3, 4)],
        );
      });
    });
  });
}

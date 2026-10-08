// packages/ping_pong/test/src/ball_spec_test.dart

import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/ball_spec.dart' show BallSpec;

void main() {
  group('BallSpec', () {
    test('exposes radius and speed', () {
      const spec = BallSpec(radius: 10, speed: 50);

      expect(spec.radius, 10);
      expect(spec.speed, 50);
    });

    test('allows zero speed', () {
      const spec = BallSpec(radius: 10, speed: 0);

      expect(spec.speed, 0);
    });

    test('is equal to a spec with the same values', () {
      const a = BallSpec(radius: 10, speed: 50);
      const b = BallSpec(radius: 10, speed: 50);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('differs when radius differs', () {
      const a = BallSpec(radius: 10, speed: 50);
      const b = BallSpec(radius: 11, speed: 50);

      expect(a, isNot(equals(b)));
    });

    test('differs when speed differs', () {
      const a = BallSpec(radius: 10, speed: 50);
      const b = BallSpec(radius: 10, speed: 51);

      expect(a, isNot(equals(b)));
    });

    test('props lists radius then speed', () {
      const spec = BallSpec(radius: 10, speed: 50);

      expect(spec.props, [10.0, 50.0]);
    });

    test('rejects a zero radius', () {
      expect(
        () => BallSpec(radius: 0, speed: 50),
        throwsAssertionError,
      );
    });

    test('rejects a negative radius', () {
      expect(
        () => BallSpec(radius: -1, speed: 50),
        throwsAssertionError,
      );
    });

    test('rejects a negative speed', () {
      expect(
        () => BallSpec(radius: 10, speed: -1),
        throwsAssertionError,
      );
    });
  });
}

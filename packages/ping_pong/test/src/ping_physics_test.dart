// packages/ping_pong/test/src/ping_physics_test.dart

import 'dart:ui' show Offset, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong/src/ball_spec.dart';
import 'package:ping_pong/src/ball_state.dart';
import 'package:ping_pong/src/ping_physics.dart';

import '../helpers/fake_random.dart';

BallState ball({
  int index = 0,
  double radius = 10,
  double speed = 50,
  Offset center = Offset.zero,
  Offset velocity = Offset.zero,
}) => BallState(
  index: index,
  spec: BallSpec(radius: radius, speed: speed),
  center: center,
  velocity: velocity,
);

void expectOffset(Offset actual, Offset expected) {
  expect(actual.dx, closeTo(expected.dx, 1e-9));
  expect(actual.dy, closeTo(expected.dy, 1e-9));
}

void main() {
  const physics = PingPhysics();
  const bounds = Size(100, 100);

  group('move', () {
    final moving = ball(
      center: const Offset(10, 20),
      velocity: const Offset(30, -40),
    );

    test('with zero delta leaves the ball where it is', () {
      final moved = physics.move(moving, Duration.zero);

      expect(moved.center, moving.center);
    });

    test('after one second moves by the velocity', () {
      final moved = physics.move(moving, const Duration(seconds: 1));

      expectOffset(moved.center, const Offset(40, -20));
    });

    test('after half a second moves by half the velocity', () {
      final moved = physics.move(moving, const Duration(milliseconds: 500));

      expectOffset(moved.center, const Offset(25, 0));
    });

    test('does not change velocity', () {
      final moved = physics.move(moving, const Duration(seconds: 1));

      expect(moved.velocity, moving.velocity);
    });
  });

  group('reflectOffWalls', () {
    test('leaves a ball inside the bounds untouched', () {
      final inside = ball(
        center: const Offset(50, 50),
        velocity: const Offset(30, 30),
      );

      final result = physics.reflectOffWalls(inside, bounds);

      expect(result.hitWall, isFalse);
      expect(result.ball, same(inside));
    });

    test('treats touching a wall as inside', () {
      final touching = ball(
        center: const Offset(10, 10),
        velocity: const Offset(-30, -30),
      );

      final result = physics.reflectOffWalls(touching, bounds);

      expect(result.hitWall, isFalse);
    });

    test('reflects off the left wall', () {
      final crossed = ball(
        center: const Offset(5, 50),
        velocity: const Offset(-30, 0),
      );

      final result = physics.reflectOffWalls(crossed, bounds);

      expect(result.hitWall, isTrue);
      expect(result.ball.center, const Offset(10, 50));
      expect(result.ball.velocity, const Offset(30, 0));
    });

    test('reflects off the right wall', () {
      final crossed = ball(
        center: const Offset(95, 50),
        velocity: const Offset(30, 0),
      );

      final result = physics.reflectOffWalls(crossed, bounds);

      expect(result.hitWall, isTrue);
      expect(result.ball.center, const Offset(90, 50));
      expect(result.ball.velocity, const Offset(-30, 0));
    });

    test('reflects off the top wall', () {
      final crossed = ball(
        center: const Offset(50, 5),
        velocity: const Offset(0, -30),
      );

      final result = physics.reflectOffWalls(crossed, bounds);

      expect(result.hitWall, isTrue);
      expect(result.ball.center, const Offset(50, 10));
      expect(result.ball.velocity, const Offset(0, 30));
    });

    test('reflects off the bottom wall', () {
      final crossed = ball(
        center: const Offset(50, 95),
        velocity: const Offset(0, 30),
      );

      final result = physics.reflectOffWalls(crossed, bounds);

      expect(result.hitWall, isTrue);
      expect(result.ball.center, const Offset(50, 90));
      expect(result.ball.velocity, const Offset(0, -30));
    });

    test('reflects off two walls at a corner', () {
      final crossed = ball(
        center: const Offset(5, 5),
        velocity: const Offset(-30, -30),
      );

      final result = physics.reflectOffWalls(crossed, bounds);

      expect(result.hitWall, isTrue);
      expect(result.ball.center, const Offset(10, 10));
      expect(result.ball.velocity, const Offset(30, 30));
    });

    test('keeps the parallel velocity component unchanged', () {
      final crossed = ball(
        center: const Offset(5, 50),
        velocity: const Offset(-30, 17),
      );

      final result = physics.reflectOffWalls(crossed, bounds);

      expect(result.ball.velocity, const Offset(30, 17));
    });

    test('forces velocity inward even when already pointing inward', () {
      final crossed = ball(
        center: const Offset(5, 50),
        velocity: const Offset(30, 0),
      );

      final result = physics.reflectOffWalls(crossed, bounds);

      expect(result.hitWall, isTrue);
      expect(result.ball.center, const Offset(10, 50));
      expect(result.ball.velocity, const Offset(30, 0));
    });
  });

  group('resolveCollision', () {
    test('leaves balls that are apart untouched', () {
      final a = ball(velocity: const Offset(50, 0));
      final b = ball(
        index: 1,
        center: const Offset(30, 0),
        velocity: const Offset(-50, 0),
      );

      final result = physics.resolveCollision(a, b);

      expect(result.collided, isFalse);
      expect(result.first, same(a));
      expect(result.second, same(b));
    });

    test('swaps velocities in a head-on hit at equal speed', () {
      final a = ball(velocity: const Offset(50, 0));
      final b = ball(
        index: 1,
        center: const Offset(15, 0),
        velocity: const Offset(-50, 0),
      );

      final result = physics.resolveCollision(a, b);

      expect(result.collided, isTrue);
      expectOffset(result.first.velocity, const Offset(-50, 0));
      expectOffset(result.second.velocity, const Offset(50, 0));
    });

    test('pushes overlapping balls apart until they just touch', () {
      final a = ball(velocity: const Offset(50, 0));
      final b = ball(
        index: 1,
        center: const Offset(15, 0),
        velocity: const Offset(-50, 0),
      );

      final result = physics.resolveCollision(a, b);

      expectOffset(result.first.center, const Offset(-2.5, 0));
      expectOffset(result.second.center, const Offset(17.5, 0));
      expect(result.first.overlaps(result.second), isFalse);
    });

    test('keeps each ball at its own speed', () {
      final fast = ball(speed: 100, velocity: const Offset(100, 0));
      final slow = ball(
        index: 1,
        speed: 20,
        center: const Offset(15, 0),
        velocity: const Offset(-20, 0),
      );

      final result = physics.resolveCollision(fast, slow);

      expectOffset(result.first.velocity, const Offset(-100, 0));
      expectOffset(result.second.velocity, const Offset(20, 0));
    });

    test('deflects an oblique hit along the tangent', () {
      final mover = ball(velocity: const Offset(30, 40));
      final still = ball(
        index: 1,
        speed: 0,
        center: const Offset(15, 0),
      );

      final result = physics.resolveCollision(mover, still);

      expectOffset(result.first.velocity, const Offset(0, 50));
      expectOffset(result.second.velocity, Offset.zero);
    });

    test('reflects a head-on hit against a ball that cannot move', () {
      final mover = ball(velocity: const Offset(50, 0));
      final still = ball(
        index: 1,
        speed: 0,
        center: const Offset(15, 0),
      );

      final result = physics.resolveCollision(mover, still);

      expectOffset(result.first.velocity, const Offset(-50, 0));
      expectOffset(result.second.velocity, Offset.zero);
    });

    test('uses a horizontal normal for concentric balls', () {
      final a = ball(
        center: const Offset(10, 10),
        velocity: const Offset(50, 0),
      );
      final b = ball(
        index: 1,
        center: const Offset(10, 10),
        velocity: const Offset(-50, 0),
      );

      final result = physics.resolveCollision(a, b);

      expect(result.collided, isTrue);
      expectOffset(result.first.center, const Offset(0, 10));
      expectOffset(result.second.center, const Offset(20, 10));
      expectOffset(result.first.velocity, const Offset(-50, 0));
      expectOffset(result.second.velocity, const Offset(50, 0));
    });

    test('preserves index and spec of both balls', () {
      final a = ball(velocity: const Offset(50, 0));
      final b = ball(
        index: 1,
        radius: 12,
        speed: 30,
        center: const Offset(15, 0),
        velocity: const Offset(-30, 0),
      );

      final result = physics.resolveCollision(a, b);

      expect(result.first.index, 0);
      expect(result.first.spec, a.spec);
      expect(result.second.index, 1);
      expect(result.second.spec, b.spec);
    });
  });

  group('spawn', () {
    const spec = BallSpec(radius: 10, speed: 50);

    BallState? spawnWith(
      FakeRandom random, {
      Size bounds = const Size(100, 60),
      Iterable<BallState> others = const [],
      int retryCap = 25,
      bool motionless = false,
    }) => physics.spawn(
      index: 3,
      spec: spec,
      bounds: bounds,
      others: others,
      random: random,
      retryCap: retryCap,
      motionless: motionless,
    );

    test('returns null when the ball is wider than the bounds', () {
      final random = FakeRandom.constant(0.5);

      expect(spawnWith(random, bounds: const Size(15, 100)), isNull);
      expect(random.calls, 0);
    });

    test('returns null when the ball is taller than the bounds', () {
      final random = FakeRandom.constant(0.5);

      expect(spawnWith(random, bounds: const Size(100, 15)), isNull);
      expect(random.calls, 0);
    });

    test('places the centre within the free area', () {
      final random = FakeRandom([0.5, 0.25, 0]);

      final spawned = spawnWith(random);

      expect(spawned, isNotNull);
      expectOffset(spawned!.center, const Offset(50, 20));
    });

    test('fits a ball that exactly fills the bounds', () {
      final random = FakeRandom([0, 0, 0]);

      final spawned = spawnWith(random, bounds: const Size(20, 20));

      expect(spawned, isNotNull);
      expectOffset(spawned!.center, const Offset(10, 10));
    });

    test('carries the index and spec', () {
      final spawned = spawnWith(FakeRandom([0.5, 0.5, 0]));

      expect(spawned!.index, 3);
      expect(spawned.spec, spec);
    });

    test('gives a random direction at the spec speed', () {
      final random = FakeRandom([0.5, 0.5, 0.25]);

      final spawned = spawnWith(random);

      expectOffset(spawned!.velocity, const Offset(0, 50));
      expect(spawned.velocity.distance, closeTo(50, 1e-9));
    });

    test('spawns motionless without consuming an angle', () {
      final random = FakeRandom([0.5, 0.5]);

      final spawned = spawnWith(random, motionless: true);

      expect(spawned!.velocity, Offset.zero);
      expect(random.calls, 2);
    });

    test('retries when the position overlaps another ball', () {
      final blocker = ball(center: const Offset(50, 30));
      final random = FakeRandom([0.5, 0.5, 0, 0, 0, 0]);

      final spawned = spawnWith(random, others: [blocker]);

      expectOffset(spawned!.center, const Offset(10, 10));
      expect(random.calls, 6);
    });

    test('returns null once the retry cap is exhausted', () {
      final blocker = ball(center: const Offset(50, 30));
      final random = FakeRandom.constant(0.5);

      final spawned = spawnWith(random, others: [blocker], retryCap: 3);

      expect(spawned, isNull);
      expect(random.calls, 9);
    });

    test('returns null without trying when the retry cap is zero', () {
      final random = FakeRandom.constant(0.5);

      expect(spawnWith(random, retryCap: 0), isNull);
      expect(random.calls, 0);
    });
  });
}

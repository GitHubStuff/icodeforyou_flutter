// packages/ping_pong/test/src/ping_pong_controller_test.dart
import 'dart:math' show Random;
import 'dart:ui' show Offset, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong/src/arena_config.dart';
import 'package:ping_pong/src/ball_spec.dart';
import 'package:ping_pong/src/ball_state.dart';
import 'package:ping_pong/src/ball_too_large_error.dart';
import 'package:ping_pong/src/ping_physics.dart';
import 'package:ping_pong/src/ping_pong_controller.dart';

/// A scripted [PingPhysics] that lets each test decide whether spawns
/// succeed, walls are hit and balls collide, and records every call so
/// the controller's orchestration can be asserted in isolation.
class _FakePhysics extends PingPhysics {
  _FakePhysics();

  static const Offset movedBy = Offset(1, 0);
  static const Offset spawnVelocity = Offset(1, 0);
  static const Offset collidedVelocity = Offset(0, 9);

  bool spawnSucceeds = true;
  bool wallsHit = false;
  bool ballsCollide = false;

  final List<({int index, bool motionless, int others})> spawnCalls = [];
  int moveCalls = 0;
  int reflectCalls = 0;
  int collisionCalls = 0;

  static Offset spawnCenter(int index, BallSpec spec) =>
      Offset(spec.radius * (index + 1), spec.radius);

  @override
  BallState? spawn({
    required int index,
    required BallSpec spec,
    required Size bounds,
    required Iterable<BallState> others,
    required Random random,
    required int retryCap,
    bool motionless = false,
  }) {
    spawnCalls.add(
      (index: index, motionless: motionless, others: others.length),
    );
    if (!spawnSucceeds) return null;
    return BallState(
      index: index,
      spec: spec,
      center: spawnCenter(index, spec),
      velocity: motionless ? Offset.zero : spawnVelocity,
    );
  }

  @override
  BallState move(BallState ball, Duration delta) {
    moveCalls++;
    return ball.copyWith(center: ball.center + movedBy);
  }

  @override
  WallReflection reflectOffWalls(BallState ball, Size bounds) {
    reflectCalls++;
    if (!wallsHit) return (ball: ball, hitWall: false);
    return (ball: ball.copyWith(velocity: -ball.velocity), hitWall: true);
  }

  @override
  Collision resolveCollision(BallState first, BallState second) {
    collisionCalls++;
    if (!ballsCollide) {
      return (first: first, second: second, collided: false);
    }
    return (
      first: first.copyWith(velocity: collidedVelocity),
      second: second.copyWith(velocity: -collidedVelocity),
      collided: true,
    );
  }
}

const Size _bounds = Size(200, 200);
const Duration _interval = Duration(seconds: 1);
const BallSpec _spec = BallSpec(radius: 10, speed: 50);

ArenaConfig _arena({
  int balls = 1,
  Size bounds = _bounds,
  Duration spawnInterval = _interval,
  int retryCap = 5,
  bool motionless = false,
  bool recycle = false,
  List<BallSpec>? specs,
}) => ArenaConfig(
  bounds: bounds,
  specs: specs ?? List<BallSpec>.filled(balls, _spec),
  spawnInterval: spawnInterval,
  retryCap: retryCap,
  motionless: motionless,
  recycle: recycle,
);

void main() {
  late _FakePhysics physics;
  late PingPongController controller;
  late int notifications;

  setUp(() {
    physics = _FakePhysics();
    controller = PingPongController(random: Random(1), physics: physics);
    notifications = 0;
    controller.addListener(() => notifications++);
    addTearDown(controller.dispose);
  });

  group('PingPongController', () {
    group('construction', () {
      test('defaults to a fresh Random and the real physics', () {
        final defaults = PingPongController();
        addTearDown(defaults.dispose);

        expect(defaults.isRunning, isFalse);
        expect(defaults.isConfigured, isFalse);
        expect(defaults.allSpawned, isFalse);
        expect(defaults.displayedCount, 0);
        expect(defaults.queuedCount, 0);
        expect(defaults.balls, isEmpty);
      });

      test('exposes balls as an unmodifiable view', () {
        expect(
          () => controller.balls.add(
            const BallState(
              index: 0,
              spec: _spec,
              center: Offset.zero,
              velocity: Offset.zero,
            ),
          ),
          throwsUnsupportedError,
        );
      });

      test('works end-to-end with the real physics and a seeded Random', () {
        final real = PingPongController(random: Random(42));
        addTearDown(real.dispose);

        real
          ..configure(_arena(balls: 2, motionless: true))
          ..start()
          ..advance(Duration.zero);

        expect(real.displayedCount, 2);
        expect(real.allSpawned, isTrue);
        for (final ball in real.balls) {
          expect(
            ball.center.dx,
            inInclusiveRange(_spec.radius, _bounds.width - _spec.radius),
          );
          expect(
            ball.center.dy,
            inInclusiveRange(_spec.radius, _bounds.height - _spec.radius),
          );
          expect(ball.velocity, Offset.zero);
        }
      });
    });

    group('configure', () {
      test('fills the spawn queue, clears balls and notifies', () {
        controller.configure(_arena(balls: 3));

        expect(controller.isConfigured, isTrue);
        expect(controller.allSpawned, isFalse);
        expect(controller.queuedCount, 3);
        expect(controller.displayedCount, 0);
        expect(controller.isRunning, isFalse);
        expect(notifications, 1);
      });

      test('keeps the running state', () {
        controller
          ..start()
          ..configure(_arena());

        expect(controller.isRunning, isTrue);
      });

      test('restarts spawning from the first spec', () {
        controller
          ..configure(_arena(balls: 2))
          ..start()
          ..advance(Duration.zero);
        expect(controller.displayedCount, 1);

        controller.configure(_arena(balls: 2));

        expect(controller.displayedCount, 0);
        expect(controller.queuedCount, 2);
      });

      test('throws BallTooLargeError when a diameter exceeds the width', () {
        final config = _arena(
          bounds: const Size(15, 100),
          specs: const [_spec, BallSpec(radius: 10, speed: 1)],
        );

        expect(
          () => controller.configure(config),
          throwsA(
            isA<BallTooLargeError>()
                .having((e) => e.index, 'index', 0)
                .having((e) => e.radius, 'radius', 10)
                .having((e) => e.bounds, 'bounds', const Size(15, 100)),
          ),
        );
      });

      test('throws BallTooLargeError when a diameter exceeds the height', () {
        final config = _arena(
          bounds: const Size(100, 15),
          specs: const [BallSpec(radius: 5, speed: 1), _spec],
        );

        expect(
          () => controller.configure(config),
          throwsA(isA<BallTooLargeError>().having((e) => e.index, 'index', 1)),
        );
      });

      test('keeps the previous configuration when a ball is too large', () {
        controller.configure(_arena(balls: 2));
        notifications = 0;

        expect(
          () => controller.configure(_arena(bounds: const Size(5, 5))),
          throwsA(isA<BallTooLargeError>()),
        );

        expect(controller.isConfigured, isTrue);
        expect(controller.queuedCount, 2);
        expect(notifications, 0);
      });

      test('rejects an oversized ball even on first configuration', () {
        expect(
          () => controller.configure(_arena(bounds: const Size(5, 5))),
          throwsA(isA<BallTooLargeError>()),
        );

        expect(controller.isConfigured, isFalse);
        expect(controller.queuedCount, 0);
      });
    });

    group('start', () {
      test('sets isRunning and notifies', () {
        controller.start();

        expect(controller.isRunning, isTrue);
        expect(notifications, 1);
      });

      test('is a no-op when already running', () {
        controller
          ..start()
          ..start();

        expect(controller.isRunning, isTrue);
        expect(notifications, 1);
      });
    });

    group('pause', () {
      test('is a no-op when not running', () {
        controller.pause();

        expect(controller.isRunning, isFalse);
        expect(notifications, 0);
      });

      test('clears isRunning and notifies', () {
        controller
          ..start()
          ..pause();

        expect(controller.isRunning, isFalse);
        expect(notifications, 2);
      });
    });

    group('reset', () {
      test('notifies and leaves an unconfigured controller empty', () {
        controller.reset();

        expect(controller.isConfigured, isFalse);
        expect(controller.queuedCount, 0);
        expect(controller.displayedCount, 0);
        expect(notifications, 1);
      });

      test('clears balls and refills the queue from the first spec', () {
        controller
          ..configure(_arena(balls: 2))
          ..start()
          ..advance(Duration.zero);
        expect(controller.displayedCount, 1);
        expect(controller.queuedCount, 1);
        notifications = 0;

        controller.reset();

        expect(controller.displayedCount, 0);
        expect(controller.queuedCount, 2);
        expect(controller.isRunning, isTrue);
        expect(notifications, 1);
      });

      test('makes the first ball due again immediately', () {
        controller
          ..configure(_arena(balls: 2))
          ..start()
          ..advance(Duration.zero)
          ..reset();
        physics.spawnCalls.clear();

        controller.advance(Duration.zero);

        expect(physics.spawnCalls, hasLength(1));
        expect(physics.spawnCalls.single.index, 0);
      });
    });

    group('advance', () {
      test('does nothing when not running', () {
        controller
          ..configure(_arena())
          ..advance(_interval);
        notifications = 0;

        controller.advance(_interval);

        expect(physics.spawnCalls, isEmpty);
        expect(controller.displayedCount, 0);
        expect(notifications, 0);
      });

      test('does nothing when not configured', () {
        controller.start();
        notifications = 0;

        controller.advance(_interval);

        expect(physics.spawnCalls, isEmpty);
        expect(notifications, 0);
      });

      group('motionless', () {
        test('places every ball at once with zero velocity', () {
          final spawned = <int>[];
          controller.onSpawned = spawned.add;
          controller
            ..configure(_arena(balls: 3, motionless: true))
            ..start();
          notifications = 0;

          controller.advance(Duration.zero);

          expect(controller.displayedCount, 3);
          expect(controller.queuedCount, 0);
          expect(controller.allSpawned, isTrue);
          expect(spawned, [0, 1, 2]);
          expect(
            physics.spawnCalls.map((c) => c.motionless),
            everyElement(isTrue),
          );
          expect(physics.spawnCalls.map((c) => c.others), [0, 1, 2]);
          expect(
            controller.balls.map((b) => b.velocity),
            everyElement(Offset.zero),
          );
          expect(notifications, 1);
        });

        test('never moves balls or resolves collisions', () {
          controller
            ..configure(_arena(balls: 2, motionless: true))
            ..start()
            ..advance(_interval)
            ..advance(_interval);

          expect(physics.moveCalls, 0);
          expect(physics.reflectCalls, 0);
          expect(physics.collisionCalls, 0);
        });

        test('does not notify once everything is spawned', () {
          controller
            ..configure(_arena(balls: 2, motionless: true))
            ..start()
            ..advance(Duration.zero);
          notifications = 0;
          physics.spawnCalls.clear();

          controller.advance(_interval);

          expect(physics.spawnCalls, isEmpty);
          expect(notifications, 0);
        });

        test('stops at the first ball that finds no room', () {
          controller
            ..configure(_arena(balls: 3, motionless: true))
            ..start()
            ..advance(Duration.zero);
          expect(controller.displayedCount, 3);

          controller.configure(_arena(balls: 3, motionless: true));
          physics
            ..spawnSucceeds = false
            ..spawnCalls.clear();
          notifications = 0;

          controller.advance(Duration.zero);

          expect(physics.spawnCalls, hasLength(1));
          expect(controller.displayedCount, 0);
          expect(controller.queuedCount, 3);
          expect(controller.allSpawned, isFalse);
          expect(notifications, 0);
        });

        test('never recycles even when recycling is enabled', () {
          var evictions = 0;
          controller.onEvicted = (_) => evictions++;
          controller
            ..configure(_arena(balls: 2, motionless: true, recycle: true))
            ..start();
          physics.spawnSucceeds = false;

          controller.advance(_interval);

          expect(evictions, 0);
          expect(controller.queuedCount, 2);
        });
      });

      group('moving', () {
        test('spawns the first ball immediately and notifies', () {
          final spawned = <int>[];
          controller.onSpawned = spawned.add;
          controller
            ..configure(_arena(balls: 2))
            ..start();
          notifications = 0;

          controller.advance(Duration.zero);

          expect(controller.displayedCount, 1);
          expect(controller.queuedCount, 1);
          expect(spawned, [0]);
          expect(physics.spawnCalls.single.motionless, isFalse);
          expect(controller.balls.single.velocity, _FakePhysics.spawnVelocity);
          expect(notifications, 1);
        });

        test('spawns without callbacks attached', () {
          controller
            ..configure(_arena(balls: 2))
            ..start();

          expect(() => controller.advance(Duration.zero), returnsNormally);
          expect(controller.displayedCount, 1);
        });

        test('waits a full spawn interval between balls', () {
          controller
            ..configure(_arena(balls: 2))
            ..start()
            ..advance(Duration.zero);
          physics.spawnCalls.clear();

          controller.advance(const Duration(milliseconds: 400));
          expect(physics.spawnCalls, isEmpty);
          expect(controller.displayedCount, 1);

          controller.advance(const Duration(milliseconds: 400));
          expect(physics.spawnCalls, isEmpty);

          controller.advance(const Duration(milliseconds: 200));
          expect(physics.spawnCalls, hasLength(1));
          expect(physics.spawnCalls.single.index, 1);
          expect(controller.displayedCount, 2);
          expect(controller.allSpawned, isTrue);
        });

        test('stops trying to spawn once every ball is on screen', () {
          controller
            ..configure(_arena())
            ..start()
            ..advance(Duration.zero);
          physics.spawnCalls.clear();

          controller.advance(_interval * 5);

          expect(physics.spawnCalls, isEmpty);
        });

        test('keeps a ball at the head of the queue when it finds no room', () {
          controller
            ..configure(_arena(balls: 2))
            ..start()
            ..advance(Duration.zero);
          physics
            ..spawnSucceeds = false
            ..spawnCalls.clear();

          controller.advance(_interval);
          expect(physics.spawnCalls.single.index, 1);
          expect(controller.displayedCount, 1);
          expect(controller.queuedCount, 1);

          physics.spawnSucceeds = true;
          controller.advance(_interval);
          expect(physics.spawnCalls.last.index, 1);
          expect(controller.displayedCount, 2);
        });

        test('does not evict when recycling is off', () {
          var evictions = 0;
          controller.onEvicted = (_) => evictions++;
          controller
            ..configure(_arena(balls: 2))
            ..start()
            ..advance(Duration.zero);
          physics.spawnSucceeds = false;

          controller.advance(_interval);

          expect(evictions, 0);
          expect(controller.displayedCount, 1);
          expect(controller.queuedCount, 1);
        });

        test(
          'evicts the oldest ball to the back of the queue when recycling',
          () {
            final evicted = <BallState>[];
            controller.onEvicted = evicted.add;
            controller
              ..configure(_arena(balls: 3, recycle: true))
              ..start()
              ..advance(Duration.zero)
              ..advance(_interval);
            expect(controller.balls.map((b) => b.index), [0, 1]);
            physics.spawnSucceeds = false;

            controller.advance(_interval);

            expect(evicted.map((b) => b.index), [0]);
            expect(controller.balls.map((b) => b.index), [1]);
            expect(controller.displayedCount, 1);
            expect(controller.queuedCount, 2);

            physics.spawnSucceeds = true;
            controller
              ..advance(_interval)
              ..advance(_interval);
            expect(controller.balls.map((b) => b.index), [1, 2, 0]);
            expect(controller.allSpawned, isTrue);
          },
        );

        test('evicts without an onEvicted callback attached', () {
          controller
            ..configure(_arena(balls: 2, recycle: true))
            ..start()
            ..advance(Duration.zero);
          physics.spawnSucceeds = false;

          expect(() => controller.advance(_interval), returnsNormally);
          expect(controller.displayedCount, 0);
          expect(controller.queuedCount, 2);
        });

        test('moves every ball and keeps the reflected state', () {
          controller
            ..configure(_arena(balls: 2, spawnInterval: Duration.zero))
            ..start()
            ..advance(Duration.zero)
            ..advance(Duration.zero);
          expect(controller.displayedCount, 2);
          final before = controller.balls.toList();

          controller.advance(_interval);

          expect(physics.moveCalls, greaterThanOrEqualTo(2));
          expect(physics.reflectCalls, physics.moveCalls);
          for (var i = 0; i < before.length; i++) {
            expect(
              controller.balls[i].center,
              before[i].center + _FakePhysics.movedBy,
            );
          }
        });

        test('reverses velocity on a wall hit', () {
          controller
            ..configure(_arena())
            ..start()
            ..advance(Duration.zero);
          physics.wallsHit = true;

          controller.advance(_interval);

          expect(
            controller.balls.single.velocity,
            -_FakePhysics.spawnVelocity,
          );
        });

        test('applies a resolved ball collision to both balls', () {
          controller
            ..configure(_arena(balls: 2, spawnInterval: Duration.zero))
            ..start()
            ..advance(Duration.zero)
            ..advance(Duration.zero);
          physics.ballsCollide = true;

          controller.advance(_interval);

          expect(physics.collisionCalls, greaterThanOrEqualTo(1));
          expect(controller.balls[0].velocity, _FakePhysics.collidedVelocity);
          expect(
            controller.balls[1].velocity,
            -_FakePhysics.collidedVelocity,
          );
        });

        test('leaves velocities untouched when balls do not collide', () {
          controller
            ..configure(_arena(balls: 2, spawnInterval: Duration.zero))
            ..start()
            ..advance(Duration.zero)
            ..advance(Duration.zero);

          controller.advance(_interval);

          expect(physics.collisionCalls, greaterThanOrEqualTo(1));
          expect(
            controller.balls.map((b) => b.velocity),
            everyElement(_FakePhysics.spawnVelocity),
          );
        });

        test('notifies on every frame even when nothing changes', () {
          controller
            ..configure(_arena())
            ..start()
            ..advance(Duration.zero);
          notifications = 0;

          controller
            ..advance(_interval)
            ..advance(_interval);

          expect(notifications, 2);
        });
      });
    });
  });
}

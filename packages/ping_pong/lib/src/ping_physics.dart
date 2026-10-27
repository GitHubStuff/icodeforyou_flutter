// packages/ping_pong/lib/src/ping_physics.dart
import 'dart:math' as math;
import 'dart:ui' show Offset, Size;

import 'package:ping_pong/src/ball_spec.dart';
import 'package:ping_pong/src/ball_state.dart';

/// A ball after being tested against the container walls.
typedef WallReflection = ({BallState ball, bool hitWall});

/// Two balls after being tested against each other.
typedef Collision = ({BallState first, BallState second, bool collided});

typedef _AxisReflection = ({double position, double velocity, bool hit});

/// Pure, stateless physics for the ping-pong simulation.
///
/// Nothing here depends on the widget layer or on time sources, so
/// every rule can be unit-tested with hand-built [BallState]s.
class PingPhysics {
  /// Creates the default physics rules.
  const PingPhysics();

  /// Advances [ball] along its velocity for [delta].
  BallState move(BallState ball, Duration delta) {
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    return ball.copyWith(center: ball.center + ball.velocity * seconds);
  }

  /// Keeps [ball] inside [bounds], reflecting its velocity on any
  /// wall it has crossed.
  ///
  /// Reflection is a mirror of the approach angle: the velocity
  /// component perpendicular to the wall is inverted and the ball is
  /// clamped back inside so it never tunnels out.
  WallReflection reflectOffWalls(BallState ball, Size bounds) {
    final x = _reflectAxis(
      position: ball.center.dx,
      velocity: ball.velocity.dx,
      radius: ball.radius,
      extent: bounds.width,
    );
    final y = _reflectAxis(
      position: ball.center.dy,
      velocity: ball.velocity.dy,
      radius: ball.radius,
      extent: bounds.height,
    );
    if (!x.hit && !y.hit) return (ball: ball, hitWall: false);

    return (
      ball: ball.copyWith(
        center: Offset(x.position, y.position),
        velocity: Offset(x.velocity, y.velocity),
      ),
      hitWall: true,
    );
  }

  /// Resolves a collision between [first] and [second], if any.
  ///
  /// Uses the classic equal-mass elastic response: the velocity
  /// components along the line between the centres are swapped. Each
  /// ball is then rescaled to its own fixed speed so a per-ball speed
  /// survives contact, and the pair is pushed apart so they no longer
  /// overlap on the next frame.
  ///
  /// A ball whose swapped velocity comes out as zero (it hit a ball
  /// that has no motion along the collision line head-on) is
  /// reflected instead, as if it had struck a wall.
  Collision resolveCollision(BallState first, BallState second) {
    if (!first.overlaps(second)) {
      return (first: first, second: second, collided: false);
    }

    final delta = second.center - first.center;
    final distance = delta.distance;
    final normal = distance == 0 ? const Offset(1, 0) : delta / distance;

    final firstAlongNormal = _dot(first.velocity, normal);
    final secondAlongNormal = _dot(second.velocity, normal);
    final exchange = normal * (secondAlongNormal - firstAlongNormal);

    final overlap = first.radius + second.radius - distance;
    final push = normal * (overlap / 2);

    return (
      first: first.copyWith(
        center: first.center - push,
        velocity: _atOwnSpeed(first.velocity + exchange, first),
      ),
      second: second.copyWith(
        center: second.center + push,
        velocity: _atOwnSpeed(second.velocity - exchange, second),
      ),
      collided: true,
    );
  }

  /// Finds a spawn position for ball [index] that does not overlap
  /// any of [others], trying up to [retryCap] random positions.
  ///
  /// Returns `null` when no position was found, or when the ball
  /// cannot fit inside [bounds] at all. With [motionless] the ball
  /// spawns with zero velocity; otherwise it gets a random direction
  /// at its spec's speed.
  BallState? spawn({
    required int index,
    required BallSpec spec,
    required Size bounds,
    required Iterable<BallState> others,
    required math.Random random,
    required int retryCap,
    bool motionless = false,
  }) {
    final radius = spec.radius;
    final freeWidth = bounds.width - 2 * radius;
    final freeHeight = bounds.height - 2 * radius;
    if (freeWidth < 0 || freeHeight < 0) return null;

    for (var attempt = 0; attempt < retryCap; attempt++) {
      final candidate = BallState(
        index: index,
        spec: spec,
        center: Offset(
          radius + random.nextDouble() * freeWidth,
          radius + random.nextDouble() * freeHeight,
        ),
        velocity: motionless
            ? Offset.zero
            : _randomVelocity(spec.speed, random),
      );
      if (!others.any(candidate.overlaps)) return candidate;
    }
    return null;
  }

  _AxisReflection _reflectAxis({
    required double position,
    required double velocity,
    required double radius,
    required double extent,
  }) {
    if (position - radius < 0) {
      return (position: radius, velocity: velocity.abs(), hit: true);
    }
    if (position + radius > extent) {
      return (
        position: extent - radius,
        velocity: -velocity.abs(),
        hit: true,
      );
    }
    return (position: position, velocity: velocity, hit: false);
  }

  Offset _atOwnSpeed(Offset velocity, BallState ball) {
    final magnitude = velocity.distance;
    if (magnitude == 0) return -ball.velocity;
    return velocity / magnitude * ball.speed;
  }

  Offset _randomVelocity(double speed, math.Random random) {
    final angle = random.nextDouble() * 2 * math.pi;
    return Offset(math.cos(angle), math.sin(angle)) * speed;
  }

  double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;
}

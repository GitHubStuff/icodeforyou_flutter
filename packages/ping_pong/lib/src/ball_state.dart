// packages/ping_pong/lib/src/ball_state.dart

import 'dart:ui' show Offset;

import 'package:equatable/equatable.dart';
import 'ball_spec.dart' show BallSpec;

/// The simulation state of one ball that has been spawned.
///
/// Immutable: every change produces a new instance via [copyWith].
/// Coordinates are relative to the top-left of the container the
/// balls live in, in logical pixels.
class BallState extends Equatable {
  /// Creates the state of ball number [index] described by [spec].
  const BallState({
    required this.index,
    required this.spec,
    required this.center,
    required this.velocity,
  });

  /// Index of this ball in the caller's list of balls.
  final int index;

  /// The physical description of this ball.
  final BallSpec spec;

  /// Position of the ball's centre.
  final Offset center;

  /// Velocity in logical pixels per second.
  final Offset velocity;

  /// Radius in logical pixels.
  double get radius => spec.radius;

  /// The ball's fixed speed, preserved across collisions.
  double get speed => spec.speed;

  /// Returns a copy with the given fields replaced.
  BallState copyWith({Offset? center, Offset? velocity}) => BallState(
    index: index,
    spec: spec,
    center: center ?? this.center,
    velocity: velocity ?? this.velocity,
  );

  /// Whether this ball's circle intersects [other]'s circle.
  bool overlaps(BallState other) =>
      (center - other.center).distance < radius + other.radius;

  @override
  List<Object?> get props => [index, spec, center, velocity];
}

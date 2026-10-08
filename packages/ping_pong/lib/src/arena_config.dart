// packages/ping_pong/lib/src/arena_config.dart
import 'dart:ui' show Size;

import 'package:equatable/equatable.dart';
import 'package:ping_pong/src/ball_spec.dart';

/// Everything the simulation needs to know about the arena it runs in.
///
/// Built by the `PingPong` widget once it knows its layout, and handed
/// to the controller. Because it is a value object, the widget can
/// compare the previous and next config and restart the simulation
/// only when something actually changed (a resize, a rotation, a new
/// ball list, or a change to the reduced-motion setting).
class ArenaConfig extends Equatable {
  /// Creates an arena of size [bounds] holding the balls in [specs].
  const ArenaConfig({
    required this.bounds,
    required this.specs,
    required this.spawnInterval,
    required this.retryCap,
    required this.motionless,
    required this.recycle,
  }) : assert(retryCap > 0, 'retryCap must be at least 1');

  /// The size of the area the balls bounce inside.
  final Size bounds;

  /// The balls, in spawn order.
  final List<BallSpec> specs;

  /// Time between one ball appearing and the next.
  final Duration spawnInterval;

  /// How many random positions to try before giving up on a spawn
  /// for the current interval.
  final int retryCap;

  /// When `true` every ball is placed at once and nothing moves.
  ///
  /// Set from `MediaQuery.disableAnimations` to honour the platform's
  /// reduced-motion accessibility setting. Recycling never happens in
  /// this mode: a layout that cycles balls is motion.
  final bool motionless;

  /// When `true`, a ball that fails to spawn evicts the oldest ball on
  /// screen, which goes to the back of the spawn queue, so every ball
  /// is eventually shown even when they cannot all fit at once.
  final bool recycle;

  @override
  List<Object?> get props => [
    bounds,
    specs,
    spawnInterval,
    retryCap,
    motionless,
    recycle,
  ];
}

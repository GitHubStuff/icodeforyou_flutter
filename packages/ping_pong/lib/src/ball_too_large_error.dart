// packages/ping_pong/lib/src/ball_too_large_error.dart

import 'dart:ui' show Size;

/// Thrown by the controller when a ball can never fit inside the arena.
///
/// Recycling cannot help such a ball: evicting every other ball would
/// leave an empty arena the ball still does not fit in. The error is
/// raised when the arena is configured, before anything spawns, so the
/// mistake surfaces at the first layout rather than after a long run.
class BallTooLargeError extends Error {
  /// Creates the error for a ball of [radius] in an arena of [bounds].
  BallTooLargeError({
    required this.index,
    required this.radius,
    required this.bounds,
  });

  /// Index of the offending ball in the caller's list.
  final int index;

  /// Radius of the offending ball in logical pixels.
  final double radius;

  /// Size of the arena the ball was meant to fit in.
  final Size bounds;

  @override
  String toString() =>
      'Ball $index of radius $radius cannot fit in an arena of '
      '${bounds.width} x ${bounds.height}';
}

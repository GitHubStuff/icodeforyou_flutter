// packages/ping_pong/lib/src/ball_spec.dart
import 'package:equatable/equatable.dart';

/// The physical description of one ball, independent of any widget.
///
/// The controller and physics work with specs rather than widgets so
/// the simulation never depends on the widget layer.
class BallSpec extends Equatable {
  /// Creates a spec for a ball of the given [radius] moving at [speed].
  const BallSpec({required this.radius, required this.speed})
    : assert(radius > 0, 'radius must be positive'),
      assert(speed >= 0, 'speed must not be negative');

  /// Radius in logical pixels.
  final double radius;

  /// Speed in logical pixels per second.
  final double speed;

  @override
  List<Object?> get props => [radius, speed];
}

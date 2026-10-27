// packages/ping_pong/lib/src/ping_pong_ball.dart
import 'package:flutter/widgets.dart';

/// A circular ball for use inside `PingPong`.
///
/// The ball is responsible for its own shape: [child] is clipped to a
/// circle of [radius] and framed by a 2px border in [border]. The
/// physics in `PingPong` use the same [radius], so the visual and the
/// hit circle always agree.
///
/// When the ball is evicted to make room for another, `PingPong`
/// shrinks it to nothing over [exitDuration] along [evictionCurve].
class PingPongBall extends StatelessWidget {
  /// Creates a ball of the given [radius] showing [child].
  ///
  /// [speed] overrides the `PingPong` widget's global speed for this
  /// ball only. [onTap] makes the ball tappable; leave it `null` for a
  /// passive ball. [exitDuration] must be between zero and
  /// [maxExitDuration]; zero removes the ball instantly.
  const PingPongBall({
    required this.radius,
    required this.child,
    required this.border,
    this.speed,
    this.onTap,
    this.exitDuration = defaultExitDuration,
    this.evictionCurve = Curves.easeIn,
    super.key,
  }) : assert(radius > 0, 'radius must be positive'),
       assert(speed == null || speed >= 0, 'speed must not be negative');

  /// Width of the circular border in logical pixels.
  static const double borderWidth = 2;

  /// How long an evicted ball takes to shrink away unless overridden.
  static const Duration defaultExitDuration = Duration(milliseconds: 500);

  /// The longest [exitDuration] allowed.
  static const Duration maxExitDuration = Duration(seconds: 2);

  /// Radius of the ball in logical pixels.
  final double radius;

  /// The content shown inside the circle.
  final Widget child;

  /// Colour of the circular border.
  final Color border;

  /// Per-ball speed in logical pixels per second, or `null` to use the
  /// `PingPong` widget's global speed.
  final double? speed;

  /// Called when the ball is tapped, or `null` for a passive ball.
  final VoidCallback? onTap;

  /// How long the ball takes to shrink to nothing when evicted.
  ///
  /// Zero removes it instantly. Bounded by [maxExitDuration].
  final Duration exitDuration;

  /// The curve of the shrink when evicted.
  final Curve evictionCurve;

  /// The ball's diameter in logical pixels.
  double get diameter => radius * 2;

  /// Whether [exitDuration] is within the allowed bounds.
  bool get hasValidExitDuration =>
      exitDuration >= Duration.zero && exitDuration <= maxExitDuration;

  @override
  Widget build(BuildContext context) {
    assert(
      hasValidExitDuration,
      'exitDuration must be between zero and $maxExitDuration',
    );
    return SizedBox(
      width: diameter,
      height: diameter,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: border, width: borderWidth),
          ),
          child: ClipOval(child: child),
        ),
      ),
    );
  }
}

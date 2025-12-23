// dissolve_particle.dart v0.01
import 'dart:ui';

/// Represents a single particle in the dissolve animation
///
/// Follows Single Responsibility Principle - only handles particle state
class DissolveParticle {
  final Offset _initialPosition;
  final Offset _velocity;
  final double _startTime;

  const DissolveParticle({
    required Offset position,
    required Offset velocity,
    required double startTime,
  }) : _initialPosition = position,
       _velocity = velocity,
       _startTime = startTime;

  /// Gets particle position at given animation time
  Offset getPositionAtTime(double time) {
    if (time < _startTime) return _initialPosition;

    final elapsed = time - _startTime;
    return Offset(
      _initialPosition.dx + _velocity.dx * elapsed,
      _initialPosition.dy + _velocity.dy * elapsed,
    );
  }

  /// Gets particle opacity at given animation time (1.0 to 0.0)
  /// Ensures all particles disappear by animation end
  double getOpacityAtTime(double time) {
    if (time < _startTime) return 1.0;

    final elapsed = time - _startTime;
    // Scale fade time to ensure particle disappears before animation ends
    // If animation is 1.0 total and particle starts at 0.4, it has 0.6 to fade
    final remainingTime = 1.0 - _startTime;
    final fadeTime = remainingTime * 0.8; // Use 80% of remaining time

    if (fadeTime <= 0) return 0.0;

    return (1.0 - (elapsed / fadeTime)).clamp(0.0, 1.0);
  }

  /// Gets particle size multiplier at given animation time
  /// Ensures all particles shrink away by animation end
  double getSizeAtTime(double time) {
    if (time < _startTime) return 1.0;

    final elapsed = time - _startTime;
    // Scale shrink time to ensure particle disappears before animation ends
    final remainingTime = 1.0 - _startTime;
    final shrinkTime = remainingTime * 0.6; // Use 60% of remaining time

    if (shrinkTime <= 0) return 0.0;

    return (1.0 - (elapsed / shrinkTime)).clamp(0.0, 1.0);
  }
}

// lib/src/dissolve_particle.dart
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
  double getOpacityAtTime(double time) {
    if (time < _startTime) return 1.0;

    final elapsed = time - _startTime;
    const fadeTime = 0.7;
    return (1.0 - (elapsed / fadeTime)).clamp(0.0, 1.0);
  }

  /// Gets particle size multiplier at given animation time
  double getSizeAtTime(double time) {
    if (time < _startTime) return 1.0;

    final elapsed = time - _startTime;
    const shrinkTime = 0.5;
    return (1.0 - (elapsed / shrinkTime)).clamp(0.2, 1.0);
  }
}

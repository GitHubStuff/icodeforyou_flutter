// animated_widgets/lib/src/animated_checkbox/_dissolve_particle.dart
import 'dart:ui';

/// Represents a single particle in the dissolve animation.
class DissolveParticle {
  /// Creates a [DissolveParticle] with the given [position], [velocity],
  /// and [startTime] within the normalised animation timeline (0.0–1.0).
  const DissolveParticle({
    required Offset position,
    required Offset velocity,
    required double startTime,
  }) : _initialPosition = position,
       _velocity = velocity,
       _startTime = startTime;

  final Offset _initialPosition;
  final Offset _velocity;
  final double _startTime;

  /// Returns the particle's [Offset] position at the given normalised [time].
  Offset getPositionAtTime(double time) {
    if (time < _startTime) return _initialPosition;
    final elapsed = time - _startTime;
    return Offset(
      _initialPosition.dx + _velocity.dx * elapsed,
      _initialPosition.dy + _velocity.dy * elapsed,
    );
  }

  /// Returns the particle's opacity (0.0–1.0) at the given normalised [time].
  double getOpacityAtTime(double time) {
    if (time < _startTime) return 1;
    final elapsed = time - _startTime;
    final remainingTime = 1.0 - _startTime;
    final fadeTime = remainingTime * 0.8;
    if (fadeTime <= 0) return 0;
    return (1.0 - (elapsed / fadeTime)).clamp(0.0, 1.0);
  }

  /// Returns the particle's size scale (0.0–1.0) at the given
  /// normalised [time].
  double getSizeAtTime(double time) {
    if (time < _startTime) return 1;
    final elapsed = time - _startTime;
    final remainingTime = 1.0 - _startTime;
    final shrinkTime = remainingTime * 0.6;
    if (shrinkTime <= 0) return 0;
    return (1.0 - (elapsed / shrinkTime)).clamp(0.0, 1.0);
  }
}

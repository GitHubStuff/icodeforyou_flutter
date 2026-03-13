// lib/src/animated_checkbox/_dissolve_particle.dart

import 'dart:ui';

/// Represents a single particle in the dissolve animation.
class DissolveParticle {
  const DissolveParticle({
    required Offset position,
    required Offset velocity,
    required double startTime,
  })  : _initialPosition = position,
        _velocity = velocity,
        _startTime = startTime;

  final Offset _initialPosition;
  final Offset _velocity;
  final double _startTime;

  Offset getPositionAtTime(double time) {
    if (time < _startTime) return _initialPosition;
    final elapsed = time - _startTime;
    return Offset(
      _initialPosition.dx + _velocity.dx * elapsed,
      _initialPosition.dy + _velocity.dy * elapsed,
    );
  }

  double getOpacityAtTime(double time) {
    if (time < _startTime) return 1;
    final elapsed = time - _startTime;
    final remainingTime = 1.0 - _startTime;
    final fadeTime = remainingTime * 0.8;
    if (fadeTime <= 0) return 0;
    return (1.0 - (elapsed / fadeTime)).clamp(0.0, 1.0);
  }

  double getSizeAtTime(double time) {
    if (time < _startTime) return 1;
    final elapsed = time - _startTime;
    final remainingTime = 1.0 - _startTime;
    final shrinkTime = remainingTime * 0.6;
    if (shrinkTime <= 0) return 0;
    return (1.0 - (elapsed / shrinkTime)).clamp(0.0, 1.0);
  }
}

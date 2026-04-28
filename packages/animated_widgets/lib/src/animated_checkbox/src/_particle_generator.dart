// animated_widgets/lib/src/animated_checkbox/_particle_generator.dart

import 'dart:math' as math;
import 'dart:ui';

import 'package:animated_widgets/src/animated_checkbox/src/_dissolve_particle.dart';

/// Generates [DissolveParticle] instances along a [Path] for the
/// dissolve animation.
class ParticleGenerator {
  static final math.Random _random = math.Random();

  /// The maximum normalised stagger time (0.0–1.0) before a particle
  /// begins animating.
  static const double _maxStaggerTime = 0.4;

  /// The distance in logical pixels between successive particles along the path
  static const double _particleStep = 1.5;

  /// Samples [path] at [_particleStep] intervals and returns
  /// a [DissolveParticle] for each sample point, each with a randomised
  /// velocity and stagger start time.
  static List<DissolveParticle> generateFromPath(Path path) {
    final particles = <DissolveParticle>[];
    final metrics = path.computeMetrics().toList();

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          particles.add(
            DissolveParticle(
              position: tangent.position,
              velocity: _randomVelocity(),
              startTime: _random.nextDouble() * _maxStaggerTime,
            ),
          );
        }
        distance += _particleStep;
      }
    }

    return particles;
  }

  /// Returns a random [Offset] velocity with a randomised direction and
  /// a speed in the range [8, 23] logical pixels per normalised time unit.
  static Offset _randomVelocity() {
    final angle = _random.nextDouble() * 2 * math.pi;
    final speed = _random.nextDouble() * 15 + 8;
    return Offset(math.cos(angle) * speed, math.sin(angle) * speed);
  }
}

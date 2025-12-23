// lib/src/particle_generator.dart
import 'dart:math' as math;
import 'dart:ui';

import '_dissolve_particle.dart';

/// Generates particles for the dissolve animation
///
/// Follows Single Responsibility Principle - only generates particles
class ParticleGenerator {
  static final math.Random _random = math.Random();
  static const double _maxStaggerTime = 0.4;

  /// Generates particles along a given path for dissolve animation
  static List<DissolveParticle> generateFromPath(Path path) {
    final particles = <DissolveParticle>[];
    final metrics = path.computeMetrics().toList();

    // Smaller step for more particles and smoother dissolve
    const particleStep = 1.5;

    for (final metric in metrics) {
      final length = metric.length;

      for (double distance = 0; distance < length; distance += particleStep) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          particles.add(
            DissolveParticle(
              position: tangent.position,
              velocity: _generateRandomVelocity(),
              startTime: _random.nextDouble() * _maxStaggerTime,
            ),
          );
        }
      }
    }

    return particles;
  }

  static Offset _generateRandomVelocity() {
    final angle = _random.nextDouble() * 2 * math.pi;
    final speed = _random.nextDouble() * 15 + 8; // Slower initial movement
    return Offset(math.cos(angle) * speed, math.sin(angle) * speed);
  }
}

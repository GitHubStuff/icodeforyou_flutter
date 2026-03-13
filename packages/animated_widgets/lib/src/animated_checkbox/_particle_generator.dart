// lib/src/animated_checkbox/_particle_generator.dart

import 'dart:math' as math;
import 'dart:ui';

import 'package:animated_widgets/src/animated_checkbox/_dissolve_particle.dart';

/// Generates particles along a path for the dissolve animation.
class ParticleGenerator {

  static final math.Random _random = math.Random();
  static const double _maxStaggerTime = 0.4;
  static const double _particleStep = 1.5;

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

  static Offset _randomVelocity() {
    final angle = _random.nextDouble() * 2 * math.pi;
    final speed = _random.nextDouble() * 15 + 8;
    return Offset(math.cos(angle) * speed, math.sin(angle) * speed);
  }
}

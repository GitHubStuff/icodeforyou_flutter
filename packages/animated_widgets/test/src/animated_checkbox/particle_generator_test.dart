// animated_widgets/test/src/animated_checkbox/particle_generator_test.dart

import 'dart:ui';

import 'package:animated_widgets/src/animated_checkbox/src/_dissolve_particle.dart';
import 'package:animated_widgets/src/animated_checkbox/src/_particle_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParticleGenerator.generateFromPath', () {
    test('returns an empty list for an empty path', () {
      final particles = ParticleGenerator.generateFromPath(Path());
      expect(particles, isEmpty);
    });

    test('samples a line at ~1.5px intervals', () {
      // A 30px line sampled at a 1.5px step yields roughly 20 points; allow a
      // small tolerance for floating-point accumulation in the step loop.
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(30, 0);

      final particles = ParticleGenerator.generateFromPath(path);

      expect(particles, isNotEmpty);
      expect(particles, everyElement(isA<DissolveParticle>()));
      expect(particles.length, inInclusiveRange(19, 21));
    });

    test('particle start positions track the source path', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(15, 0);

      final particles = ParticleGenerator.generateFromPath(path);

      // First sample sits at the path origin.
      expect(particles.first.getPositionAtTime(0).dx, closeTo(0, 1e-6));
      expect(particles.first.getPositionAtTime(0).dy, closeTo(0, 1e-6));
    });

    test('every particle is fully opaque at t=0 and fully faded at t=1', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(40, 0);

      final particles = ParticleGenerator.generateFromPath(path);

      for (final particle in particles) {
        // Regardless of its randomised stagger startTime, a particle is fully
        // visible at the start of the timeline and fully gone by the end.
        expect(particle.getOpacityAtTime(0), 1.0);
        expect(particle.getOpacityAtTime(1), 0.0);
      }
    });

    test('handles a multi-contour path', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(15, 0)
        ..moveTo(0, 30)
        ..lineTo(15, 30);

      final particles = ParticleGenerator.generateFromPath(path);

      // Two 15px contours → ~10 samples each (~20 total).
      expect(particles.length, inInclusiveRange(18, 22));
    });
  });
}

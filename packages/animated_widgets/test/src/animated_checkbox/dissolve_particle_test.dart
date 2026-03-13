// test/src/animated_checkbox/_dissolve_particle_test.dart

import 'package:animated_widgets/src/animated_checkbox/_dissolve_particle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const position = Offset(10, 20);
  const velocity = Offset(5, -3);
  const startTime = 0.3;

  const particle = DissolveParticle(
    position: position,
    velocity: velocity,
    startTime: startTime,
  );

  group('DissolveParticle.getPositionAtTime', () {
    test('returns initial position when time is before startTime', () {
      expect(particle.getPositionAtTime(0.1), equals(position));
    });

    test('returns initial position when time equals startTime', () {
      expect(particle.getPositionAtTime(startTime), equals(position));
    });

    test('returns displaced position when time is after startTime', () {
      const time = 0.8;
      const elapsed = time - startTime;
      final expected = Offset(
        position.dx + velocity.dx * elapsed,
        position.dy + velocity.dy * elapsed,
      );
      expect(particle.getPositionAtTime(time), equals(expected));
    });
  });

  group('DissolveParticle.getOpacityAtTime', () {
    test('returns 1 when time is before startTime', () {
      expect(particle.getOpacityAtTime(0.1), equals(1.0));
    });

    test('returns clamped opacity when time is after startTime', () {
      const time = 0.5;
      const elapsed = time - startTime;
      const remainingTime = 1.0 - startTime;
      const fadeTime = remainingTime * 0.8;
      final expected = (1.0 - (elapsed / fadeTime)).clamp(0.0, 1.0);
      expect(particle.getOpacityAtTime(time), closeTo(expected, 1e-10));
    });

    test('returns 0 when fully faded', () {
      expect(particle.getOpacityAtTime(1.0), equals(0.0));
    });

    test('returns 0 when fadeTime is zero (startTime == 1.0)', () {
      const lateParticle = DissolveParticle(
        position: position,
        velocity: velocity,
        startTime: 1.0,
      );
      expect(lateParticle.getOpacityAtTime(1.0), equals(0.0));
    });
  });

  group('DissolveParticle.getSizeAtTime', () {
    test('returns 1 when time is before startTime', () {
      expect(particle.getSizeAtTime(0.1), equals(1.0));
    });

    test('returns clamped size when time is after startTime', () {
      const time = 0.5;
      const elapsed = time - startTime;
      const remainingTime = 1.0 - startTime;
      const shrinkTime = remainingTime * 0.6;
      final expected = (1.0 - (elapsed / shrinkTime)).clamp(0.0, 1.0);
      expect(particle.getSizeAtTime(time), closeTo(expected, 1e-10));
    });

    test('returns 0 when fully shrunk', () {
      expect(particle.getSizeAtTime(1.0), equals(0.0));
    });

    test('returns 0 when shrinkTime is zero (startTime == 1.0)', () {
      const lateParticle = DissolveParticle(
        position: position,
        velocity: velocity,
        startTime: 1.0,
      );
      expect(lateParticle.getSizeAtTime(1.0), equals(0.0));
    });
  });
}

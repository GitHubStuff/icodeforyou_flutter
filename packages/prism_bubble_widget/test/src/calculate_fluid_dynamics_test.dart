// packages/prism_bubble_widget/test/src/calculate_fluid_dynamics_test.dart
import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/prism_bubble_widget.dart'
    show BubbleFluidDynamicEnum;
import 'package:prism_bubble_widget/src/dynamic_prism_bubble.dart'
    show calculateFluidDynamics;

void main() {
  const double tolerance = 1e-9;

  /// A broad sample of time values covering several full cycles of every
  /// preset's slowest frequency, so range invariants are exercised across
  /// peaks, troughs, and wrap-around boundaries.
  final List<double> sampleTimes = List<double>.generate(
    400,
    (int index) => index * 0.25,
  );

  /// Asserts that [preset] yields a finite phase angle and a diffusion value
  /// clamped to `[0.0, 1.0]` for every sampled time value.
  void expectWithinRange(BubbleFluidDynamicEnum preset) {
    for (final double t in sampleTimes) {
      final ({double diffusion, double phaseAngle}) result =
          calculateFluidDynamics(preset: preset, t: t);

      expect(
        result.diffusion,
        inInclusiveRange(0.0, 1.0),
        reason: 'preset=$preset t=$t',
      );
      expect(
        result.diffusion.isFinite,
        isTrue,
        reason: 'preset=$preset t=$t',
      );
      expect(
        result.phaseAngle.isFinite,
        isTrue,
        reason: 'preset=$preset t=$t',
      );
    }
  }

  group('calculateFluidDynamics', () {
    group('range invariants', () {
      test('serene keeps diffusion within [0.0, 1.0] for all sampled t', () {
        expectWithinRange(BubbleFluidDynamicEnum.serene);
      });

      test('restless keeps diffusion within [0.0, 1.0] for all sampled t', () {
        expectWithinRange(BubbleFluidDynamicEnum.restless);
      });

      test(
        'meditative keeps diffusion within [0.0, 1.0] for all sampled t',
        () {
          expectWithinRange(BubbleFluidDynamicEnum.meditative);
        },
      );

      test('frenetic keeps diffusion within [0.0, 1.0] for all sampled t', () {
        expectWithinRange(BubbleFluidDynamicEnum.frenetic);
      });

      test('molten keeps diffusion within [0.0, 1.0] for all sampled t', () {
        expectWithinRange(BubbleFluidDynamicEnum.molten);
      });

      test('tidal keeps diffusion within [0.0, 1.0] for all sampled t', () {
        expectWithinRange(BubbleFluidDynamicEnum.tidal);
      });

      test('maelstrom keeps diffusion within [0.0, 1.0] for all sampled t', () {
        expectWithinRange(BubbleFluidDynamicEnum.maelstrom);
      });

      test('dormant keeps diffusion within [0.0, 1.0] for all sampled t', () {
        expectWithinRange(BubbleFluidDynamicEnum.dormant);
      });
    });

    group('serene', () {
      test('returns zero phase angle at t = 0', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(preset: BubbleFluidDynamicEnum.serene, t: 0);

        expect(result.phaseAngle, closeTo(0.0, tolerance));
      });

      test('caps diffusion at 85% bloom', () {
        for (final double t in sampleTimes) {
          final ({double diffusion, double phaseAngle}) result =
              calculateFluidDynamics(
                preset: BubbleFluidDynamicEnum.serene,
                t: t,
              );

          expect(result.diffusion, lessThanOrEqualTo(0.85));
        }
      });

      test('diffusion at t = 0 equals pow(0.5, 1.4) * 0.85', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(preset: BubbleFluidDynamicEnum.serene, t: 0);

        final double expected = math.pow(0.5, 1.4).toDouble() * 0.85;
        expect(result.diffusion, closeTo(expected, tolerance));
      });

      test('phase angle drifts forward over time', () {
        final double early = calculateFluidDynamics(
          preset: BubbleFluidDynamicEnum.serene,
          t: 0,
        ).phaseAngle;
        final double late = calculateFluidDynamics(
          preset: BubbleFluidDynamicEnum.serene,
          t: 100,
        ).phaseAngle;

        expect(late, greaterThan(early));
      });
    });

    group('restless', () {
      test('phase angle at t = 0 is the cosine wave offset (0.4)', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(
              preset: BubbleFluidDynamicEnum.restless,
              t: 0,
            );

        expect(result.phaseAngle, closeTo(0.4, tolerance));
      });

      test('diffusion at t = 0 is the normalised mid-point (0.5)', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(
              preset: BubbleFluidDynamicEnum.restless,
              t: 0,
            );

        expect(result.diffusion, closeTo(0.5, tolerance));
      });
    });

    group('meditative', () {
      test('returns zero phase angle at t = 0', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(
              preset: BubbleFluidDynamicEnum.meditative,
              t: 0,
            );

        expect(result.phaseAngle, closeTo(0.0, tolerance));
      });

      test('diffusion at t = 0 is easeInOutCubic evaluated at 0.5', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(
              preset: BubbleFluidDynamicEnum.meditative,
              t: 0,
            );

        final double expected = Curves.easeInOutCubic.transform(0.5);
        expect(result.diffusion, closeTo(expected, tolerance));
      });

      test('breathing cycle wraps every 2π / 0.3 seconds', () {
        const double period = 2.0 * math.pi / 0.3;
        final double first = calculateFluidDynamics(
          preset: BubbleFluidDynamicEnum.meditative,
          t: 1.0,
        ).diffusion;
        final double wrapped = calculateFluidDynamics(
          preset: BubbleFluidDynamicEnum.meditative,
          t: 1.0 + period,
        ).diffusion;

        expect(wrapped, closeTo(first, 1e-6));
      });
    });

    group('frenetic', () {
      test('phase angle at t = 0 is the cosine jitter offset (0.3)', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(
              preset: BubbleFluidDynamicEnum.frenetic,
              t: 0,
            );

        expect(result.phaseAngle, closeTo(0.3, tolerance));
      });

      test('diffusion never collapses below the 0.3 baseline', () {
        for (final double t in sampleTimes) {
          final ({double diffusion, double phaseAngle}) result =
              calculateFluidDynamics(
                preset: BubbleFluidDynamicEnum.frenetic,
                t: t,
              );

          expect(result.diffusion, greaterThanOrEqualTo(0.3 - tolerance));
        }
      });

      test('diffusion at t = 0 is the mid-point of [0.3, 1.0] (0.65)', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(
              preset: BubbleFluidDynamicEnum.frenetic,
              t: 0,
            );

        expect(result.diffusion, closeTo(0.65, tolerance));
      });
    });

    group('molten', () {
      test('returns zero phase angle at t = 0', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(preset: BubbleFluidDynamicEnum.molten, t: 0);

        expect(result.phaseAngle, closeTo(0.0, tolerance));
      });

      test('diffusion at t = 0 is fastOutSlowIn evaluated at 0.5, scaled', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(preset: BubbleFluidDynamicEnum.molten, t: 0);

        final double expected = Curves.fastOutSlowIn.transform(0.5) * 0.95;
        expect(result.diffusion, closeTo(expected, tolerance));
      });

      test('caps diffusion at 95% bloom', () {
        for (final double t in sampleTimes) {
          final ({double diffusion, double phaseAngle}) result =
              calculateFluidDynamics(
                preset: BubbleFluidDynamicEnum.molten,
                t: t,
              );

          expect(result.diffusion, lessThanOrEqualTo(0.95 + tolerance));
        }
      });
    });

    group('tidal', () {
      test('phase angle at t = 0 includes the 1/e surge contribution', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(preset: BubbleFluidDynamicEnum.tidal, t: 0);

        expect(result.phaseAngle, closeTo(1.2 / math.e, tolerance));
      });

      test('diffusion never reaches 1.0 even at surge crest', () {
        // Crest occurs when sin(tidalNorm) == 1, i.e. tidalNorm == π/2.
        const double crestTime = math.pi / 2.0 / 0.5;
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(
              preset: BubbleFluidDynamicEnum.tidal,
              t: crestTime,
            );

        expect(result.diffusion, lessThan(1.0));
        expect(result.diffusion, lessThanOrEqualTo(0.95 + tolerance));
      });
    });

    group('maelstrom', () {
      test('returns zero phase angle at t = 0', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(
              preset: BubbleFluidDynamicEnum.maelstrom,
              t: 0,
            );

        expect(result.phaseAngle, closeTo(0.0, tolerance));
      });

      test('diffusion at t = 0 is the 0.4 core bloom baseline', () {
        final ({double diffusion, double phaseAngle}) result =
            calculateFluidDynamics(
              preset: BubbleFluidDynamicEnum.maelstrom,
              t: 0,
            );

        expect(result.diffusion, closeTo(0.4, tolerance));
      });

      test('diffusion oscillates within [0.1, 0.7]', () {
        for (final double t in sampleTimes) {
          final ({double diffusion, double phaseAngle}) result =
              calculateFluidDynamics(
                preset: BubbleFluidDynamicEnum.maelstrom,
                t: t,
              );

          expect(
            result.diffusion,
            inInclusiveRange(0.1 - tolerance, 0.7 + tolerance),
          );
        }
      });
    });

    group('dormant', () {
      test('returns the fixed static state regardless of t', () {
        for (final double t in <double>[0, 1, 42.5, 1000]) {
          final ({double diffusion, double phaseAngle}) result =
              calculateFluidDynamics(
                preset: BubbleFluidDynamicEnum.dormant,
                t: t,
              );

          expect(result.diffusion, 0.2);
          expect(result.phaseAngle, 0.0);
        }
      });
    });
  });
}

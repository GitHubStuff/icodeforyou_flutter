// packages/prism_bubble_widget/lib/src/calculate_fluid_dynamics.dart
part of 'dynamic_prism_bubble.dart';

/// Computes film diffusion width and rotational phase angle offsets.
///
/// Converts a scalar time parameter [t] into compound trigonometric and
/// non-linear parametric curves corresponding to the selected [preset].
///
/// Returns a record:
/// * [diffusion]: Clamped to `[0.0, 1.0]`, controlling Gaussian rim width.
/// * [phaseAngle]: Continuous rotational angle offset in radians.
({double diffusion, double phaseAngle}) calculateFluidDynamics({
  required BubbleFluidDynamicEnum preset,
  required double t,
}) {
  switch (preset) {
    case BubbleFluidDynamicEnum.serene:
      // Swirl: Low-frequency laminar drift combined with harmonic counter-eddy.
      // - 0.25 rad/s: Primary angular progression (~25.13s per full 2π rev).
      // - sin(t * 0.45) * 0.35: Secondary counter-oscillation producing a
      //   periodic phase retardance of +/-20.05 degrees (0.35 rad) every 13.96s.
      final double primarySwirl = t * 0.25;
      final double harmonicSwirl = math.sin(t * 0.45) * 0.35;
      final double phaseAngle = primarySwirl + harmonicSwirl;

      // Diffusion: Asymmetric power-curve respiration.
      // - (sin(t * 0.6) + 1.0) * 0.5: Base harmonic wave mapped to [0.0, 1.0]
      //   with a 10.47s period (2π / 0.6).
      // - pow(..., 1.4): Skews the curve downward, compressing the trough
      //   and prolonging the peak plateau to simulate surface-tension drag.
      // - * 0.85: Caps peak expansion at 85% maximum bloom.
      final double rawWave = (math.sin(t * 0.6) + 1.0) * 0.5;
      final double diffusion = math.pow(rawWave, 1.4).toDouble() * 0.85;

      return (diffusion: diffusion, phaseAngle: phaseAngle);

    case BubbleFluidDynamicEnum.restless:
      // Swirl: Turbulent aperiodic drift via incommensurate sinusoids.
      // - 0.60 rad/s: Base forward velocity.
      // - sin(t * 1.1) * 0.7: High-amplitude mid-frequency wave (+/-0.7 rad).
      // - cos(t * 0.7) * 0.4: Out-of-phase secondary wave (+/-0.4 rad).
      // The ratio 1.1 / 0.7 (~1.5714) is non-integer, avoiding simple visual
      // loops and generating fluid turbulence.
      final double primaryDrift = t * 0.6;
      final double waveA = math.sin(t * 1.1) * 0.7;
      final double waveB = math.cos(t * 0.7) * 0.4;
      final double phaseAngle = primaryDrift + waveA + waveB;

      // Diffusion: Fundamental plus first overtone (2f) pulse.
      // - sin(t * 1.4): Fundamental pulse at 0.223 Hz.
      // - sin(t * 2.8) * 0.3: Second harmonic at 2x frequency, steepening
      //   the front slope and creating sudden contraction snaps.
      // - (pulse + 1.3) / 2.6: Normalizes theoretical range [-1.3, 1.3] to [0.0, 1.0].
      final double pulse = math.sin(t * 1.4) + math.sin(t * 2.8) * 0.3;
      final double diffusion = ((pulse + 1.3) / 2.6).clamp(0.0, 1.0);

      return (diffusion: diffusion, phaseAngle: phaseAngle);

    case BubbleFluidDynamicEnum.meditative:
      // Swirl: Deep laminar flow.
      // - 0.12 rad/s: Ultra-slow drift (~52.36s per full rotation).
      // - sin(t * 0.2) * 0.15: Gentle +/-8.59 degree (0.15 rad) undulation.
      final double phaseAngle = t * 0.12 + math.sin(t * 0.2) * 0.15;

      // Diffusion: Cubic S-curve ease with extended inflection rests.
      // - (t * 0.3) % 2π: Wraps time into discrete 20.94s breathing cycles.
      // - Curves.easeInOutCubic: Zero derivative at t=0 and t=1, producing
      //   smooth transitions with resting holds at minimum and maximum states.
      final double cycle = (t * 0.3) % (2.0 * math.pi);
      final double baseCurve = (math.sin(cycle) + 1.0) * 0.5;
      final double diffusion = Curves.easeInOutCubic.transform(baseCurve);

      return (diffusion: diffusion, phaseAngle: phaseAngle);

    case BubbleFluidDynamicEnum.frenetic:
      // Swirl: High-frequency flutter.
      // - 1.80 rad/s: High base rotational velocity (~3.49s per full turn).
      // - sin(t * 3.7) * 0.8: Fast angular flutter (+/-45.8 degrees).
      // - cos(t * 7.1) * 0.3: High-frequency micro-jitter (+/-17.18 degrees).
      final double flutter = math.sin(t * 3.7) * 0.8 + math.cos(t * 7.1) * 0.3;
      final double phaseAngle = t * 1.8 + flutter;

      // Diffusion: Rapid chromatic flutter with non-zero baseline.
      // - sin(t * 4.2): 0.668 Hz oscillation.
      // - rawFrenetic * 0.7 + 0.3: Constrains output to [0.3, 1.0], preventing
      //   the rim from collapsing into a thin line during rapid transitions.
      final double rawFrenetic = math.sin(t * 4.2) * 0.5 + 0.5;
      final double diffusion = (rawFrenetic * 0.7 + 0.3).clamp(0.0, 1.0);

      return (diffusion: diffusion, phaseAngle: phaseAngle);

    case BubbleFluidDynamicEnum.molten:
      // Swirl: Viscous heavy-drag movement.
      // - 0.08 rad/s: Drag-dominated base drift (~78.54s per full turn).
      // - sin(slowClock * 0.5) * 0.1: Subtle +/-5.73 degree ripple.
      final double slowClock = t * 0.08;
      final double phaseAngle = slowClock + math.sin(slowClock * 0.5) * 0.1;

      // Diffusion: Asymmetric viscous response.
      // - sin(t * 0.2): Slow 31.41s period.
      // - Curves.fastOutSlowIn: Rapid expansion phase followed by long,
      //   gradual relaxation mimicking high liquid viscosity.
      final double viscousWave = (math.sin(t * 0.2) + 1.0) * 0.5;
      final double diffusion =
          Curves.fastOutSlowIn.transform(viscousWave) * 0.95;

      return (diffusion: diffusion, phaseAngle: phaseAngle);

    case BubbleFluidDynamicEnum.tidal:
      // Swirl & Diffusion: Surge profile modeled on asymmetric wave peaks.
      // - (t * 0.5) % 2π: 12.56s periodic tidal interval.
      // - exp(sin(θ)) / e: Mathematical surge function producing sharp crests
      //   peaking at 1.0 when sin(θ)=1, and wide, flat troughs near 1/e² (~0.135).
      // - Surge * 1.2 adds a rapid 1.2 rad (~68.75 degree) forward acceleration
      //   during crest arrival.
      final double tidalNorm = (t * 0.5) % (2.0 * math.pi);
      final double surge = math.exp(math.sin(tidalNorm)) / math.e;
      final double phaseAngle = t * 0.35 + surge * 1.2;
      final double diffusion = Curves.easeInCirc.transform(surge);

      return (diffusion: diffusion, phaseAngle: phaseAngle);

    case BubbleFluidDynamicEnum.maelstrom:
      // Swirl: Cubic rotational whip.
      // - (t * 0.4) % 2π: 15.71s vortex period.
      // - pow(norm, 3.0): Cubic polynomial acceleration ramp. Progresses
      //   slowly across the first 70% of the cycle, then whips through a full
      //   2π (360-degree) surge in the final 30%.
      final double cycleMaelstrom = (t * 0.4) % (2.0 * math.pi);
      final double whip = math
          .pow(cycleMaelstrom / (2.0 * math.pi), 3.0)
          .toDouble();
      final double phaseAngle = t * 0.8 + whip * math.pi * 2.0;

      // Diffusion: Steady turbulent core bloom oscillating between 0.1 and 0.7.
      final double diffusion = 0.4 + (math.sin(t * 1.2) * 0.3);

      return (diffusion: diffusion, phaseAngle: phaseAngle);

    case BubbleFluidDynamicEnum.dormant:
      // Static fixed state: zero velocity, 20% baseline rim thickness.
      return (diffusion: 0.2, phaseAngle: 0.0);
  }
}

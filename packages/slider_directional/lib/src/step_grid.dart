// packages/slider_directional/lib/src/step_grid.dart
import 'package:flutter/foundation.dart';

/// An immutable description of a discrete step grid on a continuous range.
///
/// Encapsulates grid validation, snapping a raw value to the nearest step
/// boundary, and computing the step index of a snapped value. Pure data and
/// pure math — no Flutter widget dependency.
///
/// ### Invariants
///
/// - `min < max`
/// - `step >= kMinStep` (three decimal places)
/// - `(max - min)` is an integer multiple of `step`
///
/// Violations throw in debug builds via the constructor assert. The integer
/// multiple check is performed on scaled integer arithmetic to sidestep
/// IEEE 754 rounding errors.
@immutable
class StepGrid {
  /// Creates a [StepGrid] with the given bounds and step size.
  StepGrid({required this.min, required this.max, required this.step})
    : assert(min < max, 'min ($min) must be less than max ($max)'),
      assert(
        step >= kMinStep,
        'step ($step) must be >= $kMinStep (three decimal places)',
      ),
      assert(
        _isValid(min: min, max: max, step: step),
        'step ($step) must evenly divide (max - min) = ${max - min}. '
            'Use a step that produces a whole number of divisions.',
      );

  /// Smallest supported step size. Three decimal places.
  static const double kMinStep = 0.001;

  /// Scaling factor used to convert grid math to integer arithmetic.
  ///
  /// With [kMinStep] = 0.001, multiplying by 1000 gives exact integer values
  /// for all legal inputs.
  static const int _kScale = 1000;

  /// Lower bound (inclusive).
  final double min;

  /// Upper bound (inclusive).
  final double max;

  /// Step size on the grid.
  final double step;

  /// Number of discrete divisions on the grid. Always a positive integer
  /// under the constructor's asserts.
  int get divisions =>
      ((max - min) * _kScale).round() ~/ (step * _kScale).round();

  /// Snaps a raw value to the nearest step boundary and clamps to `[min, max]`.
  double snap(double raw) {
    final stepsFromMin = ((raw - min) / step).round().toDouble();
    final snapped = min + stepsFromMin * step;
    return snapped.clamp(min, max);
  }

  /// Returns the zero-based step index of [value] on the grid.
  ///
  /// Caller is expected to pass a value already snapped via [snap]; passing
  /// an unsnapped value rounds to the nearest index.
  int indexOf(double value) => ((value - min) / step).round();

  /// Number of decimal places implied by [step], for formatting default
  /// slider labels. `step = 0.1` → 1, `step = 0.01` → 2, `step = 1` → 0.
  int get decimalPlaces {
    final parts = step.toString().split('.');
    if (parts.length < 2) return 0;
    return parts[1].length;
  }

  static bool _isValid({
    required double min,
    required double max,
    required double step,
  }) {
    final span = ((max - min) * _kScale).round();
    final stepScaled = (step * _kScale).round();
    if (stepScaled <= 0) return false;
    return span % stepScaled == 0;
  }
}

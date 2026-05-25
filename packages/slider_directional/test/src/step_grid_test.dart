// packages/slider_directional/test/src/step_grid_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_directional/slider_directional.dart';

void main() {
  group('StepGrid', () {
    group('constructor', () {
      test('accepts a valid integer-bound grid', () {
        final grid = StepGrid(min: 0, max: 10, step: 1);
        expect(grid.min, 0);
        expect(grid.max, 10);
        expect(grid.step, 1);
      });

      test('accepts a valid sub-unit step', () {
        final grid = StepGrid(min: 0, max: 1, step: 0.1);
        expect(grid.divisions, 10);
      });

      test('accepts the minimum supported step (0.001)', () {
        final grid = StepGrid(min: 0, max: 0.01, step: StepGrid.kMinStep);
        expect(grid.divisions, 10);
      });

      test('accepts a negative-to-positive range', () {
        final grid = StepGrid(min: -5, max: 5, step: 0.5);
        expect(grid.divisions, 20);
      });

      test('throws AssertionError when min equals max', () {
        expect(
          () => StepGrid(min: 1, max: 1, step: 0.1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws AssertionError when min is greater than max', () {
        expect(
          () => StepGrid(min: 10, max: 0, step: 1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws AssertionError when step is below kMinStep', () {
        expect(
          () => StepGrid(min: 0, max: 1, step: 0.0001),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws AssertionError when step does not evenly divide range', () {
        expect(
          () => StepGrid(min: 0, max: 10, step: 3),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('divisions', () {
      test('is computed from scaled integer arithmetic', () {
        // The classic floating-point trap: (0.3 - 0.0) / 0.1 == 2.9999... in
        // IEEE 754. The scaled-integer path must report exactly 3.
        final grid = StepGrid(min: 0, max: 0.3, step: 0.1);
        expect(grid.divisions, 3);
      });

      test('matches range / step for whole numbers', () {
        final grid = StepGrid(min: 0, max: 100, step: 5);
        expect(grid.divisions, 20);
      });
    });

    group('snap', () {
      late StepGrid grid;

      setUp(() {
        grid = StepGrid(min: 0, max: 10, step: 1);
      });

      test('rounds down to the nearest step below the midpoint', () {
        expect(grid.snap(2.4), 2.0);
      });

      test('rounds up to the nearest step at or above the midpoint', () {
        expect(grid.snap(2.6), 3.0);
      });

      test('returns an exact step value unchanged', () {
        expect(grid.snap(5.0), 5.0);
      });

      test('clamps values below min back to min', () {
        expect(grid.snap(-100), 0.0);
      });

      test('clamps values above max back to max', () {
        expect(grid.snap(100), 10.0);
      });

      test('respects a non-zero min', () {
        final offset = StepGrid(min: 5, max: 15, step: 1);
        expect(offset.snap(7.3), 7.0);
        expect(offset.snap(7.7), 8.0);
      });

      test('respects a fractional step', () {
        final fine = StepGrid(min: 0, max: 1, step: 0.1);
        expect(fine.snap(0.34), closeTo(0.3, 1e-9));
        expect(fine.snap(0.36), closeTo(0.4, 1e-9));
      });
    });

    group('indexOf', () {
      late StepGrid grid;

      setUp(() {
        grid = StepGrid(min: 0, max: 10, step: 1);
      });

      test('returns 0 at min', () {
        expect(grid.indexOf(0), 0);
      });

      test('returns divisions at max', () {
        expect(grid.indexOf(10), grid.divisions);
      });

      test('returns the step count for a mid-range value', () {
        expect(grid.indexOf(7), 7);
      });

      test('rounds an unsnapped value to the nearest index', () {
        expect(grid.indexOf(2.4), 2);
        expect(grid.indexOf(2.6), 3);
      });

      test('respects a non-zero min', () {
        final offset = StepGrid(min: 5, max: 15, step: 1);
        expect(offset.indexOf(5), 0);
        expect(offset.indexOf(8), 3);
      });
    });

    group('decimalPlaces', () {
      test('reflects the trailing fragment of step.toString() for an '
          'integer-valued step (1.0 → "1.0" → 1)', () {
        // Dart doubles stringify with a trailing ".0", so an integer-valued
        // step reports 1 decimal place, not 0. Documenting actual behaviour.
        expect(StepGrid(min: 0, max: 10, step: 1).decimalPlaces, 1);
      });

      test('is 1 for a tenths step', () {
        expect(StepGrid(min: 0, max: 1, step: 0.1).decimalPlaces, 1);
      });

      test('is 2 for a hundredths step', () {
        expect(StepGrid(min: 0, max: 1, step: 0.01).decimalPlaces, 2);
      });

      test('is 3 for a thousandths step (kMinStep)', () {
        expect(
          StepGrid(min: 0, max: 0.01, step: StepGrid.kMinStep).decimalPlaces,
          3,
        );
      });
    });

    group('kMinStep constant', () {
      test('is 0.001', () {
        expect(StepGrid.kMinStep, 0.001);
      });
    });
  });
}

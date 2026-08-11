// packages/custom_widgets/test/src/directional_slider/slider/step_grid_test.dart

import 'package:custom_widgets/src/directional_slider/slider/step_grid.dart'
    show StepGrid;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StepGrid', () {
    group('construction asserts', () {
      test('rejects min >= max', () {
        expect(
          () => StepGrid(min: 10, max: 10, step: 1),
          throwsAssertionError,
        );
      });

      test('rejects step below kMinStep', () {
        expect(
          () => StepGrid(min: 0, max: 1, step: StepGrid.kMinStep / 2),
          throwsAssertionError,
        );
      });

      test('rejects a step that does not evenly divide the span', () {
        expect(
          () => StepGrid(min: 0, max: 10, step: 3),
          throwsAssertionError,
        );
      });

      test('accepts the smallest legal step', () {
        final grid = StepGrid(min: 0, max: 0.003, step: StepGrid.kMinStep);
        expect(grid.divisions, 3);
      });
    });

    group('divisions', () {
      test('computes whole divisions from exact spans', () {
        expect(StepGrid(min: 0, max: 10, step: 1).divisions, 10);
        expect(StepGrid(min: 0, max: 1, step: 0.25).divisions, 4);
        expect(StepGrid(min: -1, max: 1, step: 0.5).divisions, 4);
      });

      test('is exact under IEEE 754 noise (0.1 steps)', () {
        expect(StepGrid(min: 0, max: 0.3, step: 0.1).divisions, 3);
      });
    });

    group('snap', () {
      test('snaps down and up to the nearest boundary', () {
        final grid = StepGrid(min: 0, max: 10, step: 1);

        expect(grid.snap(4.4), 4.0);
        expect(grid.snap(4.6), 5.0);
      });

      test('clamps below min and above max', () {
        final grid = StepGrid(min: 0, max: 10, step: 1);

        expect(grid.snap(-3), 0.0);
        expect(grid.snap(13), 10.0);
      });

      test('snaps on a fractional grid', () {
        final grid = StepGrid(min: 1, max: 2, step: 0.25);

        expect(grid.snap(1.6), 1.5);
        expect(grid.snap(1.7), 1.75);
      });
    });

    group('indexOf', () {
      test('returns the zero-based step index of a snapped value', () {
        final grid = StepGrid(min: 0, max: 10, step: 1);

        expect(grid.indexOf(0), 0);
        expect(grid.indexOf(5), 5);
        expect(grid.indexOf(10), 10);
      });

      test('rounds an unsnapped value to the nearest index', () {
        final grid = StepGrid(min: 0, max: 10, step: 1);

        expect(grid.indexOf(5.4), 5);
        expect(grid.indexOf(5.6), 6);
      });
    });

    group('decimalPlaces', () {
      test('reflects the step precision', () {
        expect(StepGrid(min: 0, max: 1, step: 0.5).decimalPlaces, 1);
        expect(StepGrid(min: 0, max: 1, step: 0.25).decimalPlaces, 2);
        expect(StepGrid(min: 0, max: 0.01, step: 0.001).decimalPlaces, 3);
      });
    });
  });
}

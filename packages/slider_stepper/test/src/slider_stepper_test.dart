// packages/slider_stepper/test/src/slider_stepper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_directional/slider_directional.dart'
    show DirectionalController, SliderDirection, StepGrid;
import 'package:slider_stepper/slider_stepper.dart';
import 'package:slider_stepper/src/step_button.dart' show StepButton;

void main() {
  group('slider_stepper barrel', () {
    test('exports SliderStepper', () {
      expect(SliderStepper, isNotNull);
    });

    test('exports StepButton', () {
      expect(StepButton, isNotNull);
    });

    test('re-exports DirectionalController', () {
      final controller = DirectionalController();
      addTearDown(controller.dispose);
      expect(controller, isA<DirectionalController>());
    });

    test('re-exports SliderDirection', () {
      expect(SliderDirection.values, hasLength(4));
    });

    test('re-exports StepGrid', () {
      final grid = StepGrid(min: 0, max: 1, step: 0.1);
      expect(grid.divisions, 10);
    });
  });
}

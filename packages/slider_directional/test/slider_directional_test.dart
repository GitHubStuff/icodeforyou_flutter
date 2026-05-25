// packages/slider_directional/test/slider_directional_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_directional/slider_directional.dart';

void main() {
  group('slider_directional barrel', () {
    test('exports Directional', () {
      expect(Directional, isNotNull);
    });

    test('exports DirectionalController', () {
      final controller = DirectionalController();
      addTearDown(controller.dispose);
      expect(controller, isA<DirectionalController>());
    });

    test('exports SliderDirection', () {
      expect(SliderDirection.values, hasLength(4));
    });

    test('exports StepGrid', () {
      final grid = StepGrid(min: 0, max: 1, step: 0.1);
      expect(grid.divisions, 10);
    });
  });
}

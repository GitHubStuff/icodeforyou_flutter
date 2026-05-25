// packages/slider_directional/test/src/directional_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_directional/slider_directional.dart';

void main() {
  group('DirectionalController', () {
    test('defaults initial value to 0.0', () {
      final controller = DirectionalController();
      expect(controller.value, 0.0);
      controller.dispose();
    });

    test('accepts a custom initial value', () {
      final controller = DirectionalController(initial: 42);
      expect(controller.value, 42.0);
      controller.dispose();
    });

    test('updates value on write', () {
      final controller = DirectionalController();
      controller.value = 5;
      expect(controller.value, 5.0);
      controller.dispose();
    });

    test('notifies listeners when value changes', () {
      final controller = DirectionalController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.value = 1;
      expect(notifications, 1);

      controller.value = 2;
      expect(notifications, 2);

      controller.dispose();
    });

    test('does not notify listeners when assigning the same value', () {
      final controller = DirectionalController(initial: 3);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.value = 3;
      expect(notifications, 0);

      controller.dispose();
    });

    test('implements ValueListenable<double>', () {
      final controller = DirectionalController(initial: 7);
      // The `value` getter is the ValueListenable contract.
      expect(controller.value, 7.0);
      controller.dispose();
    });
  });
}

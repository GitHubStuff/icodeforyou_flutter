// packages/custom_widgets/test/src/directional_slider/slider/directional_controller_test.dart

import 'package:custom_widgets/custom_widgets.dart'
    show DirectionalController;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DirectionalController', () {
    test('defaults its initial value to 0.0', () {
      final controller = DirectionalController();
      addTearDown(controller.dispose);

      expect(controller.value, 0.0);
    });

    test('holds a supplied initial value', () {
      final controller = DirectionalController(initial: 4.5);
      addTearDown(controller.dispose);

      expect(controller.value, 4.5);
    });

    test('notifies listeners exactly once per distinct write', () {
      final controller = DirectionalController(initial: 1);
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.value = 2;

      expect(controller.value, 2.0);
      expect(notifications, 1);
    });

    test('suppresses notification when the value is unchanged', () {
      final controller = DirectionalController(initial: 3);
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.value = 3;

      expect(controller.value, 3.0);
      expect(notifications, 0);
    });
  });
}

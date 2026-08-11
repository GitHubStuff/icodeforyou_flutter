// packages/custom_widgets/test/src/directional_slider/buttons/directional_slider_and_buttons_test.dart

import 'package:custom_widgets/custom_widgets.dart'
    show DirectionalController, DirectionalSliderAndButtons;
import 'package:custom_widgets/src/directional_slider/buttons/step_button.dart'
    show StepButton;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixed button diameter so tests never depend on an ambient CrossFadeTheme.
const double _kButtonSize = 36;

/// Pumps [widget] inside a Material scaffold.
Future<void> _pump(WidgetTester tester, Widget widget) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: widget)),
    ),
  );
}

/// The [StepButton] wrapping the icon matched by [icon].
StepButton _stepButtonFor(WidgetTester tester, IconData icon) {
  return tester.widget<StepButton>(
    find.ancestor(of: find.byIcon(icon), matching: find.byType(StepButton)),
  );
}

void main() {
  group('DirectionalSliderAndButtons', () {
    testWidgets('plus and minus step the controller and fire onChanged',
        (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);
      final changes = <double>[];

      await _pump(
        tester,
        DirectionalSliderAndButtons(
          controller: controller,
          min: 0,
          max: 10,
          step: 1,
          buttonSize: _kButtonSize,
          onChanged: changes.add,
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(controller.value, 6);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(controller.value, 5);

      expect(changes, [6.0, 5.0]);
    });

    testWidgets('increment clamps an overshooting step to max',
        (tester) async {
      final controller = DirectionalController(initial: 9.5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSliderAndButtons(
          controller: controller,
          min: 0,
          max: 10,
          step: 1,
          buttonSize: _kButtonSize,
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(controller.value, 10);
    });

    testWidgets('disables plus at max and minus at min', (tester) async {
      final controller = DirectionalController(initial: 10);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSliderAndButtons(
          controller: controller,
          min: 0,
          max: 10,
          step: 1,
          buttonSize: _kButtonSize,
        ),
      );

      expect(_stepButtonFor(tester, Icons.add).onPressed, isNull);
      expect(_stepButtonFor(tester, Icons.remove).onPressed, isNotNull);

      controller.value = 0;
      await tester.pump();

      expect(_stepButtonFor(tester, Icons.add).onPressed, isNotNull);
      expect(_stepButtonFor(tester, Icons.remove).onPressed, isNull);
    });

    testWidgets('hold-to-repeat stops stepping at min without overshoot',
        (tester) async {
      final controller = DirectionalController(initial: 1);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSliderAndButtons(
          controller: controller,
          min: 0,
          max: 10,
          step: 1,
          buttonSize: _kButtonSize,
        ),
      );

      // All repeat ticks elapse inside a single pump, before the disabled
      // rebuild, exercising the value-unchanged early return in _stepBy.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.remove)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pump();

      expect(controller.value, 0);
    });

    testWidgets('renders custom icons and the configured gap',
        (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSliderAndButtons(
          controller: controller,
          min: 0,
          max: 10,
          step: 1,
          buttonSize: _kButtonSize,
          minusIcon: Icons.exposure_minus_1,
          plusIcon: Icons.exposure_plus_1,
          gap: 12,
        ),
      );

      expect(find.byIcon(Icons.exposure_minus_1), findsOneWidget);
      expect(find.byIcon(Icons.exposure_plus_1), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 12 && w.height == 12,
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('forwards slider and button colors', (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSliderAndButtons(
          controller: controller,
          min: 0,
          max: 10,
          step: 1,
          buttonSize: _kButtonSize,
          activeColor: Colors.red,
          inactiveColor: Colors.green,
          thumbColor: Colors.blue,
          buttonColor: Colors.orange,
          buttonIconColor: Colors.black,
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.activeColor, Colors.red);
      expect(slider.inactiveColor, Colors.green);
      expect(slider.thumbColor, Colors.blue);

      final plus = _stepButtonFor(tester, Icons.add);
      expect(plus.color, Colors.orange);
      expect(plus.iconColor, Colors.black);
    });

    testWidgets(
        'KNOWN BUG: minValueFirst false asserts because the slider grid '
        'receives min and max swapped', (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSliderAndButtons(
          controller: controller,
          min: 0,
          max: 10,
          step: 1,
          buttonSize: _kButtonSize,
          minValueFirst: false,
        ),
      );

      expect(tester.takeException(), isAssertionError);
    });
  });
}

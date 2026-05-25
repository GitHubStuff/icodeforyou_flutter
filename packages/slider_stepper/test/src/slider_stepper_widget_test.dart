// packages/slider_stepper/test/src/slider_stepper_widget_test.dart

// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_directional/slider_directional.dart'
    show DirectionalController, SliderDirection;
import 'package:slider_stepper/slider_stepper.dart';
import 'package:slider_stepper/src/step_button.dart' show StepButton;
import 'package:widget_themes/widget_themes.dart';

void main() {
  const themeButtonSize = 60.0;

  Finder stepButton(String tooltip) => find.byWidgetPredicate(
    (w) => w is StepButton && w.tooltip == tooltip,
    description: 'StepButton(tooltip: "$tooltip")',
  );

  Widget wrap(
    Widget child, {
    bool withTheme = false,
  }) => MaterialApp(
    theme: withTheme
        ? ThemeData().copyWith(
            extensions: const [
              CrossFadeTheme(buttonSize: themeButtonSize),
            ],
          )
        : null,
    home: Scaffold(
      body: Center(
        // A bounded box so Expanded inside the Row/Column has constraints.
        child: SizedBox(width: 400, height: 400, child: child),
      ),
    ),
  );

  group('SliderStepper — stepping', () {
    testWidgets('tapping plus increments the controller and fires onChanged', (
      tester,
    ) async {
      final controller = DirectionalController(); // value 0
      addTearDown(controller.dispose);
      final changes = <double>[];

      await tester.pumpWidget(
        wrap(
          SliderStepper(
            controller: controller,
            min: 0,
            max: 3,
            step: 1,
            onChanged: changes.add,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Increase'));
      await tester.pump();

      expect(controller.value, 1);
      expect(changes, [1]);
    });

    testWidgets('tapping minus decrements the controller', (tester) async {
      final controller = DirectionalController(initial: 2);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          SliderStepper(
            controller: controller,
            min: 0,
            max: 3,
            step: 1,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Decrease'));
      await tester.pump();

      expect(controller.value, 1);
    });

    testWidgets('null onChanged is safe when stepping (?. short-circuit)', (
      tester,
    ) async {
      final controller = DirectionalController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          SliderStepper(
            controller: controller,
            min: 0,
            max: 3,
            step: 1,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Increase'));
      await tester.pump();

      expect(controller.value, 1);
    });
  });

  group('SliderStepper — button enablement at bounds', () {
    testWidgets('at min, decrement is disabled and increment enabled', (
      tester,
    ) async {
      final controller = DirectionalController(); // value 0 == min
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          SliderStepper(
            controller: controller,
            min: 0,
            max: 3,
            step: 1,
          ),
        ),
      );

      // canDecrement false -> minus onPressed null.
      final minus = tester.widget<StepButton>(stepButton('Decrease'));
      expect(minus.onPressed, isNull);
      // canIncrement true -> plus enabled.
      final plus = tester.widget<StepButton>(stepButton('Increase'));
      expect(plus.onPressed, isNotNull);
    });

    testWidgets('at max, increment is disabled and decrement enabled', (
      tester,
    ) async {
      final controller = DirectionalController(initial: 3); // == max
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          SliderStepper(
            controller: controller,
            min: 0,
            max: 3,
            step: 1,
          ),
        ),
      );

      final plus = tester.widget<StepButton>(stepButton('Increase'));
      expect(plus.onPressed, isNull);
      final minus = tester.widget<StepButton>(stepButton('Decrease'));
      expect(minus.onPressed, isNotNull);
    });
  });

  group('SliderStepper — buttonSize resolution', () {
    testWidgets('explicit buttonSize forwarded to both StepButtons '
        '(left arm of ??)', (tester) async {
      final controller = DirectionalController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          SliderStepper(
            controller: controller,
            min: 0,
            max: 3,
            step: 1,
            buttonSize: 42,
          ),
          withTheme: true, // present, but explicit must win
        ),
      );

      final buttons = tester.widgetList<StepButton>(find.byType(StepButton));
      expect(buttons.map((b) => b.buttonSize), everyElement(42.0));
    });

    testWidgets('null buttonSize resolves from CrossFadeTheme '
        '(right arm of ??)', (tester) async {
      final controller = DirectionalController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          SliderStepper(
            controller: controller,
            min: 0,
            max: 3,
            step: 1,
          ),
          withTheme: true,
        ),
      );

      final buttons = tester.widgetList<StepButton>(find.byType(StepButton));
      expect(buttons.map((b) => b.buttonSize), everyElement(themeButtonSize));
    });
  });

  group('SliderStepper — direction layouts', () {
    Future<void> pumpWith(
      WidgetTester tester,
      SliderDirection direction,
    ) async {
      final controller = DirectionalController(initial: 1);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        wrap(
          SliderStepper(
            controller: controller,
            min: 0,
            max: 3,
            step: 1,
            direction: direction,
          ),
        ),
      );
    }

    testWidgets('left -> Row layout', (tester) async {
      await pumpWith(tester, SliderDirection.left);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(StepButton), findsNWidgets(2));
    });

    testWidgets('right -> Row layout', (tester) async {
      await pumpWith(tester, SliderDirection.right);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(StepButton), findsNWidgets(2));
    });

    testWidgets('top -> Column layout', (tester) async {
      await pumpWith(tester, SliderDirection.top);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(StepButton), findsNWidgets(2));
    });

    testWidgets('bottom -> Column layout', (tester) async {
      await pumpWith(tester, SliderDirection.bottom);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(StepButton), findsNWidgets(2));
    });
  });
}

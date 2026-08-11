// packages/custom_widgets/test/src/directional_slider/slider/directional_slider_test.dart

import 'package:custom_widgets/custom_widgets.dart'
    show DirectionalController, DirectionalSlider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [slider] centred inside a fixed-width Material scaffold.
Future<void> _pump(WidgetTester tester, DirectionalSlider slider) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 400, child: slider)),
      ),
    ),
  );
}

void main() {
  group('DirectionalSlider', () {
    testWidgets('horizontal rotation renders the slider unrotated',
        (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSlider(
          controller: controller,
          rotation: Axis.horizontal,
          min: 0,
          max: 10,
          step: 1,
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(RotatedBox), findsNothing);

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 0);
      expect(slider.max, 10);
      expect(slider.divisions, 10);
      expect(slider.value, 5);
    });

    testWidgets('vertical rotation wraps the slider in a half-turn RTL box',
        (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSlider(
          controller: controller,
          rotation: Axis.vertical,
          min: 0,
          max: 10,
          step: 1,
        ),
      );

      final rotated = tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotated.quarterTurns, 2);

      final directionality = tester.widget<Directionality>(
        find
            .ancestor(
              of: find.byType(Slider),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('drag snaps the value, updates the controller, and fires '
        'onChanged', (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);
      final changes = <double>[];

      await _pump(
        tester,
        DirectionalSlider(
          controller: controller,
          rotation: Axis.horizontal,
          min: 0,
          max: 10,
          step: 1,
          onChanged: changes.add,
        ),
      );

      await tester.drag(find.byType(Slider), const Offset(120, 0));
      await tester.pump();

      expect(controller.value, greaterThan(5));
      expect(controller.value, controller.value.roundToDouble());
      expect(changes, isNotEmpty);
      expect(changes.last, controller.value);
    });

    testWidgets('tap at the current value stays in the same step bucket',
        (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);
      final changes = <double>[];

      await _pump(
        tester,
        DirectionalSlider(
          controller: controller,
          rotation: Axis.horizontal,
          min: 0,
          max: 10,
          step: 1,
          onChanged: changes.add,
        ),
      );

      await tester.tap(find.byType(Slider));
      await tester.pump();

      expect(controller.value, 5.0);
      expect(changes, everyElement(5.0));
    });

    testWidgets('drag with haptics enabled still snaps and updates',
        (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSlider(
          controller: controller,
          rotation: Axis.horizontal,
          min: 0,
          max: 10,
          step: 1,
          enableHapticFeedback: true,
        ),
      );

      await tester.drag(find.byType(Slider), const Offset(120, 0));
      await tester.pump();

      expect(controller.value, greaterThan(5));
      expect(controller.value, controller.value.roundToDouble());
    });

    testWidgets('defaults the label to the value at grid precision',
        (tester) async {
      final controller = DirectionalController(initial: 2.5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSlider(
          controller: controller,
          rotation: Axis.horizontal,
          min: 0,
          max: 5,
          step: 0.5,
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.label, '2.5');
    });

    testWidgets('uses a caller-supplied label verbatim', (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSlider(
          controller: controller,
          rotation: Axis.horizontal,
          min: 0,
          max: 10,
          step: 1,
          label: 'five',
        ),
      );

      expect(tester.widget<Slider>(find.byType(Slider)).label, 'five');
    });

    testWidgets('forwards track and thumb colors', (tester) async {
      final controller = DirectionalController(initial: 5);
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DirectionalSlider(
          controller: controller,
          rotation: Axis.horizontal,
          min: 0,
          max: 10,
          step: 1,
          activeColor: Colors.red,
          inactiveColor: Colors.green,
          thumbColor: Colors.blue,
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.activeColor, Colors.red);
      expect(slider.inactiveColor, Colors.green);
      expect(slider.thumbColor, Colors.blue);
    });

    testWidgets('rebuilds against a new controller and follows its writes',
        (tester) async {
      final first = DirectionalController(initial: 2);
      final second = DirectionalController(initial: 7);
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      DirectionalSlider build(DirectionalController controller) {
        return DirectionalSlider(
          controller: controller,
          rotation: Axis.horizontal,
          min: 0,
          max: 10,
          step: 1,
        );
      }

      await _pump(tester, build(first));
      expect(tester.widget<Slider>(find.byType(Slider)).value, 2);

      await _pump(tester, build(second));
      expect(tester.widget<Slider>(find.byType(Slider)).value, 7);

      second.value = 8;
      await tester.pump();
      expect(tester.widget<Slider>(find.byType(Slider)).value, 8);
    });
  });
}

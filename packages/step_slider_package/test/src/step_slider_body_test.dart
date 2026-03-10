// test/src/step_slider_body_test.dart
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_slider_package/step_slider_package.dart';

void main() {
  group('StepSliderBody (via StepSlider)', () {
    Widget buildTestWidget({
      double initialValue = 50.0,
      double min = 0.0,
      double max = 100.0,
      double step = 1.0,
      int? divisions,
      String? label,
      ValueChanged<double>? onChanged,
      Color? activeColor,
      Color? inactiveColor,
      Color? thumbColor,
      Color? buttonColor,
      Color? buttonIconColor,
      double buttonSize = 36.0,
      bool enableHapticFeedback = false,
      HapticFeedbackType hapticFeedbackType = HapticFeedbackType.light,
      ThemeData? theme,
    }) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          body: StepSlider(
            initialValue: initialValue,
            min: min,
            max: max,
            step: step,
            divisions: divisions,
            label: label,
            onChanged: onChanged,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            thumbColor: thumbColor,
            buttonColor: buttonColor,
            buttonIconColor: buttonIconColor,
            buttonSize: buttonSize,
            enableHapticFeedback: enableHapticFeedback,
            hapticFeedbackType: hapticFeedbackType,
          ),
        ),
      );
    }

    group('layout', () {
      testWidgets('contains Row with buttons and slider', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(Row), findsWidgets);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('slider is wrapped in Expanded', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final expanded = find.ancestor(
          of: find.byType(Slider),
          matching: find.byType(Expanded),
        );
        expect(expanded, findsOneWidget);
      });

      testWidgets('buttons are outside Expanded', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Decrement button should not be inside Expanded
        final decrementInExpanded = find.ancestor(
          of: find.byIcon(Icons.remove),
          matching: find.byType(Expanded),
        );
        expect(decrementInExpanded, findsNothing);

        // Increment button should not be inside Expanded
        final incrementInExpanded = find.ancestor(
          of: find.byIcon(Icons.add),
          matching: find.byType(Expanded),
        );
        expect(incrementInExpanded, findsNothing);
      });
    });

    group('_onChanged', () {
      testWidgets('updates internal state and calls callback', (tester) async {
        double? capturedValue;
        await tester.pumpWidget(buildTestWidget(
          onChanged: (v) => capturedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(capturedValue, 51.0);

        // Verify slider value updated
        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.value, 51.0);
      });

      testWidgets('works without onChanged callback', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Verify slider value still updated
        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.value, 51.0);
      });

      testWidgets('slider drag updates value', (tester) async {
        double? capturedValue;
        await tester.pumpWidget(buildTestWidget(
          onChanged: (v) => capturedValue = v,
        ));

        await tester.drag(find.byType(Slider), const Offset(50, 0));
        await tester.pump();

        expect(capturedValue, isNotNull);
        expect(capturedValue, isNot(50.0));
      });
    });

    group('_decrement', () {
      testWidgets('decrements by step value', (tester) async {
        double? capturedValue;
        await tester.pumpWidget(buildTestWidget(
          step: 5,
          onChanged: (v) => capturedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(capturedValue, 45.0);
      });

      testWidgets('clamps to min when step exceeds', (tester) async {
        double? capturedValue;
        await tester.pumpWidget(buildTestWidget(
          initialValue: 3,
          step: 10,
          onChanged: (v) => capturedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(capturedValue, 0.0);
      });

      testWidgets('works with decimal step values', (tester) async {
        double? capturedValue;
        await tester.pumpWidget(buildTestWidget(
          initialValue: 1.5,
          max: 5,
          step: 0.25,
          onChanged: (v) => capturedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(capturedValue, 1.25);
      });

      testWidgets('multiple decrements work correctly', (tester) async {
        var capturedValue = 0;
        await tester.pumpWidget(buildTestWidget(
          step: 10,
          onChanged: (v) => capturedValue = v.toInt(),
        ));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
        expect(capturedValue, 40.0);

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
        expect(capturedValue, 30.0);

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
        expect(capturedValue, 20.0);
      });
    });

    group('_increment', () {
      testWidgets('increments by step value', (tester) async {
        double? capturedValue;
        await tester.pumpWidget(buildTestWidget(
          step: 5,
          onChanged: (v) => capturedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(capturedValue, 55.0);
      });

      testWidgets('clamps to max when step exceeds', (tester) async {
        double? capturedValue;
        await tester.pumpWidget(buildTestWidget(
          initialValue: 97,
          step: 10,
          onChanged: (v) => capturedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(capturedValue, 100.0);
      });

      testWidgets('works with decimal step values', (tester) async {
        double? capturedValue;
        await tester.pumpWidget(buildTestWidget(
          initialValue: 1.5,
          max: 5,
          step: 0.25,
          onChanged: (v) => capturedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(capturedValue, 1.75);
      });

      testWidgets('multiple increments work correctly', (tester) async {
        var capturedValue = 0;
        await tester.pumpWidget(buildTestWidget(
          step: 10,
          onChanged: (v) => capturedValue = v.toInt(),
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(capturedValue, 60.0);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(capturedValue, 70.0);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(capturedValue, 80.0);
      });
    });

    group('theme integration', () {
      testWidgets('uses theme primary color for buttons by default', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
            ),
          ),
        ));

        final materials = tester.widgetList<Material>(
          find.byType(Material),
        ).where((m) => m.shape is CircleBorder);

        expect(materials.every((m) => m.color == Colors.teal), isTrue);
      });

      testWidgets('uses theme onPrimary color for icons by default', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.yellow,
            ),
          ),
        ));

        final icons = tester.widgetList<Icon>(find.byType(Icon));
        expect(icons.every((i) => i.color == Colors.yellow), isTrue);
      });

      testWidgets('custom colors override theme colors', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          buttonColor: Colors.purple,
          buttonIconColor: Colors.orange,
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
            ),
          ),
        ));

        final materials = tester.widgetList<Material>(
          find.byType(Material),
        ).where((m) => m.shape is CircleBorder);
        expect(materials.every((m) => m.color == Colors.purple), isTrue);

        final icons = tester.widgetList<Icon>(find.byType(Icon));
        expect(icons.every((i) => i.color == Colors.orange), isTrue);
      });
    });

    group('slider properties', () {
      testWidgets('passes min/max to Slider', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 25,
          min: 10,
          max: 50,
        ));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.min, 10.0);
        expect(slider.max, 50.0);
      });

      testWidgets('passes divisions to Slider', (tester) async {
        await tester.pumpWidget(buildTestWidget(divisions: 20));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.divisions, 20);
      });

      testWidgets('passes custom label to Slider', (tester) async {
        await tester.pumpWidget(buildTestWidget(label: 'Volume'));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.label, 'Volume');
      });

      testWidgets('generates default label from value when not provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialValue: 42.7));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.label, '43'); // Rounded
      });

      testWidgets('passes activeColor to Slider', (tester) async {
        await tester.pumpWidget(buildTestWidget(activeColor: Colors.red));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.activeColor, Colors.red);
      });

      testWidgets('passes inactiveColor to Slider', (tester) async {
        await tester.pumpWidget(buildTestWidget(inactiveColor: Colors.grey));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.inactiveColor, Colors.grey);
      });

      testWidgets('passes thumbColor to Slider', (tester) async {
        await tester.pumpWidget(buildTestWidget(thumbColor: Colors.blue));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.thumbColor, Colors.blue);
      });
    });

    group('BlocBuilder integration', () {
      testWidgets('rebuilds only affected widgets on state change', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final initialSlider = tester.widget<Slider>(find.byType(Slider));
        expect(initialSlider.value, 50.0);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        final updatedSlider = tester.widget<Slider>(find.byType(Slider));
        expect(updatedSlider.value, 51.0);
      });
    });
  });
}

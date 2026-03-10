// test/src/step_slider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_slider_package/step_slider_package.dart';

void main() {
  group('StepSlider', () {
    Widget buildTestWidget({
      double initialValue = 0.0,
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
    }) {
      return MaterialApp(
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

    group('construction', () {
      testWidgets('builds with default values', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(StepSlider), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('builds with custom initial value', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialValue: 50));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.value, 50.0);
      });

      testWidgets('builds with custom min/max', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 25,
          min: 10,
          max: 50,
        ));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.min, 10.0);
        expect(slider.max, 50.0);
      });

      testWidgets('builds with divisions', (tester) async {
        await tester.pumpWidget(buildTestWidget(divisions: 10));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.divisions, 10);
      });

      testWidgets('builds with custom label', (tester) async {
        await tester.pumpWidget(buildTestWidget(label: 'Custom Label'));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.label, 'Custom Label');
      });

      testWidgets('builds a default label when not provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialValue: 42));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.label, '42');
      });

      testWidgets('builds with custom colors', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          activeColor: Colors.red,
          inactiveColor: Colors.grey,
          thumbColor: Colors.blue,
        ));

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.activeColor, Colors.red);
        expect(slider.inactiveColor, Colors.grey);
        expect(slider.thumbColor, Colors.blue);
      });

      testWidgets('builds with custom button size', (tester) async {
        await tester.pumpWidget(buildTestWidget(buttonSize: 48));

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final buttonSizedBoxes = sizedBoxes.where(
          (box) => box.width == 48.0 && box.height == 48.0,
        );
        expect(buttonSizedBoxes.length, 2);
      });

      testWidgets('builds with custom button colors', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 50,
          buttonColor: Colors.green,
          buttonIconColor: Colors.yellow,
        ));

        final materials = tester.widgetList<Material>(find.byType(Material));
        final buttonMaterials = materials.where(
          (m) => m.shape is CircleBorder,
        );
        expect(buttonMaterials.any((m) => m.color == Colors.green), isTrue);

        final icons = tester.widgetList<Icon>(find.byType(Icon));
        expect(icons.any((i) => i.color == Colors.yellow), isTrue);
      });

      testWidgets('builds with haptic feedback enabled', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          enableHapticFeedback: true,
          hapticFeedbackType: HapticFeedbackType.heavy,
        ));

        expect(find.byType(StepSlider), findsOneWidget);
      });
    });

    group('all haptic feedback types', () {
      for (final type in HapticFeedbackType.values) {
        testWidgets('builds with $type haptic feedback', (tester) async {
          await tester.pumpWidget(buildTestWidget(
            initialValue: 50,
            enableHapticFeedback: true,
            hapticFeedbackType: type,
          ));

          expect(find.byType(StepSlider), findsOneWidget);

          // Tap decrement to trigger haptic
          await tester.tap(find.byIcon(Icons.remove));
          await tester.pump();
        });
      }
    });
  });
}

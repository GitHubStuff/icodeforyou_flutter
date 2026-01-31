// test/src/slider_cubit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_slider_package/step_slider_package.dart';

void main() {
  group('SliderCubit (via StepSlider)', () {
    late double capturedValue;
    late int changeCount;

    setUp(() {
      capturedValue = 0.0;
      changeCount = 0;
    });

    Widget buildTestWidget({
      double initialValue = 50.0,
      double min = 0.0,
      double max = 100.0,
      double step = 1.0,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: StepSlider(
            initialValue: initialValue,
            min: min,
            max: max,
            step: step,
            onChanged: (value) {
              capturedValue = value;
              changeCount++;
            },
          ),
        ),
      );
    }

    group('update', () {
      testWidgets('updates value when slider is dragged', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final slider = find.byType(Slider);
        await tester.drag(slider, const Offset(100, 0));
        await tester.pump();

        expect(changeCount, greaterThan(0));
      });

      testWidgets('updates value when increment button tapped', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialValue: 50.0, step: 5.0));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(capturedValue, 55.0);
        expect(changeCount, 1);
      });

      testWidgets('updates value when decrement button tapped', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialValue: 50.0, step: 5.0));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(capturedValue, 45.0);
        expect(changeCount, 1);
      });

      testWidgets('emits multiple updates on successive taps', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialValue: 50.0, step: 10.0));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(capturedValue, 60.0);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(capturedValue, 70.0);

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
        expect(capturedValue, 60.0);

        expect(changeCount, 3);
      });
    });

    group('state isolation', () {
      testWidgets('each StepSlider has independent state', (tester) async {
        double value1 = 0.0;
        double value2 = 0.0;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StepSlider(
                  key: const Key('slider1'),
                  initialValue: 25.0,
                  step: 5.0,
                  onChanged: (v) => value1 = v,
                ),
                StepSlider(
                  key: const Key('slider2'),
                  initialValue: 75.0,
                  step: 10.0,
                  onChanged: (v) => value2 = v,
                ),
              ],
            ),
          ),
        ));

        // Find buttons by their parent key
        final slider1Add = find.descendant(
          of: find.byKey(const Key('slider1')),
          matching: find.byIcon(Icons.add),
        );
        final slider2Remove = find.descendant(
          of: find.byKey(const Key('slider2')),
          matching: find.byIcon(Icons.remove),
        );

        await tester.tap(slider1Add);
        await tester.pump();
        expect(value1, 30.0);
        expect(value2, 0.0); // Unchanged

        await tester.tap(slider2Remove);
        await tester.pump();
        expect(value1, 30.0); // Unchanged
        expect(value2, 65.0);
      });
    });

    group('clamping behavior', () {
      testWidgets('clamps value at max when incrementing', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 98.0,
          max: 100.0,
          step: 5.0,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(capturedValue, 100.0);
      });

      testWidgets('clamps value at min when decrementing', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 2.0,
          min: 0.0,
          step: 5.0,
        ));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(capturedValue, 0.0);
      });
    });
  });
}

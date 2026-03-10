// test/src/step_button_test.dart
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_slider_package/step_slider_package.dart';

void main() {
  group('StepButton (via StepSlider)', () {
    Widget buildTestWidget({
      double initialValue = 50.0,
      double min = 0.0,
      double max = 100.0,
      double step = 1.0,
      Color? buttonColor,
      Color? buttonIconColor,
      double buttonSize = 36.0,
      bool enableHapticFeedback = false,
      HapticFeedbackType hapticFeedbackType = HapticFeedbackType.light,
      ValueChanged<double>? onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: StepSlider(
            initialValue: initialValue,
            min: min,
            max: max,
            step: step,
            buttonColor: buttonColor,
            buttonIconColor: buttonIconColor,
            buttonSize: buttonSize,
            enableHapticFeedback: enableHapticFeedback,
            hapticFeedbackType: hapticFeedbackType,
            onChanged: onChanged,
          ),
        ),
      );
    }

    group('enabled state', () {
      testWidgets('both buttons enabled when value is in middle', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final decrementInkWell = tester.widget<InkWell>(
          find.ancestor(
            of: find.byIcon(Icons.remove),
            matching: find.byType(InkWell),
          ),
        );
        final incrementInkWell = tester.widget<InkWell>(
          find.ancestor(
            of: find.byIcon(Icons.add),
            matching: find.byType(InkWell),
          ),
        );

        expect(decrementInkWell.onTap, isNotNull);
        expect(incrementInkWell.onTap, isNotNull);
      });

      testWidgets('decrement disabled at min value', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialValue: 0));

        final decrementInkWell = tester.widget<InkWell>(
          find.ancestor(
            of: find.byIcon(Icons.remove),
            matching: find.byType(InkWell),
          ),
        );

        expect(decrementInkWell.onTap, isNull);
      });

      testWidgets('increment disabled at max value', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialValue: 100));

        final incrementInkWell = tester.widget<InkWell>(
          find.ancestor(
            of: find.byIcon(Icons.add),
            matching: find.byType(InkWell),
          ),
        );

        expect(incrementInkWell.onTap, isNull);
      });

      testWidgets('button becomes disabled after reaching max', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 95,
          step: 10,
        ));

        // Initially enabled
        var incrementInkWell = tester.widget<InkWell>(
          find.ancestor(
            of: find.byIcon(Icons.add),
            matching: find.byType(InkWell),
          ),
        );
        expect(incrementInkWell.onTap, isNotNull);

        // Tap to reach max
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Now disabled
        incrementInkWell = tester.widget<InkWell>(
          find.ancestor(
            of: find.byIcon(Icons.add),
            matching: find.byType(InkWell),
          ),
        );
        expect(incrementInkWell.onTap, isNull);
      });

      testWidgets('button becomes disabled after reaching min', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 5,
          step: 10,
        ));

        // Initially enabled
        var decrementInkWell = tester.widget<InkWell>(
          find.ancestor(
            of: find.byIcon(Icons.remove),
            matching: find.byType(InkWell),
          ),
        );
        expect(decrementInkWell.onTap, isNotNull);

        // Tap to reach min
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        // Now disabled
        decrementInkWell = tester.widget<InkWell>(
          find.ancestor(
            of: find.byIcon(Icons.remove),
            matching: find.byType(InkWell),
          ),
        );
        expect(decrementInkWell.onTap, isNull);
      });
    });

    group('visual appearance', () {
      testWidgets('uses theme colors by default', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final materials = tester.widgetList<Material>(
          find.byType(Material),
        ).where((m) => m.shape is CircleBorder);

        expect(materials.length, 2);
      });

      testWidgets('uses custom button color when provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          buttonColor: Colors.purple,
        ));

        final materials = tester.widgetList<Material>(
          find.byType(Material),
        ).where((m) => m.shape is CircleBorder && m.color == Colors.purple);

        expect(materials.length, 2);
      });

      testWidgets('uses custom icon color when provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          buttonIconColor: Colors.orange,
        ));

        final icons = tester.widgetList<Icon>(find.byType(Icon));
        expect(icons.every((i) => i.color == Colors.orange), isTrue);
      });

      testWidgets('disabled button has reduced opacity color', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 0,
          buttonColor: Colors.blue,
        ));

        final decrementMaterial = tester.widget<Material>(
          find.ancestor(
            of: find.byIcon(Icons.remove),
            matching: find.byType(Material),
          ).first,
        );

        expect(decrementMaterial.color, Colors.blue.withValues(alpha: 0.4));
      });

      testWidgets('disabled icon has reduced opacity', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 0,
          buttonIconColor: Colors.white,
        ));

        final decrementIcon = tester.widget<Icon>(find.byIcon(Icons.remove));
        expect(decrementIcon.color, Colors.white.withValues(alpha: 0.4));
      });

      testWidgets('button size is applied correctly', (tester) async {
        await tester.pumpWidget(buildTestWidget(buttonSize: 48));

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final buttonSizedBoxes = sizedBoxes.where(
          (box) => box.width == 48.0 && box.height == 48.0,
        );

        expect(buttonSizedBoxes.length, 2);
      });

      testWidgets('icon size is 60% of button size', (tester) async {
        await tester.pumpWidget(buildTestWidget(buttonSize: 50));

        final icons = tester.widgetList<Icon>(find.byType(Icon));
        expect(icons.every((i) => i.size == 30.0), isTrue);
      });
    });

    group('haptic feedback', () {
      late List<String> hapticCalls;

      setUp(() {
        hapticCalls = [];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            // vibrate() passes no arguments, others pass a String
            final argument = call.arguments as String? ?? 'HapticFeedbackType.vibrate';
            hapticCalls.add(argument);
          }
          return null;
        });
      });

      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      testWidgets('no haptic when disabled', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(hapticCalls, isEmpty);
      });

      testWidgets('light haptic feedback triggers', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          enableHapticFeedback: true,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(hapticCalls, contains('HapticFeedbackType.lightImpact'));
      });

      testWidgets('medium haptic feedback triggers', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          enableHapticFeedback: true,
          hapticFeedbackType: HapticFeedbackType.medium,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(hapticCalls, contains('HapticFeedbackType.mediumImpact'));
      });

      testWidgets('heavy haptic feedback triggers', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          enableHapticFeedback: true,
          hapticFeedbackType: HapticFeedbackType.heavy,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(hapticCalls, contains('HapticFeedbackType.heavyImpact'));
      });

      testWidgets('selection haptic feedback triggers', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          enableHapticFeedback: true,
          hapticFeedbackType: HapticFeedbackType.selection,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(hapticCalls, contains('HapticFeedbackType.selectionClick'));
      });

      testWidgets('vibrate haptic feedback triggers', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          enableHapticFeedback: true,
          hapticFeedbackType: HapticFeedbackType.vibrate,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(hapticCalls, contains('HapticFeedbackType.vibrate'));
      });

      testWidgets('haptic triggers on decrement button too', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          enableHapticFeedback: true,
        ));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(hapticCalls, contains('HapticFeedbackType.lightImpact'));
      });
    });

    group('tap handling', () {
      testWidgets('increment button calls onChanged', (tester) async {
        double? changedValue;
        await tester.pumpWidget(buildTestWidget(
          step: 5,
          onChanged: (v) => changedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(changedValue, 55.0);
      });

      testWidgets('decrement button calls onChanged', (tester) async {
        double? changedValue;
        await tester.pumpWidget(buildTestWidget(
          step: 5,
          onChanged: (v) => changedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(changedValue, 45.0);
      });

      testWidgets('disabled button does not call onChanged', (tester) async {
        double? changedValue;
        await tester.pumpWidget(buildTestWidget(
          initialValue: 0,
          onChanged: (v) => changedValue = v,
        ));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(changedValue, isNull);
      });
    });
  });
}

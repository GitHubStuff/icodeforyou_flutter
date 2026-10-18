// packages/sliders/test/src/hslider_with_buttons_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodCall, SystemChannels;
import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:sliders/sliders.dart';

void main() {
  group('HSliderWithButtons', () {
    group('construction', () {
      test('asserts min < max', () {
        expect(
          () => HSliderWithButtons(step: 1, min: 1, max: 1),
          throwsAssertionError,
        );
      });

      test('asserts step > 0', () {
        expect(
          () => HSliderWithButtons(step: 0),
          throwsAssertionError,
        );
        expect(
          () => HSliderWithButtons(step: -1),
          throwsAssertionError,
        );
      });
    });

    group('initial value', () {
      testWidgets('defaults to the midpoint of [min, max]', (tester) async {
        await pumpSlider(
          tester,
          HSliderWithButtons(step: 1, min: 5, max: 10, onChanged: (_) {}),
        );

        expect(sliderOf(tester).value, 7.5);
      });

      testWidgets('uses initialValue when given', (tester) async {
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 1,
            min: 0,
            max: 10,
            initialValue: 3,
            onChanged: (_) {},
          ),
        );

        expect(sliderOf(tester).value, 3);
      });

      testWidgets('clamps initialValue above max', (tester) async {
        await pumpSlider(
          tester,
          HSliderWithButtons(step: 1, initialValue: 42, onChanged: (_) {}),
        );

        expect(sliderOf(tester).value, 1);
      });

      testWidgets('clamps initialValue below min', (tester) async {
        await pumpSlider(
          tester,
          HSliderWithButtons(step: 1, initialValue: -42, onChanged: (_) {}),
        );

        expect(sliderOf(tester).value, 0);
      });
    });

    group('buttons', () {
      testWidgets('increase adds step and notifies', (tester) async {
        final reported = <double>[];
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 2,
            min: 0,
            max: 10,
            initialValue: 4,
            onChanged: reported.add,
          ),
        );

        await tapIncrease(tester);

        expect(sliderOf(tester).value, 6);
        expect(reported, [6]);
      });

      testWidgets('decrease subtracts step and notifies', (tester) async {
        final reported = <double>[];
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 2,
            min: 0,
            max: 10,
            initialValue: 4,
            onChanged: reported.add,
          ),
        );

        await tapDecrease(tester);

        expect(sliderOf(tester).value, 2);
        expect(reported, [2]);
      });

      testWidgets('increase clamps an overshoot to max', (tester) async {
        final reported = <double>[];
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 5,
            min: 0,
            max: 10,
            initialValue: 8,
            onChanged: reported.add,
          ),
        );

        await tapIncrease(tester);

        expect(sliderOf(tester).value, 10);
        expect(reported, [10]);
      });

      testWidgets('decrease clamps an overshoot to min', (tester) async {
        final reported = <double>[];
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 5,
            min: 0,
            max: 10,
            initialValue: 2,
            onChanged: reported.add,
          ),
        );

        await tapDecrease(tester);

        expect(sliderOf(tester).value, 0);
        expect(reported, [0]);
      });

      testWidgets('increase is disabled at max, decrease enabled', (
        tester,
      ) async {
        await pumpSlider(
          tester,
          HSliderWithButtons(step: 1, initialValue: 1, onChanged: (_) {}),
        );

        expect(increaseButton(tester).onPressed, isNull);
        expect(decreaseButton(tester).onPressed, isNotNull);
      });

      testWidgets('decrease is disabled at min, increase enabled', (
        tester,
      ) async {
        await pumpSlider(
          tester,
          HSliderWithButtons(step: 1, initialValue: 0, onChanged: (_) {}),
        );

        expect(decreaseButton(tester).onPressed, isNull);
        expect(increaseButton(tester).onPressed, isNotNull);
      });

      testWidgets('re-enable after stepping away from a bound', (tester) async {
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 1,
            min: 0,
            max: 10,
            initialValue: 10,
            onChanged: (_) {},
          ),
        );
        expect(increaseButton(tester).onPressed, isNull);

        await tapDecrease(tester);

        expect(increaseButton(tester).onPressed, isNotNull);
      });

      testWidgets('forward haptic and fire it on tap', (tester) async {
        final haptics = <String>[];
        recordHaptics(tester, into: haptics);
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 1,
            haptic: .heavy,
            onChanged: (_) {},
          ),
        );

        final buttons = tester.widgetList<SliderButton>(
          find.byType(SliderButton),
        );
        expect(
          buttons.map((b) => b.haptic),
          everyElement(HapticIntensity.heavy),
        );

        await tapIncrease(tester);

        expect(haptics, ['HapticFeedbackType.heavyImpact']);
      });
    });

    group('slider', () {
      testWidgets('drag updates the value and notifies', (tester) async {
        final reported = <double>[];
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 1,
            initialValue: 0,
            onChanged: reported.add,
          ),
        );

        await tester.drag(find.byType(Slider), const Offset(50, 0));
        await tester.pump();

        expect(reported, isNotEmpty);
        expect(reported.last, greaterThan(0));
        expect(sliderOf(tester).value, reported.last);
      });

      testWidgets('forward divisions and sliderThemeData', (tester) async {
        const themeData = SliderThemeData(trackHeight: 8);
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 1,
            divisions: 4,
            sliderThemeData: themeData,
            onChanged: (_) {},
          ),
        );

        final slider = tester.widget<HorizontalSlider>(
          find.byType(HorizontalSlider),
        );
        expect(slider.divisions, 4);
        expect(slider.sliderTheme, same(themeData));
      });
    });

    group('disabled', () {
      testWidgets('null onChanged disables slider and both buttons', (
        tester,
      ) async {
        await pumpSlider(
          tester,
          const HSliderWithButtons(step: 1, initialValue: 0.5),
        );

        expect(sliderOf(tester).onChanged, isNull);
        expect(decreaseButton(tester).onPressed, isNull);
        expect(increaseButton(tester).onPressed, isNull);
      });
    });

    group('colour', () {
      testWidgets('tints both icons and the slider', (tester) async {
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 1,
            color: Colors.red,
            onChanged: (_) {},
          ),
        );

        final icons = tester.widgetList<Icon>(find.byType(Icon));
        expect(icons, hasLength(2));
        expect(icons.map((i) => i.color), everyElement(Colors.red));

        final slider = tester.widget<HorizontalSlider>(
          find.byType(HorizontalSlider),
        );
        expect(slider.color, Colors.red);
      });
    });

    group('range change', () {
      testWidgets('re-clamps the value without notifying', (tester) async {
        final reported = <double>[];
        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 1,
            min: 0,
            max: 1,
            initialValue: 0.8,
            onChanged: reported.add,
          ),
        );
        expect(sliderOf(tester).value, 0.8);

        await pumpSlider(
          tester,
          HSliderWithButtons(
            step: 1,
            min: 0,
            max: 0.5,
            initialValue: 0.8,
            onChanged: reported.add,
          ),
        );

        expect(sliderOf(tester).value, 0.5);
        expect(reported, isEmpty);
      });

      testWidgets('ignores a changed initialValue', (tester) async {
        await pumpSlider(
          tester,
          HSliderWithButtons(step: 1, initialValue: 0.2, onChanged: (_) {}),
        );

        await pumpSlider(
          tester,
          HSliderWithButtons(step: 1, initialValue: 0.9, onChanged: (_) {}),
        );

        expect(sliderOf(tester).value, 0.2);
      });
    });
  });
}

/// Pumps [child] inside the Material scaffolding the widget needs.
Future<void> pumpSlider(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

/// The Material [Slider] the widget ultimately renders.
Slider sliderOf(WidgetTester tester) =>
    tester.widget<Slider>(find.byType(Slider));

/// The [IconButton] behind the decrease [SliderButton].
IconButton decreaseButton(WidgetTester tester) => tester.widget<IconButton>(
  find.widgetWithIcon(IconButton, Icons.remove_circle_outline),
);

/// The [IconButton] behind the increase [SliderButton].
IconButton increaseButton(WidgetTester tester) => tester.widget<IconButton>(
  find.widgetWithIcon(IconButton, Icons.add_circle_outline),
);

Future<void> tapDecrease(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.remove_circle_outline));
  await tester.pump();
}

Future<void> tapIncrease(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.add_circle_outline));
  await tester.pump();
}

/// Intercepts the platform channel so haptic calls land in [into] (as
/// their `HapticFeedbackType` argument) instead of going nowhere.
void recordHaptics(WidgetTester tester, {required List<String> into}) {
  final messenger = tester.binding.defaultBinaryMessenger;

  Future<Object?> handler(MethodCall call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      into.add(call.arguments as String);
    }
    return null;
  }

  messenger.setMockMethodCallHandler(SystemChannels.platform, handler);
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
}

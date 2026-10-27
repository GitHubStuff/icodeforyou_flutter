// packages/sliders/test/src/hslider_with_buttons_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:sliders/sliders.dart'
    show Constants, HSliderWithButtons, HorizontalSlider, SliderButton;

Widget _harness(Widget child, {double? width}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: width == null ? child : SizedBox(width: width, child: child),
    ),
  ),
);

Finder get _decreaseFinder =>
    find.widgetWithIcon(IconButton, Icons.remove_circle_outline);

Finder get _increaseFinder =>
    find.widgetWithIcon(IconButton, Icons.add_circle_outline);

IconButton _decrease(WidgetTester tester) =>
    tester.widget<IconButton>(_decreaseFinder);

IconButton _increase(WidgetTester tester) =>
    tester.widget<IconButton>(_increaseFinder);

Slider _slider(WidgetTester tester) =>
    tester.widget<Slider>(find.byType(Slider));

HorizontalSlider _horizontal(WidgetTester tester) =>
    tester.widget<HorizontalSlider>(find.byType(HorizontalSlider));

void main() {
  group('HSliderWithButtons', () {
    group('constructor', () {
      test('defaults', () {
        const widget = HSliderWithButtons(step: 1);

        expect(widget.initialValue, isNull);
        expect(widget.min, 0);
        expect(widget.max, 1);
        expect(widget.divisions, isNull);
        expect(widget.onChanged, isNull);
        expect(widget.color, isNull);
        expect(widget.haptic, HapticIntensity.light);
        expect(widget.sliderThemeData, isNull);
      });

      test('asserts that min is less than max', () {
        expect(
          () => HSliderWithButtons(step: 1, min: 1, max: 1),
          throwsAssertionError,
        );
        expect(
          () => HSliderWithButtons(step: 1, min: 5, max: 1),
          throwsAssertionError,
        );
      });

      test('asserts that step is positive', () {
        expect(() => HSliderWithButtons(step: 0), throwsAssertionError);
        expect(() => HSliderWithButtons(step: -1), throwsAssertionError);
      });
    });

    group('layout', () {
      testWidgets('renders two buttons around one slider', (tester) async {
        await tester.pumpWidget(
          _harness(HSliderWithButtons(step: 1, onChanged: (_) {})),
        );

        expect(find.byType(SliderButton), findsNWidgets(2));
        expect(find.byType(HorizontalSlider), findsOneWidget);
        expect(_decreaseFinder, findsOneWidget);
        expect(_increaseFinder, findsOneWidget);
        expect(find.byTooltip('Decrease'), findsOneWidget);
        expect(find.byTooltip('Increase'), findsOneWidget);
      });

      testWidgets('places decrease, slider, increase in order', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(HSliderWithButtons(step: 1, onChanged: (_) {})),
        );

        final decreaseX = tester.getCenter(_decreaseFinder).dx;
        final sliderX = tester.getCenter(find.byType(Slider)).dx;
        final increaseX = tester.getCenter(_increaseFinder).dx;

        expect(decreaseX, lessThan(sliderX));
        expect(sliderX, lessThan(increaseX));
      });

      testWidgets('asserts when narrower than Constants.sliderWidth', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(step: 1, onChanged: (_) {}),
            width: Constants.sliderWidth - 1,
          ),
        );

        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('lays out at exactly Constants.sliderWidth', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(step: 1, onChanged: (_) {}),
            width: Constants.sliderWidth,
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(Slider), findsOneWidget);
      });
    });

    group('initial value', () {
      testWidgets('defaults to the midpoint of the range', (tester) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(step: 1, min: 2, max: 10, onChanged: (_) {}),
          ),
        );

        expect(_slider(tester).value, 6);
      });

      testWidgets('uses initialValue when given', (tester) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 3,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_slider(tester).value, 3);
      });

      testWidgets('clamps an initialValue above max', (tester) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 42,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_slider(tester).value, 10);
      });

      testWidgets('clamps an initialValue below min', (tester) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              min: 5,
              max: 10,
              initialValue: -1,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_slider(tester).value, 5);
      });

      testWidgets('ignores later changes to initialValue', (tester) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 2,
              onChanged: (_) {},
            ),
          ),
        );
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 9,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_slider(tester).value, 2);
      });

      testWidgets('a new Key resets to the new initialValue', (tester) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              key: const ValueKey(1),
              step: 1,
              max: 10,
              initialValue: 2,
              onChanged: (_) {},
            ),
          ),
        );
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              key: const ValueKey(2),
              step: 1,
              max: 10,
              initialValue: 9,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_slider(tester).value, 9);
      });
    });

    group('range updates', () {
      testWidgets('clamps the value when max drops below it', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 8,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 5,
              initialValue: 8,
              onChanged: reported.add,
            ),
          ),
        );

        expect(_slider(tester).value, 5);
        expect(reported, isEmpty);
      });

      testWidgets('clamps the value when min rises above it', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 2,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              min: 4,
              max: 10,
              initialValue: 2,
              onChanged: reported.add,
            ),
          ),
        );

        expect(_slider(tester).value, 4);
        expect(reported, isEmpty);
      });

      testWidgets('keeps the value when it is still in range', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 3,
              onChanged: (_) {},
            ),
          ),
        );
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 20,
              initialValue: 3,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_slider(tester).value, 3);
      });
    });

    group('buttons', () {
      testWidgets('increase adds step and reports it', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 2,
              max: 10,
              initialValue: 3,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.tap(_increaseFinder);
        await tester.pump();

        expect(reported, [5]);
        expect(_slider(tester).value, 5);
      });

      testWidgets('decrease subtracts step and reports it', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 2,
              max: 10,
              initialValue: 3,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.tap(_decreaseFinder);
        await tester.pump();

        expect(reported, [1]);
        expect(_slider(tester).value, 1);
      });

      testWidgets('increase clamps an overshoot to max', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 4,
              max: 10,
              initialValue: 8,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.tap(_increaseFinder);
        await tester.pump();

        expect(reported, [10]);
        expect(_slider(tester).value, 10);
      });

      testWidgets('decrease clamps an overshoot to min', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 4,
              max: 10,
              initialValue: 2,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.tap(_decreaseFinder);
        await tester.pump();

        expect(reported, [0]);
        expect(_slider(tester).value, 0);
      });

      testWidgets('repeated taps accumulate', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 5,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.tap(_increaseFinder);
        await tester.pump();
        await tester.tap(_increaseFinder);
        await tester.pump();
        await tester.tap(_decreaseFinder);
        await tester.pump();

        expect(reported, [6, 7, 6]);
        expect(_slider(tester).value, 6);
      });

      testWidgets('step is independent of divisions', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 0.5,
              max: 10,
              divisions: 10,
              initialValue: 5,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.tap(_increaseFinder);
        await tester.pump();

        expect(reported, [5.5]);
        expect(_slider(tester).value, 5.5);
      });
    });

    group('enabled state', () {
      testWidgets('both buttons enabled strictly inside the range', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 5,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_decrease(tester).onPressed, isNotNull);
        expect(_increase(tester).onPressed, isNotNull);
        expect(_slider(tester).onChanged, isNotNull);
      });

      testWidgets('decrease is disabled at min', (tester) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 0,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_decrease(tester).onPressed, isNull);
        expect(_increase(tester).onPressed, isNotNull);
        expect(_slider(tester).onChanged, isNotNull);
      });

      testWidgets('increase is disabled at max', (tester) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 10,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_decrease(tester).onPressed, isNotNull);
        expect(_increase(tester).onPressed, isNull);
        expect(_slider(tester).onChanged, isNotNull);
      });

      testWidgets('buttons toggle as the value reaches a bound', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 2,
              initialValue: 1,
              onChanged: (_) {},
            ),
          ),
        );
        await tester.tap(_increaseFinder);
        await tester.pump();

        expect(_increase(tester).onPressed, isNull);
        expect(_decrease(tester).onPressed, isNotNull);

        await tester.tap(_decreaseFinder);
        await tester.pump();

        expect(_increase(tester).onPressed, isNotNull);
        expect(_decrease(tester).onPressed, isNotNull);
      });

      testWidgets('a null onChanged disables everything', (tester) async {
        await tester.pumpWidget(
          _harness(
            const HSliderWithButtons(step: 1, max: 10, initialValue: 5),
          ),
        );

        expect(_decrease(tester).onPressed, isNull);
        expect(_increase(tester).onPressed, isNull);
        expect(_slider(tester).onChanged, isNull);
      });

      testWidgets('tapping a disabled button changes nothing', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            const HSliderWithButtons(step: 1, max: 10, initialValue: 5),
          ),
        );
        await tester.tap(_increaseFinder);
        await tester.pump();

        expect(_slider(tester).value, 5);
      });
    });

    group('slider', () {
      testWidgets('dragging updates the value and reports it', (
        tester,
      ) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              initialValue: 0,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.drag(find.byType(Slider), const Offset(60, 0));
        await tester.pumpAndSettle();

        expect(reported, isNotEmpty);
        expect(_slider(tester).value, reported.last);
        for (final value in reported) {
          expect(value, inInclusiveRange(0, 10));
        }
      });

      testWidgets('dragging with divisions reports snapped values', (
        tester,
      ) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              max: 10,
              divisions: 10,
              initialValue: 0,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.drag(find.byType(Slider), const Offset(60, 0));
        await tester.pumpAndSettle();

        expect(reported, isNotEmpty);
        for (final value in reported) {
          expect(value, closeTo(value.roundToDouble(), 1e-9));
        }
      });
    });

    group('forwarding', () {
      testWidgets('min, max and divisions reach HorizontalSlider', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              min: 1,
              max: 9,
              divisions: 8,
              onChanged: (_) {},
            ),
          ),
        );

        final slider = _horizontal(tester);
        expect(slider.min, 1);
        expect(slider.max, 9);
        expect(slider.divisions, 8);
      });

      testWidgets('color reaches both icons and the slider', (tester) async {
        const color = Colors.deepOrange;

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(step: 1, color: color, onChanged: (_) {}),
          ),
        );

        final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
        expect(icons, hasLength(2));
        for (final icon in icons) {
          expect(icon.color, color);
        }
        expect(_horizontal(tester).color, color);
      });

      testWidgets('haptic reaches both buttons', (tester) async {
        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(step: 1, haptic: .heavy, onChanged: (_) {}),
          ),
        );

        final buttons = tester
            .widgetList<SliderButton>(find.byType(SliderButton))
            .toList();
        expect(buttons, hasLength(2));
        for (final button in buttons) {
          expect(button.haptic, HapticIntensity.heavy);
        }
      });

      testWidgets('sliderThemeData reaches HorizontalSlider', (tester) async {
        const themeData = SliderThemeData(trackHeight: 7);

        await tester.pumpWidget(
          _harness(
            HSliderWithButtons(
              step: 1,
              sliderThemeData: themeData,
              onChanged: (_) {},
            ),
          ),
        );

        expect(_horizontal(tester).sliderTheme, same(themeData));
      });
    });
  });
}

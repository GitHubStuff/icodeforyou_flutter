// packages/sliders/test/src/horizontal_slider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliders/sliders.dart' show HorizontalSlider;

const _width = 340.0;

Widget _harness(Widget child, {SliderThemeData? ambient}) {
  final body = Center(
    child: SizedBox(width: _width, child: child),
  );
  return MaterialApp(
    theme: ambient == null ? null : ThemeData(sliderTheme: ambient),
    home: Scaffold(body: body),
  );
}

Slider _slider(WidgetTester tester) =>
    tester.widget<Slider>(find.byType(Slider));

/// The fully resolved theme the inner [Slider] actually sees.
SliderThemeData _resolved(WidgetTester tester) =>
    SliderTheme.of(tester.element(find.byType(Slider)));

void main() {
  group('HorizontalSlider', () {
    group('constructor', () {
      test('defaults min to 0 and max to 1', () {
        const slider = HorizontalSlider(value: 0.5);

        expect(slider.min, 0);
        expect(slider.max, 1);
        expect(slider.divisions, isNull);
        expect(slider.color, isNull);
        expect(slider.sliderTheme, isNull);
        expect(slider.onChanged, isNull);
      });

      test('asserts that min is less than max', () {
        expect(
          () => HorizontalSlider(value: 0, min: 1, max: 1),
          throwsAssertionError,
        );
        expect(
          () => HorizontalSlider(value: 0, min: 2, max: 1),
          throwsAssertionError,
        );
      });
    });

    group('value forwarding', () {
      testWidgets('forwards value, min, max and divisions', (tester) async {
        await tester.pumpWidget(
          _harness(
            HorizontalSlider(
              value: 4,
              min: 2,
              max: 8,
              divisions: 3,
              onChanged: (_) {},
            ),
          ),
        );

        final slider = _slider(tester);
        expect(slider.value, 4);
        expect(slider.min, 2);
        expect(slider.max, 8);
        expect(slider.divisions, 3);
      });

      testWidgets('clamps a value above max for display', (tester) async {
        await tester.pumpWidget(
          _harness(HorizontalSlider(value: 99, max: 10, onChanged: (_) {})),
        );

        expect(_slider(tester).value, 10);
      });

      testWidgets('clamps a value below min for display', (tester) async {
        await tester.pumpWidget(
          _harness(
            HorizontalSlider(value: -5, min: 1, max: 10, onChanged: (_) {}),
          ),
        );

        expect(_slider(tester).value, 1);
      });
    });

    group('enabled state', () {
      testWidgets('a null onChanged disables the Slider', (tester) async {
        await tester.pumpWidget(_harness(const HorizontalSlider(value: 0.5)));

        expect(_slider(tester).onChanged, isNull);
      });

      testWidgets('a non-null onChanged enables the Slider', (tester) async {
        await tester.pumpWidget(
          _harness(HorizontalSlider(value: 0.5, onChanged: (_) {})),
        );

        expect(_slider(tester).onChanged, isNotNull);
      });
    });

    group('interaction', () {
      testWidgets('dragging reports in-range values', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(
              value: 0,
              max: 10,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.drag(find.byType(Slider), const Offset(100, 0));
        await tester.pumpAndSettle();

        expect(reported, isNotEmpty);
        for (final value in reported) {
          expect(value, inInclusiveRange(0, 10));
        }
      });

      testWidgets('an out-of-range value reports in range after a drag', (
        tester,
      ) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(
              value: 50,
              max: 10,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.drag(find.byType(Slider), const Offset(-100, 0));
        await tester.pumpAndSettle();

        expect(reported, isNotEmpty);
        expect(reported.first, inInclusiveRange(0, 10));
      });

      testWidgets('divisions snap reported values', (tester) async {
        final reported = <double>[];

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(
              value: 0,
              max: 10,
              divisions: 10,
              onChanged: reported.add,
            ),
          ),
        );
        await tester.drag(find.byType(Slider), const Offset(100, 0));
        await tester.pumpAndSettle();

        expect(reported, isNotEmpty);
        for (final value in reported) {
          expect(value, closeTo(value.roundToDouble(), 1e-9));
        }
      });
    });

    group('theme resolution', () {
      testWidgets('applies defaultShapes over the ambient theme', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            HorizontalSlider(value: 0.5, divisions: 4, onChanged: (_) {}),
          ),
        );

        final theme = _resolved(tester);
        expect(theme.thumbShape, isA<RoundSliderThumbShape>());
        expect(theme.trackShape, isA<RoundedRectSliderTrackShape>());
        expect(theme.overlayShape, isA<RoundSliderOverlayShape>());
        expect(theme.tickMarkShape, same(SliderTickMarkShape.noTickMark));
        expect(theme.trackGap, 0);
        expect(theme.padding, const EdgeInsets.symmetric(horizontal: 10));
      });

      test('defaultShapes exposes the same values', () {
        final shapes = HorizontalSlider.defaultShapes;

        expect(shapes.thumbShape, isA<RoundSliderThumbShape>());
        expect(shapes.trackShape, isA<RoundedRectSliderTrackShape>());
        expect(shapes.overlayShape, isA<RoundSliderOverlayShape>());
        expect(shapes.tickMarkShape, same(SliderTickMarkShape.noTickMark));
        expect(shapes.trackGap, 0);
        expect(shapes.padding, const EdgeInsets.symmetric(horizontal: 10));
      });

      testWidgets('keeps ambient fields that defaultShapes does not set', (
        tester,
      ) async {
        const ambient = SliderThemeData(
          trackHeight: 12,
          activeTrackColor: Colors.red,
        );

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(value: 0.5, onChanged: (_) {}),
            ambient: ambient,
          ),
        );

        final theme = _resolved(tester);
        expect(theme.trackHeight, 12);
        expect(theme.activeTrackColor, Colors.red);
      });

      testWidgets('a null color leaves ambient colours untouched', (
        tester,
      ) async {
        const ambient = SliderThemeData(
          activeTrackColor: Colors.red,
          inactiveTrackColor: Colors.green,
          thumbColor: Colors.blue,
          overlayColor: Colors.yellow,
        );

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(value: 0.5, onChanged: (_) {}),
            ambient: ambient,
          ),
        );

        final theme = _resolved(tester);
        expect(theme.activeTrackColor, Colors.red);
        expect(theme.inactiveTrackColor, Colors.green);
        expect(theme.thumbColor, Colors.blue);
        expect(theme.overlayColor, Colors.yellow);
      });

      testWidgets('color tints track, thumb and overlay', (tester) async {
        const color = Colors.deepOrange;

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(value: 0.5, color: color, onChanged: (_) {}),
          ),
        );

        final theme = _resolved(tester);
        expect(theme.activeTrackColor, color);
        expect(theme.inactiveTrackColor, color);
        expect(theme.thumbColor, color);
        expect(theme.overlayColor, color.withValues(alpha: 0.15));
      });

      testWidgets('color overrides ambient colours', (tester) async {
        const ambient = SliderThemeData(activeTrackColor: Colors.red);

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(
              value: 0.5,
              color: Colors.purple,
              onChanged: (_) {},
            ),
            ambient: ambient,
          ),
        );

        expect(_resolved(tester).activeTrackColor, Colors.purple);
      });

      testWidgets('sliderTheme wins over the color tint', (tester) async {
        await tester.pumpWidget(
          _harness(
            HorizontalSlider(
              value: 0.5,
              color: Colors.purple,
              sliderTheme: const SliderThemeData(
                activeTrackColor: Colors.teal,
              ),
              onChanged: (_) {},
            ),
          ),
        );

        final theme = _resolved(tester);
        expect(theme.activeTrackColor, Colors.teal);
        expect(theme.inactiveTrackColor, Colors.purple);
        expect(theme.thumbColor, Colors.purple);
      });

      testWidgets('sliderTheme can override defaultShapes', (tester) async {
        const customPadding = EdgeInsets.all(24);

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(
              value: 0.5,
              sliderTheme: const SliderThemeData(
                trackGap: 6,
                padding: customPadding,
              ),
              onChanged: (_) {},
            ),
          ),
        );

        final theme = _resolved(tester);
        expect(theme.trackGap, 6);
        expect(theme.padding, customPadding);
        expect(theme.thumbShape, isA<RoundSliderThumbShape>());
      });

      testWidgets('sliderTheme only overrides the fields it sets', (
        tester,
      ) async {
        const ambient = SliderThemeData(trackHeight: 9);

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(
              value: 0.5,
              sliderTheme: const SliderThemeData(thumbColor: Colors.black),
              onChanged: (_) {},
            ),
            ambient: ambient,
          ),
        );

        final theme = _resolved(tester);
        expect(theme.thumbColor, Colors.black);
        expect(theme.trackHeight, 9);
      });

      testWidgets('every merged field survives a round trip', (tester) async {
        // Exercises every argument of the private merge extension by
        // setting them all in sliderTheme and checking they all arrive.
        const indicatorStyle = TextStyle(fontSize: 9);
        final full = SliderThemeData(
          activeTickMarkColor: Colors.red,
          activeTrackColor: Colors.green,
          allowedInteraction: SliderInteraction.tapOnly,
          disabledActiveTickMarkColor: Colors.blue,
          disabledActiveTrackColor: Colors.yellow,
          disabledInactiveTickMarkColor: Colors.orange,
          disabledInactiveTrackColor: Colors.purple,
          disabledSecondaryActiveTrackColor: Colors.pink,
          disabledThumbColor: Colors.brown,
          inactiveTickMarkColor: Colors.cyan,
          inactiveTrackColor: Colors.lime,
          minThumbSeparation: 3,
          mouseCursor: WidgetStateMouseCursor.clickable,
          overlappingShapeStrokeColor: Colors.indigo,
          overlayColor: Colors.teal,
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 5),
          padding: const EdgeInsets.all(2),
          rangeThumbShape: const RoundRangeSliderThumbShape(),
          rangeTickMarkShape: const RoundRangeSliderTickMarkShape(),
          rangeTrackShape: const RectangularRangeSliderTrackShape(),
          rangeValueIndicatorShape:
              const PaddleRangeSliderValueIndicatorShape(),
          secondaryActiveTrackColor: Colors.amber,
          showValueIndicator: ShowValueIndicator.alwaysVisible,
          thumbColor: Colors.grey,
          thumbSelector: (_, _, _, _, _, _) => Thumb.start,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          thumbSize: const WidgetStatePropertyAll(Size(4, 4)),
          tickMarkShape: const RoundSliderTickMarkShape(),
          trackGap: 1,
          trackHeight: 11,
          trackShape: const RectangularSliderTrackShape(),
          valueIndicatorColor: Colors.white,
          valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
          valueIndicatorStrokeColor: Colors.black,
          valueIndicatorTextStyle: indicatorStyle,
        );

        await tester.pumpWidget(
          _harness(
            HorizontalSlider(
              value: 0.5,
              color: Colors.deepOrange,
              sliderTheme: full,
              onChanged: (_) {},
            ),
          ),
        );

        final theme = _resolved(tester);
        expect(theme.activeTickMarkColor, full.activeTickMarkColor);
        expect(theme.activeTrackColor, full.activeTrackColor);
        expect(theme.allowedInteraction, full.allowedInteraction);
        expect(
          theme.disabledActiveTickMarkColor,
          full.disabledActiveTickMarkColor,
        );
        expect(theme.disabledActiveTrackColor, full.disabledActiveTrackColor);
        expect(
          theme.disabledInactiveTickMarkColor,
          full.disabledInactiveTickMarkColor,
        );
        expect(
          theme.disabledInactiveTrackColor,
          full.disabledInactiveTrackColor,
        );
        expect(
          theme.disabledSecondaryActiveTrackColor,
          full.disabledSecondaryActiveTrackColor,
        );
        expect(theme.disabledThumbColor, full.disabledThumbColor);
        expect(theme.inactiveTickMarkColor, full.inactiveTickMarkColor);
        expect(theme.inactiveTrackColor, full.inactiveTrackColor);
        expect(theme.minThumbSeparation, full.minThumbSeparation);
        expect(theme.mouseCursor, full.mouseCursor);
        expect(
          theme.overlappingShapeStrokeColor,
          full.overlappingShapeStrokeColor,
        );
        expect(theme.overlayColor, full.overlayColor);
        expect(theme.overlayShape, full.overlayShape);
        expect(theme.padding, full.padding);
        expect(theme.rangeThumbShape, full.rangeThumbShape);
        expect(theme.rangeTickMarkShape, full.rangeTickMarkShape);
        expect(theme.rangeTrackShape, full.rangeTrackShape);
        expect(theme.rangeValueIndicatorShape, full.rangeValueIndicatorShape);
        expect(theme.secondaryActiveTrackColor, full.secondaryActiveTrackColor);
        expect(theme.showValueIndicator, full.showValueIndicator);
        expect(theme.thumbColor, full.thumbColor);
        expect(theme.thumbSelector, full.thumbSelector);
        expect(theme.thumbShape, full.thumbShape);
        expect(theme.thumbSize, full.thumbSize);
        expect(theme.tickMarkShape, full.tickMarkShape);
        expect(theme.trackGap, full.trackGap);
        expect(theme.trackHeight, full.trackHeight);
        expect(theme.trackShape, full.trackShape);
        expect(theme.valueIndicatorColor, full.valueIndicatorColor);
        expect(theme.valueIndicatorShape, full.valueIndicatorShape);
        expect(theme.valueIndicatorStrokeColor, full.valueIndicatorStrokeColor);
        expect(theme.valueIndicatorTextStyle, full.valueIndicatorTextStyle);
      });
    });
  });
}

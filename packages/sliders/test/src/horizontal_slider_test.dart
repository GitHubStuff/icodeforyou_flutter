// packages/sliders/test/src/horizontal_slider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliders/sliders.dart';

void main() {
  group('HorizontalSlider', () {
    group('construction', () {
      test('asserts min < max', () {
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

    group('value and range', () {
      testWidgets('forwards value, min, max and divisions', (tester) async {
        await pumpSlider(
          tester,
          HorizontalSlider(
            value: 3,
            min: 0,
            max: 10,
            divisions: 5,
            onChanged: (_) {},
          ),
        );

        final slider = sliderOf(tester);
        expect(slider.value, 3);
        expect(slider.min, 0);
        expect(slider.max, 10);
        expect(slider.divisions, 5);
      });

      testWidgets('clamps a value above max for display', (tester) async {
        await pumpSlider(
          tester,
          HorizontalSlider(value: 42, onChanged: (_) {}),
        );

        expect(sliderOf(tester).value, 1);
      });

      testWidgets('clamps a value below min for display', (tester) async {
        await pumpSlider(
          tester,
          HorizontalSlider(value: -42, onChanged: (_) {}),
        );

        expect(sliderOf(tester).value, 0);
      });

      testWidgets('leaves divisions null for a continuous slider', (
        tester,
      ) async {
        await pumpSlider(
          tester,
          HorizontalSlider(value: 0.5, onChanged: (_) {}),
        );

        expect(sliderOf(tester).divisions, isNull);
      });
    });

    group('onChanged', () {
      testWidgets('reports an in-range value on drag', (tester) async {
        final reported = <double>[];
        await pumpSlider(
          tester,
          HorizontalSlider(value: 0, onChanged: reported.add),
        );

        await tester.drag(find.byType(Slider), const Offset(50, 0));
        await tester.pump();

        expect(reported, isNotEmpty);
        expect(reported.last, greaterThan(0));
        expect(reported.last, lessThanOrEqualTo(1));
      });

      testWidgets('null disables the slider', (tester) async {
        await pumpSlider(tester, const HorizontalSlider(value: 0.5));

        expect(sliderOf(tester).onChanged, isNull);
      });
    });

    group('theme resolution', () {
      testWidgets('applies defaultShapes over the ambient theme', (
        tester,
      ) async {
        await pumpSlider(
          tester,
          HorizontalSlider(value: 0.5, onChanged: (_) {}),
        );

        final theme = resolvedTheme(tester);
        expect(theme.thumbShape, isA<RoundSliderThumbShape>());
        expect(theme.trackShape, isA<RoundedRectSliderTrackShape>());
        expect(theme.overlayShape, isA<RoundSliderOverlayShape>());
        expect(theme.tickMarkShape, SliderTickMarkShape.noTickMark);
        expect(theme.trackGap, 0);
        expect(theme.padding, const EdgeInsets.symmetric(horizontal: 10));
      });

      testWidgets('keeps ambient fields that no layer overrides', (
        tester,
      ) async {
        await pumpSlider(
          tester,
          HorizontalSlider(value: 0.5, onChanged: (_) {}),
          ambient: const SliderThemeData(trackHeight: 8),
        );

        expect(resolvedTheme(tester).trackHeight, 8);
      });

      testWidgets('leaves colours on the ambient theme when color is null', (
        tester,
      ) async {
        await pumpSlider(
          tester,
          HorizontalSlider(value: 0.5, onChanged: (_) {}),
          ambient: const SliderThemeData(
            activeTrackColor: Colors.green,
            thumbColor: Colors.green,
          ),
        );

        final theme = resolvedTheme(tester);
        expect(theme.activeTrackColor, Colors.green);
        expect(theme.thumbColor, Colors.green);
      });

      testWidgets('tints track, thumb and overlay from color', (tester) async {
        await pumpSlider(
          tester,
          HorizontalSlider(
            value: 0.5,
            color: Colors.red,
            onChanged: (_) {},
          ),
        );

        final theme = resolvedTheme(tester);
        expect(theme.activeTrackColor, Colors.red);
        expect(theme.inactiveTrackColor, Colors.red);
        expect(theme.thumbColor, Colors.red);
        expect(theme.overlayColor, Colors.red.withValues(alpha: 0.15));
      });

      testWidgets('sliderTheme wins over the color tint', (tester) async {
        await pumpSlider(
          tester,
          HorizontalSlider(
            value: 0.5,
            color: Colors.red,
            sliderTheme: const SliderThemeData(activeTrackColor: Colors.blue),
            onChanged: (_) {},
          ),
        );

        final theme = resolvedTheme(tester);
        expect(theme.activeTrackColor, Colors.blue);
        expect(theme.thumbColor, Colors.red);
      });

      testWidgets('sliderTheme wins over defaultShapes', (tester) async {
        await pumpSlider(
          tester,
          HorizontalSlider(
            value: 0.5,
            sliderTheme: const SliderThemeData(
              tickMarkShape: RoundSliderTickMarkShape(),
              trackGap: 4,
            ),
            onChanged: (_) {},
          ),
        );

        final theme = resolvedTheme(tester);
        expect(theme.tickMarkShape, isA<RoundSliderTickMarkShape>());
        expect(theme.trackGap, 4);
        expect(theme.thumbShape, isA<RoundSliderThumbShape>());
      });
    });
  });
}

/// Pumps [child] inside a [MaterialApp], optionally with an ambient
/// [SliderThemeData] installed on the app theme.
Future<void> pumpSlider(
  WidgetTester tester,
  Widget child, {
  SliderThemeData? ambient,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(sliderTheme: ambient),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

/// The Material [Slider] the widget ultimately renders.
Slider sliderOf(WidgetTester tester) =>
    tester.widget<Slider>(find.byType(Slider));

/// The fully resolved theme the widget hands to its [Slider], read from
/// the nearest [SliderTheme] ancestor.
SliderThemeData resolvedTheme(WidgetTester tester) {
  final nearest = find
      .ancestor(of: find.byType(Slider), matching: find.byType(SliderTheme))
      .first;
  return tester.widget<SliderTheme>(nearest).data;
}

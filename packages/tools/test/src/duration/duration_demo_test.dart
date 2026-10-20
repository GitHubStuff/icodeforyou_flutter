// packages/tools/test/src/duration/duration_demo_test.dart

import 'package:caption_switch/caption_switch.dart' show CaptionSwitch;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliders/sliders.dart' show HSliderWithButtons;
import 'package:tools/tools.dart' show DurationDemo;

const _zeroFormat = '%d %h:%02m:%02s';
const _negativeFormat = '%n%d %h:%02m:%02s';

enum _Slider { days, hours, minutes, seconds }

Future<void> _pump(WidgetTester tester) => tester.pumpWidget(
  const MaterialApp(home: Scaffold(body: DurationDemo())),
);

/// Drives one unit slider by invoking its `onChanged` with [value].
Future<void> _setUnit(WidgetTester tester, _Slider slider, int value) async {
  final widget = tester.widget<HSliderWithButtons>(
    find.byType(HSliderWithButtons).at(slider.index),
  );
  widget.onChanged!(value.toDouble());
  await tester.pump();
}

/// Taps the real increase button of one unit slider.
Future<void> _tapIncrease(WidgetTester tester, _Slider slider) async {
  await tester.tap(find.byTooltip('Increase').at(slider.index));
  await tester.pump();
}

Future<void> _toggleSign(WidgetTester tester) async {
  await tester.tap(find.byType(SwitchListTile));
  await tester.pump();
}

CaptionSwitch _switch(WidgetTester tester) =>
    tester.widget<CaptionSwitch>(find.byType(CaptionSwitch));

void main() {
  group('DurationDemo', () {
    group('initial state', () {
      testWidgets('shows the zero template and output', (tester) async {
        await _pump(tester);

        expect(find.text('FMT:'), findsOneWidget);
        expect(find.text(_zeroFormat), findsOneWidget);
        expect(find.text('OUT:'), findsOneWidget);
        expect(find.text('0 0:00:00'), findsOneWidget);
      });

      testWidgets('all unit readouts are zero', (tester) async {
        await _pump(tester);

        expect(find.text('Days: 0'), findsOneWidget);
        expect(find.text('Hours: 0'), findsOneWidget);
        expect(find.text('Minutes: 0'), findsOneWidget);
        expect(find.text('Seconds: 0'), findsOneWidget);
      });

      testWidgets('sign switch is off', (tester) async {
        await _pump(tester);

        expect(_switch(tester).value, isFalse);
        expect(find.text('Negative duration'), findsOneWidget);
        expect(find.text('toggle sign of duration'), findsOneWidget);
      });

      testWidgets('has four sliders with their natural bounds', (tester) async {
        await _pump(tester);

        final sliders = tester
            .widgetList<HSliderWithButtons>(find.byType(HSliderWithButtons))
            .toList();

        expect(sliders, hasLength(4));
        expect(sliders[_Slider.days.index].max, 20);
        expect(sliders[_Slider.hours.index].max, 23);
        expect(sliders[_Slider.minutes.index].max, 59);
        expect(sliders[_Slider.seconds.index].max, 59);
        for (final slider in sliders) {
          expect(slider.min, 0);
          expect(slider.step, 1);
          expect(slider.divisions, slider.max.round());
          expect(slider.initialValue, 0);
          expect(slider.color, Colors.deepOrange);
          expect(slider.onChanged, isNotNull);
        }
      });
    });

    group('unit sliders', () {
      testWidgets('seconds', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.seconds, 5);

        expect(find.text('Seconds: 5'), findsOneWidget);
        expect(find.text('0 0:00:05'), findsOneWidget);
      });

      testWidgets('minutes', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.minutes, 7);

        expect(find.text('Minutes: 7'), findsOneWidget);
        expect(find.text('0 0:07:00'), findsOneWidget);
      });

      testWidgets('hours', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.hours, 3);

        expect(find.text('Hours: 3'), findsOneWidget);
        expect(find.text('0 3:00:00'), findsOneWidget);
      });

      testWidgets('days', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.days, 2);

        expect(find.text('Days: 2'), findsOneWidget);
        expect(find.text('2 0:00:00'), findsOneWidget);
      });

      testWidgets('changing one unit keeps the others', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.seconds, 5);
        await _setUnit(tester, _Slider.hours, 3);
        await _setUnit(tester, _Slider.days, 2);
        await _setUnit(tester, _Slider.minutes, 7);

        expect(find.text('Days: 2'), findsOneWidget);
        expect(find.text('Hours: 3'), findsOneWidget);
        expect(find.text('Minutes: 7'), findsOneWidget);
        expect(find.text('Seconds: 5'), findsOneWidget);
        expect(find.text('2 3:07:05'), findsOneWidget);
      });

      testWidgets('a unit can be set back to zero', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.hours, 3);
        await _setUnit(tester, _Slider.hours, 0);

        expect(find.text('Hours: 0'), findsOneWidget);
        expect(find.text('0 0:00:00'), findsOneWidget);
      });

      testWidgets('the increase button drives the demo end to end', (
        tester,
      ) async {
        await _pump(tester);
        await _tapIncrease(tester, _Slider.seconds);
        await _tapIncrease(tester, _Slider.seconds);
        await _tapIncrease(tester, _Slider.minutes);

        expect(find.text('Seconds: 2'), findsOneWidget);
        expect(find.text('Minutes: 1'), findsOneWidget);
        expect(find.text('0 0:01:02'), findsOneWidget);
      });

      testWidgets('template stays day-led regardless of magnitude', (
        tester,
      ) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.seconds, 1);

        expect(find.text(_zeroFormat), findsOneWidget);
      });
    });

    group('sign switch', () {
      testWidgets('turning on negates the duration', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.seconds, 5);
        await _toggleSign(tester);

        expect(_switch(tester).value, isTrue);
        expect(find.text(_negativeFormat), findsOneWidget);
        expect(find.text('-0 0:00:05'), findsOneWidget);
      });

      testWidgets('readouts stay non-negative while negative', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.days, 1);
        await _setUnit(tester, _Slider.hours, 2);
        await _setUnit(tester, _Slider.minutes, 3);
        await _setUnit(tester, _Slider.seconds, 4);
        await _toggleSign(tester);

        expect(find.text('Days: 1'), findsOneWidget);
        expect(find.text('Hours: 2'), findsOneWidget);
        expect(find.text('Minutes: 3'), findsOneWidget);
        expect(find.text('Seconds: 4'), findsOneWidget);
        expect(find.text('-1 2:03:04'), findsOneWidget);
      });

      testWidgets('units changed while negative stay negative', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.seconds, 5);
        await _toggleSign(tester);
        await _setUnit(tester, _Slider.days, 1);

        expect(find.text('Days: 1'), findsOneWidget);
        expect(find.text('-1 0:00:05'), findsOneWidget);
      });

      testWidgets('turning off restores the positive duration', (tester) async {
        await _pump(tester);
        await _setUnit(tester, _Slider.seconds, 5);
        await _toggleSign(tester);
        await _toggleSign(tester);

        expect(_switch(tester).value, isFalse);
        expect(find.text(_zeroFormat), findsOneWidget);
        expect(find.text('0 0:00:05'), findsOneWidget);
      });

      testWidgets('toggling at zero flips the switch but not the output', (
        tester,
      ) async {
        await _pump(tester);
        await _toggleSign(tester);

        expect(_switch(tester).value, isTrue);
        expect(find.text(_zeroFormat), findsOneWidget);
        expect(find.text('0 0:00:00'), findsOneWidget);
      });

      testWidgets('sign set before any unit applies to later units', (
        tester,
      ) async {
        await _pump(tester);
        await _toggleSign(tester);
        await _setUnit(tester, _Slider.minutes, 9);

        expect(find.text('-0 0:09:00'), findsOneWidget);
      });
    });
  });
}

// packages/custom_widgets/test/src/default_welcome_screen/default_welcome_screen_test.dart

import 'package:analog_clock_widget/analog_clock_widget.dart' show AnalogClock;
import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:three_d_sphere/three_d_sphere.dart' show ThreeDSphere;

void main() {
  const spacing = 16.0;
  const welcomeFontSize = 24.0;
  const backgroundColor = Colors.deepPurple;
  const textColor = Colors.white;

  Widget wrap(Widget child) {
    return MaterialApp(home: child);
  }

  group('DefaultWelcomeScreen', () {
    testWidgets('constructs at runtime (non-const, so the constructor line is '
        'executed rather than canonicalized at compile time)', (tester) async {
      // UniqueKey() cannot be const, forcing a runtime constructor call.
      await tester.pumpWidget(wrap(DefaultWelcomeScreen(key: UniqueKey())));
      await tester.pump();

      expect(find.byType(DefaultWelcomeScreen), findsOneWidget);
    });

    testWidgets('paints the deep purple background', (tester) async {
      await tester.pumpWidget(wrap(DefaultWelcomeScreen(key: UniqueKey())));
      await tester.pump();

      final box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(DefaultWelcomeScreen),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, backgroundColor);
    });

    testWidgets('centers a min-sized row of clock, text, and sphere', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(DefaultWelcomeScreen(key: UniqueKey())));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(DefaultWelcomeScreen),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );

      final row = tester.widget<Row>(
        find.descendant(
          of: find.byType(DefaultWelcomeScreen),
          matching: find.byType(Row),
        ),
      );
      expect(row.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('renders the analog clock at radius 75 with themed hands', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(DefaultWelcomeScreen(key: UniqueKey())));
      await tester.pump();

      final clock = tester.widget<AnalogClock>(find.byType(AnalogClock));
      expect(clock.radius, 75);
      expect(clock.style.hourHandColor, backgroundColor);
      expect(clock.style.minuteHandColor, backgroundColor);
    });

    testWidgets('renders the Welcome label in white at font size 24', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(DefaultWelcomeScreen(key: UniqueKey())));
      await tester.pump();

      final text = tester.widget<Text>(find.text('Welcome'));
      expect(text.style?.color, textColor);
      expect(text.style?.fontSize, welcomeFontSize);
    });

    testWidgets('separates the row children with 16dp gaps', (tester) async {
      await tester.pumpWidget(wrap(DefaultWelcomeScreen(key: UniqueKey())));
      await tester.pump();

      final gaps = tester
          .widgetList<Gap>(find.byType(Gap))
          .toList(growable: false);
      expect(gaps, hasLength(2));
      for (final gap in gaps) {
        expect(gap.mainAxisExtent, spacing);
      }
    });

    testWidgets('renders the 24x24 amber sphere', (tester) async {
      await tester.pumpWidget(wrap(DefaultWelcomeScreen(key: UniqueKey())));
      await tester.pump();

      final sphere = tester.widget<ThreeDSphere>(find.byType(ThreeDSphere));
      expect(sphere.width, 24);
      expect(sphere.height, 24);
      expect(sphere.color, Colors.amber[900]);
    });
  });
}

// packages/custom_widgets/test/src/ice_chip/ice_chip_test.dart
import 'package:custom_widgets/src/ice_chip/ice_chip.dart';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in a [MaterialApp] with the requested [brightness] so the
/// chip's theme-aware border resolution can be exercised in both modes.
Widget _harness({
  required Widget child,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

/// Extracts the single [FilterChip] rendered by the harnessed [IceChip].
FilterChip _chipOf(WidgetTester tester) {
  return tester.widget<FilterChip>(find.byType(FilterChip));
}

void main() {
  group('IceChip', () {
    group('default constructor', () {
      testWidgets('renders the supplied child as the chip label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            child: IceChip(
              const Icon(Icons.ac_unit),
              backgroundColor: Colors.lightBlue,
              showBorder: true,
              onPress: () {},
            ),
          ),
        );

        expect(find.byIcon(Icons.ac_unit), findsOneWidget);
        expect(find.byType(Text), findsNothing);
      });

      testWidgets('pins FilterChip to a single non-selected visual state', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            child: IceChip(
              const SizedBox.shrink(),
              backgroundColor: Colors.teal,
              showBorder: true,
              onPress: () {},
            ),
          ),
        );

        final chip = _chipOf(tester);
        expect(chip.selected, isFalse);
        expect(chip.showCheckmark, isFalse);
        expect(chip.shape, isA<StadiumBorder>());
        expect(chip.backgroundColor, Colors.teal);
        expect(chip.selectedColor, Colors.teal);
      });
    });

    group('IceChip.text', () {
      testWidgets('renders the label upper-cased', (WidgetTester tester) async {
        await tester.pumpWidget(
          _harness(
            child: IceChip.text(
              'vanilla',
              backgroundColor: Colors.lightBlue,
              showBorder: true,
              onPress: () {},
            ),
          ),
        );

        expect(find.text('VANILLA'), findsOneWidget);
        expect(find.text('vanilla'), findsNothing);
      });

      testWidgets('colors the label with the contrasting color of a light '
          'background', (WidgetTester tester) async {
        const background = Colors.white;

        await tester.pumpWidget(
          _harness(
            child: IceChip.text(
              'mint',
              backgroundColor: background,
              showBorder: true,
              onPress: () {},
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('MINT'));
        expect(text.style?.color, background.contrastingColor());
      });

      testWidgets('colors the label with the contrasting color of a dark '
          'background', (WidgetTester tester) async {
        const background = Colors.black;

        await tester.pumpWidget(
          _harness(
            child: IceChip.text(
              'mint',
              backgroundColor: background,
              showBorder: true,
              onPress: () {},
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('MINT'));
        expect(text.style?.color, background.contrastingColor());
      });

      testWidgets('label color tracks the background, not the theme', (
        WidgetTester tester,
      ) async {
        const background = Colors.white;

        await tester.pumpWidget(
          _harness(
            brightness: Brightness.dark,
            child: IceChip.text(
              'mint',
              backgroundColor: background,
              showBorder: true,
              onPress: () {},
            ),
          ),
        );

        // Dark theme, but a light background: the label must contrast with
        // the background it sits on, independent of theme brightness.
        final text = tester.widget<Text>(find.text('MINT'));
        expect(text.style?.color, background.contrastingColor());
      });
    });

    group('border', () {
      testWidgets('draws a black 3px side in light mode when showBorder is '
          'true', (WidgetTester tester) async {
        await tester.pumpWidget(
          _harness(
            child: IceChip.text(
              'berry',
              backgroundColor: Colors.pink,
              showBorder: true,
              onPress: () {},
            ),
          ),
        );

        final side = _chipOf(tester).side;
        expect(side?.color, Colors.black);
        expect(side?.width, 3);
      });

      testWidgets('draws a white 3px side in dark mode when showBorder is '
          'true', (WidgetTester tester) async {
        await tester.pumpWidget(
          _harness(
            brightness: Brightness.dark,
            child: IceChip.text(
              'berry',
              backgroundColor: Colors.pink,
              showBorder: true,
              onPress: () {},
            ),
          ),
        );

        expect(_chipOf(tester).side?.color, Colors.white);
      });

      testWidgets('paints a transparent side of identical width when '
          'showBorder is false, preserving layout', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            child: IceChip.text(
              'berry',
              backgroundColor: Colors.pink,
              showBorder: false,
              onPress: () {},
            ),
          ),
        );

        final side = _chipOf(tester).side;
        expect(side?.color, Colors.transparent);
        expect(side?.width, 3);
      });
    });

    group('interaction', () {
      testWidgets('fires onPress exactly once per tap', (
        WidgetTester tester,
      ) async {
        var pressCount = 0;

        await tester.pumpWidget(
          _harness(
            child: IceChip.text(
              'tap me',
              backgroundColor: Colors.amber,
              showBorder: true,
              onPress: () => pressCount++,
            ),
          ),
        );

        await tester.tap(find.byType(FilterChip));
        await tester.pump();
        expect(pressCount, 1);

        await tester.tap(find.byType(FilterChip));
        await tester.pump();
        expect(pressCount, 2);
      });
    });
  });
}

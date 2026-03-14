// test/tag_chip_test.dart

// ignore_for_file: avoid_redundant_argument_values, lines_longer_than_80_chars, document_ignores, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag_chip/tag_chip.dart';

void main() {
  Widget buildSubject({
    Color backgroundColor = Colors.white,
    String text = 'Test',
    TagChipState state = TagChipState.none,
    CallbackState onPressed,
    double minimumWidth = 32,
    double fontSize = 16,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(
        body: TagChip(
          backgroundColor: backgroundColor,
          text: text,
          state: state,
          onPressed: onPressed,
          minimumWidth: minimumWidth,
          fontSize: fontSize,
        ),
      ),
    );
  }

  StadiumBorder _chipShape(WidgetTester tester) {
    final chip = tester.widget<ActionChip>(find.byType(ActionChip));
    return chip.shape! as StadiumBorder;
  }

  group('TagChip', () {
    group('text color — background luminance', () {
      testWidgets('black text on light background', (tester) async {
        await tester.pumpWidget(buildSubject(backgroundColor: Colors.white));

        final text = tester.widget<Text>(find.text('Test'));
        expect(text.style?.color, Colors.black);
      });

      testWidgets('white text on dark background', (tester) async {
        await tester.pumpWidget(buildSubject(backgroundColor: Colors.black));

        final text = tester.widget<Text>(find.text('Test'));
        expect(text.style?.color, Colors.white);
      });
    });

    group('border — TagChipState.none', () {
      testWidgets('transparent border in light theme', (tester) async {
        await tester.pumpWidget(buildSubject(state: TagChipState.none));

        final side = _chipShape(tester).side;
        expect(side.color, Colors.transparent);
        expect(side.width, 2);
      });

      testWidgets('transparent border in dark theme', (tester) async {
        await tester.pumpWidget(
          buildSubject(state: TagChipState.none, theme: ThemeData.dark()),
        );

        final side = _chipShape(tester).side;
        expect(side.color, Colors.transparent);
        expect(side.width, 2);
      });
    });

    group('border — TagChipState.disabled', () {
      testWidgets('transparent border in light theme', (tester) async {
        await tester.pumpWidget(buildSubject(state: TagChipState.disabled));

        final side = _chipShape(tester).side;
        expect(side.color, Colors.transparent);
        expect(side.width, 2);
      });

      testWidgets('transparent border in dark theme', (tester) async {
        await tester.pumpWidget(
          buildSubject(state: TagChipState.disabled, theme: ThemeData.dark()),
        );

        final side = _chipShape(tester).side;
        expect(side.color, Colors.transparent);
        expect(side.width, 2);
      });
    });

    group('border — TagChipState.enabled', () {
      testWidgets('black 2px border in light theme', (tester) async {
        await tester.pumpWidget(buildSubject(state: TagChipState.enabled));

        final side = _chipShape(tester).side;
        expect(side.width, 2);
        expect(side.color, Colors.black);
      });

      testWidgets('white 2px border in dark theme', (tester) async {
        await tester.pumpWidget(
          buildSubject(state: TagChipState.enabled, theme: ThemeData.dark()),
        );

        final side = _chipShape(tester).side;
        expect(side.width, 2);
        expect(side.color, Colors.white);
      });
    });

    group('onPressed', () {
      testWidgets('does not throw when null and chip is tapped', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.byType(ActionChip));
        await tester.pump();
      });

      testWidgets('receives TagChipState.none', (tester) async {
        TagChipState? received;
        await tester.pumpWidget(
          buildSubject(onPressed: (s) => received = s),
        );

        await tester.tap(find.byType(ActionChip));
        await tester.pump();

        expect(received, TagChipState.none);
      });

      testWidgets('receives TagChipState.disabled', (tester) async {
        TagChipState? received;
        await tester.pumpWidget(
          buildSubject(
            state: TagChipState.disabled,
            onPressed: (s) => received = s,
          ),
        );

        await tester.tap(find.byType(ActionChip));
        await tester.pump();

        expect(received, TagChipState.disabled);
      });

      testWidgets('receives TagChipState.enabled', (tester) async {
        TagChipState? received;
        await tester.pumpWidget(
          buildSubject(
            state: TagChipState.enabled,
            onPressed: (s) => received = s,
          ),
        );

        await tester.tap(find.byType(ActionChip));
        await tester.pump();

        expect(received, TagChipState.enabled);
      });
    });

    group('construction', () {
      testWidgets('renders correct text', (tester) async {
        await tester.pumpWidget(buildSubject(text: 'Hello'));

        expect(find.text('Hello'), findsOneWidget);
      });

      testWidgets('applies backgroundColor to chip', (tester) async {
        await tester.pumpWidget(buildSubject(backgroundColor: Colors.red));

        final chip = tester.widget<ActionChip>(find.byType(ActionChip));
        expect(chip.backgroundColor, Colors.red);
      });

      testWidgets('applies custom fontSize', (tester) async {
        await tester.pumpWidget(buildSubject(fontSize: 20));

        final text = tester.widget<Text>(find.text('Test'));
        expect(text.style?.fontSize, 20);
      });

      testWidgets('applies minimumWidth constraint', (tester) async {
        await tester.pumpWidget(buildSubject(minimumWidth: 100));

        final box = tester.firstWidget<ConstrainedBox>(
          find.descendant(
            of: find.byType(TagChip),
            matching: find.byType(ConstrainedBox),
          ),
        );
        expect(box.constraints.minWidth, 100);
      });
    });
  });
}

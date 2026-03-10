// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag_chip/tag_chip.dart'; // adjust import to your package name

void main() {
  Widget buildSubject({
    Color backgroundColor = Colors.white,
    String text = 'Test',
    TagChipState state = TagChipState.none,
    CallbackState onPressed,
    double minimumWidth = 32,
    double fontSize = 16,
  }) {
    return MaterialApp(
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

  group('TagChip', () {
    group('border color', () {
      testWidgets('uses black border when background is light', (tester) async {
        await tester.pumpWidget(buildSubject());

        final text = tester.widget<Text>(find.text('Test'));
        expect(text.style?.color, Colors.black);
      });

      testWidgets('uses white border when background is dark', (tester) async {
        await tester.pumpWidget(buildSubject(backgroundColor: Colors.black));

        final text = tester.widget<Text>(find.text('Test'));
        expect(text.style?.color, Colors.white);
      });
    });

    group('state', () {
      testWidgets('renders with TagChipState.none — no border', (tester) async {
        await tester.pumpWidget(buildSubject());

        final chip = tester.widget<ActionChip>(find.byType(ActionChip));
        final shape = chip.shape! as StadiumBorder;
        expect(shape.side, BorderSide.none);
      });

      testWidgets('renders with TagChipState.disabled — no border', (tester) async {
        await tester.pumpWidget(buildSubject(state: TagChipState.disabled));

        final chip = tester.widget<ActionChip>(find.byType(ActionChip));
        final shape = chip.shape! as StadiumBorder;
        expect(shape.side, BorderSide.none);
      });

      testWidgets('renders with TagChipState.enabled — shows border', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: TagChipState.enabled,
        ));

        final chip = tester.widget<ActionChip>(find.byType(ActionChip));
        final shape = chip.shape! as StadiumBorder;
        expect(shape.side.width, 2);
        expect(shape.side.color, Colors.black);
      });
    });

    group('constraints', () {
      testWidgets('respects minimumWidth', (tester) async {
        await tester.pumpWidget(buildSubject(minimumWidth: 100));

        // Find the outermost ConstrainedBox inside TagChip (the one it owns)
        final box = tester.firstWidget<ConstrainedBox>(
          find.descendant(
            of: find.byType(TagChip),
            matching: find.byType(ConstrainedBox),
          ),
        );
        expect(box.constraints.minWidth, 100);
      });

      testWidgets('uses custom fontSize', (tester) async {
        await tester.pumpWidget(buildSubject(fontSize: 20));

        final text = tester.widget<Text>(find.text('Test'));
        expect(text.style?.fontSize, 20);
      });
    });

    group('onPressed', () {
      testWidgets('calls onPressed with current state when tapped', (tester) async {
        TagChipState? received;
        await tester.pumpWidget(buildSubject(
          state: TagChipState.enabled,
          onPressed: (state) => received = state,
        ));

        await tester.tap(find.byType(ActionChip));
        await tester.pump();

        expect(received, TagChipState.enabled);
      });

      testWidgets('does not throw when onPressed is null and chip is tapped', (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.byType(ActionChip));
        await tester.pump();
        // no exception
      });

      testWidgets('calls onPressed with disabled state', (tester) async {
        TagChipState? received;
        await tester.pumpWidget(buildSubject(
          state: TagChipState.disabled,
          onPressed: (state) => received = state,
        ));

        await tester.tap(find.byType(ActionChip));
        await tester.pump();

        expect(received, TagChipState.disabled);
      });

      testWidgets('calls onPressed with none state', (tester) async {
        TagChipState? received;
        await tester.pumpWidget(buildSubject(
          onPressed: (state) => received = state,
        ));

        await tester.tap(find.byType(ActionChip));
        await tester.pump();

        expect(received, TagChipState.none);
      });
    });

    testWidgets('renders correct text', (tester) async {
      await tester.pumpWidget(buildSubject(text: 'Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('uses backgroundColor on chip', (tester) async {
      await tester.pumpWidget(buildSubject(backgroundColor: Colors.red));

      final chip = tester.widget<ActionChip>(find.byType(ActionChip));
      expect(chip.backgroundColor, Colors.red);
    });
  });
}

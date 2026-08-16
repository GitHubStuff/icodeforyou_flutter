// packages/custom_widgets/test/src/uninherited_text/uninherited_text_test.dart
//
// Constructed WITHOUT `const` so the constructor line executes at
// runtime and registers in LCOV; const invocations are canonicalized
// at compile time and never hit it.
// ignore_for_file: prefer_const_constructors

import 'package:custom_widgets/src/uninherited_text/uninherited_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UninheritedText', () {
    test('constructor applies documented defaults', () {
      final widget = UninheritedText('boom');

      expect(widget.text, 'boom');
      expect(widget.backgroundColor, Colors.black);
      expect(widget.style.color, Colors.redAccent);
      expect(widget.style.fontSize, 32);
      expect(widget.style.decoration, TextDecoration.none);
      expect(widget.style.fontWeight, FontWeight.w700);
    });

    testWidgets('renders standalone with no MaterialApp above it', (
      tester,
    ) async {
      await tester.pumpWidget(UninheritedText('startup failed'));

      expect(find.text('startup failed'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final directionality = tester.widget<Directionality>(
        find.byType(Directionality).first,
      );
      expect(directionality.textDirection, TextDirection.ltr);
    });

    testWidgets('honors a custom background color and style', (tester) async {
      const customStyle = TextStyle(
        color: Colors.white,
        fontSize: 16,
        decoration: TextDecoration.none,
      );

      await tester.pumpWidget(
        UninheritedText(
          'custom',
          backgroundColor: Colors.indigo,
          style: customStyle,
        ),
      );

      final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(coloredBox.color, Colors.indigo);

      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text('custom'),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      );
      expect(defaultTextStyle.style, customStyle);
    });
  });
}

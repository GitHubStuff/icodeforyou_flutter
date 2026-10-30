// packages/ext_string/test/src/ext_string_test.dart

import 'package:ext_string/src/ext_string.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test suite verifying the layout measurement, date parsing, and glyph
/// rendering extensions declared on [String] via [ExtString].
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExtString.pixelSize', () {
    const style = TextStyle(fontSize: 16);

    test('measures non-empty string with default parameters', () {
      final size = 'Hello World'.pixelSize(style: style);

      expect(size.width, greaterThan(0.0));
      expect(size.height, greaterThan(0.0));
    });

    test('measures empty string with zero width and positive height', () {
      final size = ''.pixelSize(style: style);

      expect(size.width, 0.0);
      expect(size.height, greaterThan(0.0));
    });

    test('respects custom textDirection, textAlign, and textScaler', () {
      final unscaledSize = 'Testing'.pixelSize(
        style: style,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        textScaler: TextScaler.noScaling,
      );

      final scaledSize = 'Testing'.pixelSize(
        style: style,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        textScaler: const TextScaler.linear(2),
      );

      expect(scaledSize.width, greaterThan(unscaledSize.width));
      expect(scaledSize.height, greaterThan(unscaledSize.height));
    });

    test('respects maxWidth and maxLines constraints', () {
      const longText = 'A long line of sample text intended to wrap on width.';

      final singleLineSize = longText.pixelSize(
        style: style,
        maxWidth: double.infinity,
      );

      final wrappedTwoLines = longText.pixelSize(
        style: style,
        maxWidth: 100,
        maxLines: 2,
      );

      expect(wrappedTwoLines.width, lessThanOrEqualTo(100.0));
      expect(wrappedTwoLines.height, greaterThan(singleLineSize.height));
    });
  });

  group('ExtString.toMicrosecondsOrNull', () {
    test('parses standard ISO 8601 UTC date-time string', () {
      final micros = '2024-01-01T00:00:00Z'.toMicrosecondsOrNull();

      expect(micros, 1704067200000000);
    });

    test('parses pre-epoch UTC date-time string to negative microseconds', () {
      final micros = '1969-12-31T23:59:59Z'.toMicrosecondsOrNull();

      expect(micros, -1000000);
    });

    test('parses local date string without time component', () {
      final micros = '2024-01-01'.toMicrosecondsOrNull();

      expect(micros, isNotNull);
      expect(
        micros,
        DateTime.parse('2024-01-01').microsecondsSinceEpoch,
      );
    });

    test('returns null for unparseable strings', () {
      expect('not a date'.toMicrosecondsOrNull(), isNull);
      expect(''.toMicrosecondsOrNull(), isNull);
      expect('  2024-01-01  '.toMicrosecondsOrNull(), isNull);
    });
  });

  group('ExtString.asGlyph', () {
    testWidgets('constructs a FittedBox containing a centered Text widget', (
      tester,
    ) async {
      const glyph = '★';
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: glyph.asGlyph(),
        ),
      );

      final fittedBoxFinder = find.byType(FittedBox);
      expect(fittedBoxFinder, findsOneWidget);

      final fittedBox = tester.widget<FittedBox>(fittedBoxFinder);
      expect(fittedBox.fit, BoxFit.contain);

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.data, glyph);
      expect(textWidget.textAlign, TextAlign.center);
      expect(textWidget.style?.height, 1.0);
    });
  });
}

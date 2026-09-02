// packages/extensions/test/string/string_ext_test.dart

import 'package:extensions/string/string_ext.dart' show StringExt;
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StringExt.renderSize', () {
    test('measures a non-empty string with defaults', () {
      final (:width, :height) = 'Hello'.renderSize();
      expect(width, greaterThan(0));
      expect(height, greaterThan(0));
    });

    test('a longer string is wider than a shorter one', () {
      final short = 'Hi'.renderSize();
      final long = 'Hi there, world'.renderSize();
      expect(long.width, greaterThan(short.width));
    });

    test('a larger font size produces a larger measurement', () {
      final small = 'Hello'.renderSize(fontSize: 12);
      final big = 'Hello'.renderSize(fontSize: 24);
      expect(big.width, greaterThan(small.width));
      expect(big.height, greaterThan(small.height));
    });

    test('maxLines allows wrapping to grow the height', () {
      const text = 'A reasonably long line of text that will wrap around';
      final oneLine = text.renderSize();
      final twoLines = text.renderSize(maxLines: 2);
      expect(twoLines.height, greaterThanOrEqualTo(oneLine.height));
    });

    test('honors fontWeight and textDirection parameters', () {
      final (:width, :height) = 'שלום'.renderSize(
        fontWeight: FontWeight.bold,
        textDirection: TextDirection.rtl,
      );
      expect(width, greaterThan(0));
      expect(height, greaterThan(0));
    });
  });

  group('StringExt.toMicrosecondsOrNull', () {
    test('parses a UTC ISO 8601 date to epoch microseconds', () {
      expect('2024-01-01T00:00:00Z'.toMicrosecondsOrNull(), 1704067200000000);
    });

    test('parses a local ISO 8601 date consistently with DateTime.parse', () {
      expect(
        '2024-01-01'.toMicrosecondsOrNull(),
        DateTime.parse('2024-01-01').microsecondsSinceEpoch,
      );
    });

    test('returns null for an invalid date string', () {
      expect('not a date'.toMicrosecondsOrNull(), isNull);
    });
  });
}

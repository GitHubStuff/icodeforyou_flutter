// packages/ext_string/test/src/ext_string_test.dart

import 'package:ext_string/ext_string.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExtString', () {
    group('pixelSize', () {
      const style = TextStyle(fontSize: 16);
      const text = 'The quick brown fox jumps over the lazy dog';

      test('returns a non-zero size for non-empty text', () {
        final size = text.pixelSize(style: style);

        expect(size.width, greaterThan(0));
        expect(size.height, greaterThan(0));
      });

      test('returns zero width and one line of height for empty text', () {
        final empty = ''.pixelSize(style: style);
        final single = 'x'.pixelSize(style: style);

        expect(empty.width, 0);
        expect(empty.height, single.height);
      });

      test('lays out on a single line when maxWidth is unconstrained', () {
        final single = 'x'.pixelSize(style: style);
        final long = text.pixelSize(style: style);

        expect(long.height, single.height);
      });

      test('wraps and grows in height when maxWidth is constrained', () {
        final unconstrained = text.pixelSize(style: style);
        final constrained = text.pixelSize(style: style, maxWidth: 100);

        expect(constrained.width, lessThanOrEqualTo(100));
        expect(constrained.height, greaterThan(unconstrained.height));
      });

      test('caps height when maxLines is set', () {
        final unlimited = text.pixelSize(style: style, maxWidth: 100);
        final capped = text.pixelSize(
          style: style,
          maxWidth: 100,
          maxLines: 1,
        );

        expect(capped.height, lessThan(unlimited.height));
      });

      test('grows when a non-identity textScaler is supplied', () {
        final unscaled = text.pixelSize(style: style);
        final scaled = text.pixelSize(
          style: style,
          textScaler: const TextScaler.linear(2),
        );

        expect(scaled.width, greaterThan(unscaled.width));
        expect(scaled.height, greaterThan(unscaled.height));
      });

      test('respects textDirection and textAlign without changing size', () {
        final ltr = text.pixelSize(style: style);
        final rtl = text.pixelSize(
          style: style,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.end,
        );

        expect(rtl, ltr);
      });

      test('scales with fontSize', () {
        final small = text.pixelSize(style: const TextStyle(fontSize: 10));
        final large = text.pixelSize(style: const TextStyle(fontSize: 20));

        expect(large.width, greaterThan(small.width));
        expect(large.height, greaterThan(small.height));
      });
    });

    group('toMicrosecondsOrNull', () {
      test('parses a UTC ISO 8601 date-time', () {
        expect(
          '2024-01-01T00:00:00Z'.toMicrosecondsOrNull(),
          1704067200000000,
        );
      });

      test('parses a date-time before the epoch to a negative value', () {
        expect('1969-12-31T23:59:59Z'.toMicrosecondsOrNull(), -1000000);
      });

      test('parses a date-only string as local midnight', () {
        expect(
          '2024-01-01'.toMicrosecondsOrNull(),
          DateTime(2024).microsecondsSinceEpoch,
        );
      });

      test('parses an explicit UTC offset', () {
        expect(
          '2024-01-01T02:00:00+02:00'.toMicrosecondsOrNull(),
          1704067200000000,
        );
      });

      test('parses fractional seconds', () {
        expect(
          '2024-01-01T00:00:00.123456Z'.toMicrosecondsOrNull(),
          1704067200123456,
        );
      });

      test('returns null for an invalid string', () {
        expect('not a date'.toMicrosecondsOrNull(), isNull);
      });

      test('returns null for an empty string', () {
        expect(''.toMicrosecondsOrNull(), isNull);
      });

      test('returns null for padded input', () {
        expect(' 2024-01-01 '.toMicrosecondsOrNull(), isNull);
      });
    });
  });
}

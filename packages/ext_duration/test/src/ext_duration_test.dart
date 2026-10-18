// packages/ext_duration/test/src/ext_duration_test.dart

import 'package:ext_duration/ext_duration.dart' show ExtDuration;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExtDuration', () {
    group('format', () {
      const sample = Duration(
        hours: 26,
        minutes: 5,
        seconds: 9,
        milliseconds: 42,
      );

      test('formats a clock-style pattern', () {
        expect(sample.format('%02H:%02m:%02s'), '26:05:09');
      });

      test('formats a pattern with days and hours of day', () {
        expect(sample.format('%d day(s) %02h:%02m'), '1 day(s) 02:05');
      });

      test('formats fractional seconds', () {
        expect(sample.format('%S.%03l s'), '93909.042 s');
      });

      test('emits the sign via %n for negative durations', () {
        expect(sample.format('%n%M min'), '1565 min');
        expect((-sample).format('%n%M min'), '-1565 min');
      });

      test('escapes a literal percent', () {
        expect(sample.format('100%%'), '100%');
      });

      test('returns the pattern verbatim when it has no conversions', () {
        expect(sample.format('no fields here'), 'no fields here');
      });

      test('returns an empty string for an empty pattern', () {
        expect(sample.format(''), '');
      });

      test('formats Duration.zero', () {
        expect(Duration.zero.format('%02H:%02m:%02s'), '00:00:00');
      });

      test('throws FormatException for an unknown conversion', () {
        expect(() => sample.format('%x'), throwsFormatException);
      });

      test('throws FormatException for an incomplete conversion', () {
        expect(() => sample.format('%'), throwsFormatException);
      });

      test('is callable on a const Duration', () {
        expect(const Duration(minutes: 90).format('%H:%02m'), '1:30');
      });
    });
  });
}

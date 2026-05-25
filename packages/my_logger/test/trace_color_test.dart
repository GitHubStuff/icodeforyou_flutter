// package/test/src/utils/trace_color_test.dart
// ignore_for_file: avoid_redundant_argument_values
import 'package:flutter_test/flutter_test.dart';
import 'package:my_logger/src/trace_color.dart' show TraceColor;

void main() {
  group('TraceColor', () {
    test('exposes the expected ANSI codes', () {
      expect(TraceColor.blue.code, '\x1B[34m');
      expect(TraceColor.brightCyan.code, '\x1B[96m');
      expect(TraceColor.brightRed.code, '\x1B[91m');
      expect(TraceColor.cyan.code, '\x1B[36m');
      expect(TraceColor.green.code, '\x1B[32m');
      expect(TraceColor.grey.code, '\x1B[90m');
      expect(TraceColor.magenta.code, '\x1B[35m');
      expect(TraceColor.red.code, '\x1B[31m');
      expect(TraceColor.yellow.code, '\x1B[33m');
    });

    test('exposes the ANSI reset sequence', () {
      expect(TraceColor.reset, '\x1B[0m');
    });

    group('apply', () {
      test('wraps text in color and reset when ANSI is supported', () {
        final result = TraceColor.red.apply(
          'error',
          supportsAnsi: () => true,
        );
        expect(result, '\x1B[31merror\x1B[0m');
      });

      test('returns text unchanged when ANSI is not supported', () {
        final result = TraceColor.red.apply(
          'error',
          supportsAnsi: () => false,
        );
        expect(result, 'error');
      });

      test('handles empty strings without producing stray escapes', () {
        expect(
          TraceColor.cyan.apply('', supportsAnsi: () => true),
          '\x1B[36m\x1B[0m',
        );
        expect(
          TraceColor.cyan.apply('', supportsAnsi: () => false),
          '',
        );
      });

      test('handles multi-line input as a single wrapped block', () {
        const input = 'line one\nline two\nline three';
        final result = TraceColor.green.apply(
          input,
          supportsAnsi: () => true,
        );
        expect(result, '\x1B[32m$input\x1B[0m');
      });

      test('falls through to the default predicate when none is passed', () {
        // We can't deterministically know whether the test runner is a TTY,
        // but we can assert the call doesn't throw and returns a string that
        // either equals the input or wraps it in this color's codes.
        final result = TraceColor.yellow.apply('text');
        const wrapped = '\x1B[33mtext\x1B[0m';
        expect(result == 'text' || result == wrapped, isTrue);
      });
    });
  });
}

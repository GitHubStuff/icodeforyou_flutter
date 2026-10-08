// packages/extensions/test/duration/duration_fmt_test.dart

import 'package:extensions/duration/duration_fmt.dart' show DurationFormatting;
import 'package:test/test.dart';

void main() {
  group('DurationFormatting', () {
    group('toFormattedString', () {
      group('when the duration contains days', () {
        test('renders as D HH:MM:SS', () {
          const Duration duration = Duration(
            days: 2,
            hours: 3,
            minutes: 4,
            seconds: 5,
          );

          expect(duration.toFormattedString(), '2 03:04:05');
        });

        test('zero-pads hours, minutes and seconds', () {
          const Duration duration = Duration(days: 1);

          expect(duration.toFormattedString(), '1 00:00:00');
        });

        test('groups day counts of four digits with a thousands separator', () {
          const Duration duration = Duration(days: 1200, hours: 1);

          expect(duration.toFormattedString(), '1,200 01:00:00');
        });

        test('groups day counts of seven digits with multiple separators', () {
          const Duration duration = Duration(days: 1200000);

          expect(duration.toFormattedString(), '1,200,000 00:00:00');
        });

        test('does not insert a separator for exactly three digits', () {
          const Duration duration = Duration(days: 999);

          expect(duration.toFormattedString(), '999 00:00:00');
        });

        test('reduces hours modulo 24 rather than showing the total', () {
          const Duration duration = Duration(hours: 25);

          expect(duration.toFormattedString(), '1 01:00:00');
        });
      });

      group('when the duration contains hours but no days', () {
        test('renders as HH:MM:SS', () {
          const Duration duration = Duration(hours: 4, minutes: 5, seconds: 6);

          expect(duration.toFormattedString(), '04:05:06');
        });

        test('zero-pads minutes and seconds', () {
          const Duration duration = Duration(hours: 1, seconds: 9);

          expect(duration.toFormattedString(), '01:00:09');
        });

        test('renders 23 hours without rolling into days', () {
          const Duration duration = Duration(
            hours: 23,
            minutes: 59,
            seconds: 59,
          );

          expect(duration.toFormattedString(), '23:59:59');
        });

        test('reduces minutes modulo 60 rather than showing the total', () {
          const Duration duration = Duration(minutes: 61);

          expect(duration.toFormattedString(), '01:01:00');
        });
      });

      group('when the duration contains minutes but no hours', () {
        test('renders as MM:SS', () {
          const Duration duration = Duration(minutes: 7, seconds: 30);

          expect(duration.toFormattedString(), '07:30');
        });

        test('zero-pads seconds', () {
          const Duration duration = Duration(minutes: 1);

          expect(duration.toFormattedString(), '01:00');
        });

        test('renders 59 minutes without rolling into hours', () {
          const Duration duration = Duration(minutes: 59, seconds: 59);

          expect(duration.toFormattedString(), '59:59');
        });

        test('reduces seconds modulo 60 rather than showing the total', () {
          const Duration duration = Duration(seconds: 61);

          expect(duration.toFormattedString(), '01:01');
        });
      });

      group('when the duration contains only seconds', () {
        test('renders the bare second count without padding', () {
          const Duration duration = Duration(seconds: 6);

          expect(duration.toFormattedString(), '6');
        });

        test('renders 59 seconds without rolling into minutes', () {
          const Duration duration = Duration(seconds: 59);

          expect(duration.toFormattedString(), '59');
        });

        test('renders Duration.zero as 0', () {
          expect(Duration.zero.toFormattedString(), '0');
        });
      });

      group('sub-second precision', () {
        test('truncates milliseconds rather than rounding', () {
          const Duration duration = Duration(seconds: 42, milliseconds: 999);

          expect(duration.toFormattedString(), '42');
        });

        test('truncates microseconds rather than rounding', () {
          const Duration duration = Duration(minutes: 1, microseconds: 999999);

          expect(duration.toFormattedString(), '01:00');
        });

        test('renders a sub-second duration as 0', () {
          const Duration duration = Duration(milliseconds: 500);

          expect(duration.toFormattedString(), '0');
        });
      });
    });
  });
}

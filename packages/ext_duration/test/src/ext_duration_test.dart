// packages/ext_duration/test/src/ext_duration_test.dart

import 'package:ext_duration/src/ext_duration.dart';
import 'package:test/test.dart';

void main() {
  group('ExtDuration', () {
    group('format', () {
      const duration = Duration(
        hours: 26,
        minutes: 5,
        seconds: 9,
        milliseconds: 42,
      );

      test('delegates to DurationFormatter', () {
        expect(duration.format('%02H:%02m:%02s'), '26:05:09');
      });

      test('supports literal text around conversions', () {
        expect(duration.format('%d day(s) %02h:%02m'), '1 day(s) 02:05');
      });

      test('propagates FormatException for invalid patterns', () {
        expect(() => duration.format('%x'), throwsFormatException);
      });

      test('zero formats as zero', () {
        expect(Duration.zero.format('%d %02h:%02m:%02s'), '0 00:00:00');
      });
    });

    group('composeFormat', () {
      test('seconds only', () {
        expect(
          const Duration(seconds: 9).composeFormat(
            showPlusSign: false,
            showLeaderZero: false,
            padHours: false,
          ),
          '%s',
        );
      });

      test('minutes and seconds', () {
        expect(
          const Duration(minutes: 5, seconds: 9).composeFormat(
            showPlusSign: false,
            showLeaderZero: false,
            padHours: false,
          ),
          '%m:%02s',
        );
      });

      test('hours with plus sign and padded hours', () {
        expect(
          const Duration(hours: 1, minutes: 5, seconds: 9).composeFormat(
            showPlusSign: true,
            showLeaderZero: false,
            padHours: true,
          ),
          '+%02h:%02m:%02s',
        );
      });

      test('days', () {
        expect(
          const Duration(days: 2).composeFormat(
            showPlusSign: false,
            showLeaderZero: false,
            padHours: false,
          ),
          '%d %h:%02m:%02s',
        );
      });

      test('negative with leader zero ignores plus sign', () {
        expect(
          const Duration(seconds: -9).composeFormat(
            showPlusSign: true,
            showLeaderZero: true,
            padHours: false,
          ),
          '%n%d %h:%02m:%02s',
        );
      });

      test('zero receives the plus sign', () {
        expect(
          Duration.zero.composeFormat(
            showPlusSign: true,
            showLeaderZero: false,
            padHours: false,
          ),
          '+%s',
        );
      });

      test('negative durations select the same unit as positive ones', () {
        const positive = Duration(hours: 3, minutes: 4, seconds: 5);
        const negative = Duration(hours: -3, minutes: -4, seconds: -5);

        final positiveTemplate = positive.composeFormat(
          showPlusSign: false,
          showLeaderZero: false,
          padHours: false,
        );
        final negativeTemplate = negative.composeFormat(
          showPlusSign: false,
          showLeaderZero: false,
          padHours: false,
        );

        expect(negativeTemplate, '%n$positiveTemplate');
      });

      group('round-trips through format', () {
        String render(
          Duration duration, {
          required bool showPlusSign,
          required bool showLeaderZero,
          required bool padHours,
        }) =>
            duration.format(
              duration.composeFormat(
                showPlusSign: showPlusSign,
                showLeaderZero: showLeaderZero,
                padHours: padHours,
              ),
            );

        test('five seconds with leader zero renders fixed width', () {
          expect(
            render(
              const Duration(seconds: 5),
              showPlusSign: false,
              showLeaderZero: true,
              padHours: false,
            ),
            '0 0:00:05',
          );
        });

        test('five seconds with leader zero and padded hours', () {
          expect(
            render(
              const Duration(seconds: 5),
              showPlusSign: false,
              showLeaderZero: true,
              padHours: true,
            ),
            '0 00:00:05',
          );
        });

        test('negative nine seconds with leader zero', () {
          expect(
            render(
              const Duration(seconds: -9),
              showPlusSign: true,
              showLeaderZero: true,
              padHours: false,
            ),
            '-0 0:00:09',
          );
        });

        test('days with unpadded hours', () {
          expect(
            render(
              const Duration(days: 2, hours: 3),
              showPlusSign: false,
              showLeaderZero: false,
              padHours: false,
            ),
            '2 3:00:00',
          );
        });

        test('days with padded hours', () {
          expect(
            render(
              const Duration(days: 2, hours: 3),
              showPlusSign: false,
              showLeaderZero: false,
              padHours: true,
            ),
            '2 03:00:00',
          );
        });

        test('minutes leading are unpadded', () {
          expect(
            render(
              const Duration(minutes: 5, seconds: 9),
              showPlusSign: false,
              showLeaderZero: false,
              padHours: false,
            ),
            '5:09',
          );
        });

        test('positive with plus sign', () {
          expect(
            render(
              const Duration(hours: 1, minutes: 5, seconds: 9),
              showPlusSign: true,
              showLeaderZero: false,
              padHours: true,
            ),
            '+01:05:09',
          );
        });
      });
    });

    group('toStopwatchDisplay', () {
      test('days, hours, minutes, seconds', () {
        expect(
          const Duration(
            days: 146,
            hours: 23,
            minutes: 17,
            seconds: 14,
          ).toStopwatchDisplay(),
          '146 23:17:14',
        );
      });

      test('pads hours, minutes and seconds but not days', () {
        expect(
          const Duration(hours: 7, minutes: 15, seconds: 4).toStopwatchDisplay(),
          '0 07:15:04',
        );
      });

      test('zero without plus sign', () {
        expect(Duration.zero.toStopwatchDisplay(), '0 00:00:00');
      });

      test('zero never gets a plus sign', () {
        expect(
          Duration.zero.toStopwatchDisplay(showPlusSign: true),
          '0 00:00:00',
        );
      });

      test('positive without plus sign', () {
        expect(const Duration(seconds: 5).toStopwatchDisplay(), '0 00:00:05');
      });

      test('positive with plus sign', () {
        expect(
          const Duration(seconds: 5).toStopwatchDisplay(showPlusSign: true),
          '+0 00:00:05',
        );
      });

      test('negative is prefixed with minus', () {
        expect(
          const Duration(hours: -1).toStopwatchDisplay(),
          '-0 01:00:00',
        );
      });

      test('negative ignores showPlusSign', () {
        expect(
          const Duration(hours: -1).toStopwatchDisplay(showPlusSign: true),
          '-0 01:00:00',
        );
      });

      test('negative with days uses the absolute magnitude', () {
        expect(
          const Duration(days: -1, hours: -2, minutes: -3, seconds: -4)
              .toStopwatchDisplay(),
          '-1 02:03:04',
        );
      });

      test('sub-second components are truncated', () {
        expect(
          const Duration(milliseconds: 999).toStopwatchDisplay(),
          '0 00:00:00',
        );
      });

      test('hours wrap at a day boundary', () {
        expect(
          const Duration(hours: 25).toStopwatchDisplay(),
          '1 01:00:00',
        );
      });

      test('minutes and seconds wrap at their boundaries', () {
        expect(
          const Duration(minutes: 61, seconds: 61).toStopwatchDisplay(),
          '0 01:02:01',
        );
      });
    });
  });
}

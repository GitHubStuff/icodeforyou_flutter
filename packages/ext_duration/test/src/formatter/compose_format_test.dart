// packages/ext_duration/test/src/formatter/compose_format_test.dart
//
// `compose_format.dart` is a `part of` `ext_duration.dart`, so its private
// helpers (`_templateSign`, `_leadingUnit`, `_templateBody`) are exercised
// exclusively through the public `ExtDuration.composeFormat` entry point.
// Every branch in each helper is targeted below.

import 'package:ext_duration/src/ext_duration.dart';
import 'package:test/test.dart';

String _compose(
  Duration duration, {
  bool showPlusSign = false,
  bool showLeaderZero = false,
  bool padHours = false,
}) =>
    duration.composeFormat(
      showPlusSign: showPlusSign,
      showLeaderZero: showLeaderZero,
      padHours: padHours,
    );

void main() {
  group('compose_format', () {
    group('template sign', () {
      test('negative yields %n', () {
        expect(_compose(const Duration(seconds: -1)), startsWith('%n'));
      });

      test('negative yields %n even when showPlusSign is true', () {
        expect(
          _compose(const Duration(seconds: -1), showPlusSign: true),
          startsWith('%n'),
        );
      });

      test('non-negative yields + when showPlusSign is true', () {
        expect(
          _compose(const Duration(seconds: 1), showPlusSign: true),
          startsWith('+'),
        );
      });

      test('non-negative yields nothing when showPlusSign is false', () {
        expect(_compose(const Duration(seconds: 1)), '%s');
      });

      test('zero is non-negative and receives +', () {
        expect(_compose(Duration.zero, showPlusSign: true), '+%s');
      });

      test('zero without plus sign has no prefix', () {
        expect(_compose(Duration.zero), '%s');
      });
    });

    group('leading unit', () {
      test('showLeaderZero forces days regardless of magnitude', () {
        expect(_compose(Duration.zero, showLeaderZero: true), '%d %h:%02m:%02s');
        expect(
          _compose(const Duration(seconds: 1), showLeaderZero: true),
          '%d %h:%02m:%02s',
        );
        expect(
          _compose(const Duration(minutes: 1), showLeaderZero: true),
          '%d %h:%02m:%02s',
        );
        expect(
          _compose(const Duration(hours: 1), showLeaderZero: true),
          '%d %h:%02m:%02s',
        );
      });

      test('days when inDays > 0', () {
        expect(_compose(const Duration(days: 1)), '%d %h:%02m:%02s');
      });

      test('days exactly at the 24-hour boundary', () {
        expect(_compose(const Duration(hours: 24)), '%d %h:%02m:%02s');
      });

      test('hours when inHours > 0 and no days', () {
        expect(_compose(const Duration(hours: 1)), '%h:%02m:%02s');
        expect(_compose(const Duration(hours: 23)), '%h:%02m:%02s');
      });

      test('hours exactly at the 60-minute boundary', () {
        expect(_compose(const Duration(minutes: 60)), '%h:%02m:%02s');
      });

      test('minutes when inMinutes > 0 and no hours', () {
        expect(_compose(const Duration(minutes: 1)), '%m:%02s');
        expect(_compose(const Duration(minutes: 59)), '%m:%02s');
      });

      test('minutes exactly at the 60-second boundary', () {
        expect(_compose(const Duration(seconds: 60)), '%m:%02s');
      });

      test('seconds when nothing larger is present', () {
        expect(_compose(const Duration(seconds: 1)), '%s');
        expect(_compose(const Duration(seconds: 59)), '%s');
      });

      test('seconds for sub-second durations', () {
        expect(_compose(const Duration(milliseconds: 999)), '%s');
        expect(_compose(const Duration(microseconds: 1)), '%s');
      });

      test('seconds for zero', () {
        expect(_compose(Duration.zero), '%s');
      });

      test('is determined from the absolute value', () {
        expect(_compose(const Duration(days: -1)), '%n%d %h:%02m:%02s');
        expect(_compose(const Duration(hours: -1)), '%n%h:%02m:%02s');
        expect(_compose(const Duration(minutes: -1)), '%n%m:%02s');
        expect(_compose(const Duration(seconds: -1)), '%n%s');
      });
    });

    group('template body', () {
      test('days, unpadded hours', () {
        expect(_compose(const Duration(days: 1)), '%d %h:%02m:%02s');
      });

      test('days, padded hours', () {
        expect(
          _compose(const Duration(days: 1), padHours: true),
          '%d %02h:%02m:%02s',
        );
      });

      test('hours, unpadded', () {
        expect(_compose(const Duration(hours: 1)), '%h:%02m:%02s');
      });

      test('hours, padded', () {
        expect(
          _compose(const Duration(hours: 1), padHours: true),
          '%02h:%02m:%02s',
        );
      });

      test('minutes ignore padHours', () {
        expect(_compose(const Duration(minutes: 1)), '%m:%02s');
        expect(_compose(const Duration(minutes: 1), padHours: true), '%m:%02s');
      });

      test('seconds ignore padHours', () {
        expect(_compose(const Duration(seconds: 1)), '%s');
        expect(_compose(const Duration(seconds: 1), padHours: true), '%s');
      });
    });

    group('full flag matrix', () {
      const durations = <String, Duration>{
        'seconds': Duration(seconds: 9),
        'minutes': Duration(minutes: 5, seconds: 9),
        'hours': Duration(hours: 1, minutes: 5, seconds: 9),
        'days': Duration(days: 2),
      };

      const bodies = <String, Map<bool, String>>{
        'seconds': {false: '%s', true: '%s'},
        'minutes': {false: '%m:%02s', true: '%m:%02s'},
        'hours': {false: '%h:%02m:%02s', true: '%02h:%02m:%02s'},
        'days': {false: '%d %h:%02m:%02s', true: '%d %02h:%02m:%02s'},
      };

      for (final entry in durations.entries) {
        for (final showPlusSign in [false, true]) {
          for (final showLeaderZero in [false, true]) {
            for (final padHours in [false, true]) {
              test(
                '${entry.key} plus=$showPlusSign leader=$showLeaderZero '
                'pad=$padHours',
                () {
                  final body = showLeaderZero
                      ? bodies['days']![padHours]!
                      : bodies[entry.key]![padHours]!;
                  final sign = showPlusSign ? '+' : '';

                  expect(
                    _compose(
                      entry.value,
                      showPlusSign: showPlusSign,
                      showLeaderZero: showLeaderZero,
                      padHours: padHours,
                    ),
                    '$sign$body',
                  );
                  expect(
                    _compose(
                      -entry.value,
                      showPlusSign: showPlusSign,
                      showLeaderZero: showLeaderZero,
                      padHours: padHours,
                    ),
                    '%n$body',
                  );
                },
              );
            }
          }
        }
      }
    });
  });
}

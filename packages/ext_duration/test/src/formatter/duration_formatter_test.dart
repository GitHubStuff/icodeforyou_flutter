// packages/ext_duration/test/src/formatter/duration_formatter_test.dart

import 'package:ext_duration/src/formatter/duration_formatter.dart';
import 'package:test/test.dart';

/// 1 day, 2 h, 5 min, 9 s, 42 ms, 7 µs.
///
/// Totals: 26 h · 1565 min · 93909 s · 93909042 ms · 93909042007 µs.
const _sample = Duration(
  days: 1,
  hours: 2,
  minutes: 5,
  seconds: 9,
  milliseconds: 42,
  microseconds: 7,
);

Matcher _formatException({
  required String message,
  required String source,
  required int offset,
}) => throwsA(
  isA<FormatException>()
      .having((e) => e.message, 'message', message)
      .having((e) => e.source, 'source', source)
      .having((e) => e.offset, 'offset', offset),
);

void main() {
  group('DurationFormatter', () {
    group('construction', () {
      test('exposes the pattern it was built from', () {
        expect(DurationFormatter('%d').pattern, '%d');
      });

      test('an instance can be reused for many durations', () {
        final formatter = DurationFormatter('%S');

        expect(formatter.format(const Duration(seconds: 1)), '1');
        expect(formatter.format(const Duration(seconds: 2)), '2');
        expect(formatter.format(Duration.zero), '0');
      });
    });

    group('literals', () {
      test('empty pattern yields empty string', () {
        expect(DurationFormatter('').format(_sample), '');
      });

      test('pattern without conversions is returned verbatim', () {
        expect(DurationFormatter('hello world').format(_sample), 'hello world');
      });

      test('literal before a conversion', () {
        expect(DurationFormatter('days=%d').format(_sample), 'days=1');
      });

      test('literal after a conversion', () {
        expect(DurationFormatter('%d days').format(_sample), '1 days');
      });

      test('literals between conversions', () {
        expect(DurationFormatter('%d-%h-%m').format(_sample), '1-2-5');
      });

      test('adjacent conversions without literals', () {
        expect(DurationFormatter('%d%h%m').format(_sample), '125');
      });

      test('non-ASCII literals are preserved', () {
        expect(DurationFormatter('⏱ %s s').format(_sample), '⏱ 9 s');
      });
    });

    group('conversions', () {
      test('d — whole days', () {
        expect(DurationFormatter('%d').format(_sample), '1');
      });

      test('h — hours within the day', () {
        expect(DurationFormatter('%h').format(_sample), '2');
      });

      test('H — total hours', () {
        expect(DurationFormatter('%H').format(_sample), '26');
      });

      test('m — minutes within the hour', () {
        expect(DurationFormatter('%m').format(_sample), '5');
      });

      test('M — total minutes', () {
        expect(DurationFormatter('%M').format(_sample), '1565');
      });

      test('s — seconds within the minute', () {
        expect(DurationFormatter('%s').format(_sample), '9');
      });

      test('S — total seconds', () {
        expect(DurationFormatter('%S').format(_sample), '93909');
      });

      test('l — milliseconds within the second', () {
        expect(DurationFormatter('%l').format(_sample), '42');
      });

      test('L — total milliseconds', () {
        expect(DurationFormatter('%L').format(_sample), '93909042');
      });

      test('u — microseconds within the millisecond', () {
        expect(DurationFormatter('%u').format(_sample), '7');
      });

      test('U — total microseconds', () {
        expect(DurationFormatter('%U').format(_sample), '93909042007');
      });

      test('n — empty for non-negative', () {
        expect(DurationFormatter('%n').format(_sample), '');
        expect(DurationFormatter('%n').format(Duration.zero), '');
      });

      test('n — minus for negative', () {
        expect(DurationFormatter('%n').format(-_sample), '-');
      });

      test('% — literal percent sign', () {
        expect(DurationFormatter('%%').format(_sample), '%');
        expect(DurationFormatter('100%%').format(_sample), '100%');
      });

      test('numeric conversions use the absolute value', () {
        final formatter = DurationFormatter('%d|%h|%H|%m|%M|%s|%S|%l|%L|%u|%U');
        const expected = '1|2|26|5|1565|9|93909|42|93909042|7|93909042007';

        expect(formatter.format(_sample), expected);
        expect(formatter.format(-_sample), expected);
      });

      test('h wraps at 24 hours', () {
        expect(DurationFormatter('%h').format(const Duration(hours: 23)), '23');
        expect(DurationFormatter('%h').format(const Duration(hours: 24)), '0');
        expect(DurationFormatter('%h').format(const Duration(hours: 25)), '1');
      });

      test('m wraps at 60 minutes', () {
        expect(
          DurationFormatter('%m').format(const Duration(minutes: 59)),
          '59',
        );
        expect(
          DurationFormatter('%m').format(const Duration(minutes: 60)),
          '0',
        );
        expect(
          DurationFormatter('%m').format(const Duration(minutes: 61)),
          '1',
        );
      });

      test('s wraps at 60 seconds', () {
        expect(
          DurationFormatter('%s').format(const Duration(seconds: 59)),
          '59',
        );
        expect(
          DurationFormatter('%s').format(const Duration(seconds: 60)),
          '0',
        );
        expect(
          DurationFormatter('%s').format(const Duration(seconds: 61)),
          '1',
        );
      });

      test('l wraps at 1000 milliseconds', () {
        expect(
          DurationFormatter('%l').format(const Duration(milliseconds: 999)),
          '999',
        );
        expect(
          DurationFormatter('%l').format(const Duration(milliseconds: 1000)),
          '0',
        );
        expect(
          DurationFormatter('%l').format(const Duration(milliseconds: 1001)),
          '1',
        );
      });

      test('u wraps at 1000 microseconds', () {
        expect(
          DurationFormatter('%u').format(const Duration(microseconds: 999)),
          '999',
        );
        expect(
          DurationFormatter('%u').format(const Duration(microseconds: 1000)),
          '0',
        );
        expect(
          DurationFormatter('%u').format(const Duration(microseconds: 1001)),
          '1',
        );
      });

      test('zero duration', () {
        expect(
          DurationFormatter(
            '%d|%h|%H|%m|%M|%s|%S|%l|%L|%u|%U|%n',
          ).format(Duration.zero),
          '0|0|0|0|0|0|0|0|0|0|0|',
        );
      });
    });

    group('width', () {
      test('no width means no padding', () {
        expect(DurationFormatter('%S').format(_sample), '93909');
      });

      test('width equal to length adds nothing', () {
        expect(DurationFormatter('%5S').format(_sample), '93909');
      });

      test('width smaller than length adds nothing', () {
        expect(DurationFormatter('%1S').format(_sample), '93909');
      });

      test('width pads with spaces on the left by default', () {
        expect(DurationFormatter('%7S').format(_sample), '  93909');
      });

      test('multi-digit width is parsed as a decimal number', () {
        expect(DurationFormatter('%12U').format(_sample), ' 93909042007');
      });

      test('width applies to the sign conversion', () {
        expect(DurationFormatter('%2n|').format(-_sample), ' -|');
        expect(DurationFormatter('%2n|').format(_sample), '  |');
      });

      test('width applies to the percent conversion', () {
        expect(DurationFormatter('%3%').format(_sample), '  %');
      });
    });

    group('flags', () {
      test('0 pads with zeros', () {
        expect(DurationFormatter('%02h').format(_sample), '02');
        expect(DurationFormatter('%07S').format(_sample), '0093909');
      });

      test('0 without width is a no-op', () {
        expect(DurationFormatter('%0h').format(_sample), '2');
      });

      test('- left-justifies with spaces', () {
        expect(DurationFormatter('%-7S|').format(_sample), '93909  |');
      });

      test('- without width is a no-op', () {
        expect(DurationFormatter('%-h|').format(_sample), '2|');
      });

      test('- takes precedence over 0', () {
        expect(DurationFormatter('%-07S|').format(_sample), '93909  |');
        expect(DurationFormatter('%0-7S|').format(_sample), '93909  |');
      });

      test('repeated flags are accepted', () {
        expect(DurationFormatter('%--3d|').format(_sample), '1  |');
        expect(DurationFormatter('%003d').format(_sample), '001');
      });

      test('documentation examples', () {
        const d = Duration(hours: 26, minutes: 5, seconds: 9, milliseconds: 42);

        expect(DurationFormatter('%02H:%02m:%02s').format(d), '26:05:09');
        expect(
          DurationFormatter('%d day(s) %02h:%02m').format(d),
          '1 day(s) 02:05',
        );
        expect(DurationFormatter('%S.%03l s').format(d), '93909.042 s');
        expect(DurationFormatter('%n%M min').format(d), '1565 min');
        expect(DurationFormatter('%n%M min').format(-d), '-1565 min');
        expect(DurationFormatter('100%%').format(d), '100%');
      });
    });

    group('errors', () {
      test('lone percent at end of pattern', () {
        expect(
          () => DurationFormatter('%'),
          _formatException(
            message: 'Incomplete conversion specifier',
            source: '%',
            offset: 0,
          ),
        );
      });

      test('percent followed only by flags', () {
        expect(
          () => DurationFormatter('abc%0'),
          _formatException(
            message: 'Incomplete conversion specifier',
            source: 'abc%0',
            offset: 3,
          ),
        );
        expect(
          () => DurationFormatter('%-'),
          _formatException(
            message: 'Incomplete conversion specifier',
            source: '%-',
            offset: 0,
          ),
        );
      });

      test('percent followed only by width', () {
        expect(
          () => DurationFormatter('%5'),
          _formatException(
            message: 'Incomplete conversion specifier',
            source: '%5',
            offset: 0,
          ),
        );
      });

      test('percent followed by flags and width but no conversion', () {
        expect(
          () => DurationFormatter('x%-012'),
          _formatException(
            message: 'Incomplete conversion specifier',
            source: 'x%-012',
            offset: 1,
          ),
        );
      });

      test('unknown conversion', () {
        expect(
          () => DurationFormatter('%x'),
          _formatException(
            message: 'Unknown conversion specifier "%x"',
            source: '%x',
            offset: 0,
          ),
        );
      });

      test('unknown conversion after flags and width reports start offset', () {
        expect(
          () => DurationFormatter('ab %-02q'),
          _formatException(
            message: 'Unknown conversion specifier "%q"',
            source: 'ab %-02q',
            offset: 3,
          ),
        );
      });

      test('unknown conversion with a space symbol', () {
        expect(
          () => DurationFormatter('% d'),
          _formatException(
            message: 'Unknown conversion specifier "% "',
            source: '% d',
            offset: 0,
          ),
        );
      });

      test('error is raised for the first bad specifier only', () {
        expect(
          () => DurationFormatter('%d %x %y'),
          _formatException(
            message: 'Unknown conversion specifier "%x"',
            source: '%d %x %y',
            offset: 3,
          ),
        );
      });

      test('a valid pattern never throws', () {
        expect(
          () => DurationFormatter('%d %h %H %m %M %s %S %l %L %u %U %n %%'),
          returnsNormally,
        );
      });
    });
  });
}

// packages/ext_duration/test/src/formatter/duration_formatter_test.dart

import 'package:ext_duration/src/formatter/duration_formatter.dart'
    show DurationFormatter;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DurationFormatter', () {
    // 26h 5m 9s 42ms — the fixture used by the library documentation.
    const sample = Duration(
      hours: 26,
      minutes: 5,
      seconds: 9,
      milliseconds: 42,
    );

    group('constructor', () {
      test('exposes the pattern it was built from', () {
        const pattern = '%02H:%02m';
        final formatter = DurationFormatter(pattern);

        expect(formatter.pattern, pattern);
      });

      test('accepts an empty pattern', () {
        expect(DurationFormatter('').format(sample), '');
      });

      test('accepts a pattern with no conversions', () {
        expect(
          DurationFormatter('plain text').format(sample),
          'plain text',
        );
      });

      test('throws FormatException for a trailing bare percent', () {
        expect(
          () => DurationFormatter('abc%'),
          throwsA(
            isA<FormatException>()
                .having(
                  (e) => e.message,
                  'message',
                  'Incomplete conversion specifier',
                )
                .having((e) => e.source, 'source', 'abc%')
                .having((e) => e.offset, 'offset', 3),
          ),
        );
      });

      test('throws FormatException when only flags follow the percent', () {
        expect(
          () => DurationFormatter('%-0'),
          throwsA(
            isA<FormatException>()
                .having(
                  (e) => e.message,
                  'message',
                  'Incomplete conversion specifier',
                )
                .having((e) => e.offset, 'offset', 0),
          ),
        );
      });

      test('throws FormatException when only a width follows the percent', () {
        expect(
          () => DurationFormatter('x%12'),
          throwsA(
            isA<FormatException>()
                .having(
                  (e) => e.message,
                  'message',
                  'Incomplete conversion specifier',
                )
                .having((e) => e.offset, 'offset', 1),
          ),
        );
      });

      test('throws FormatException for an unknown conversion', () {
        expect(
          () => DurationFormatter('%02x'),
          throwsA(
            isA<FormatException>()
                .having(
                  (e) => e.message,
                  'message',
                  'Unknown conversion specifier "%x"',
                )
                .having((e) => e.source, 'source', '%02x')
                .having((e) => e.offset, 'offset', 0),
          ),
        );
      });

      test('reports the offset of the percent that started the bad field', () {
        expect(
          () => DurationFormatter('%d and %q'),
          throwsA(
            isA<FormatException>().having((e) => e.offset, 'offset', 7),
          ),
        );
      });

      test('parses eagerly so a bad pattern fails before format is called', () {
        expect(() => DurationFormatter('%z'), throwsFormatException);
      });
    });

    group('conversions', () {
      test('%d emits whole days', () {
        expect(DurationFormatter('%d').format(sample), '1');
        expect(
          DurationFormatter('%d').format(const Duration(hours: 23)),
          '0',
        );
        expect(
          DurationFormatter('%d').format(const Duration(days: 10, hours: 5)),
          '10',
        );
      });

      test('%h emits hours within the day', () {
        expect(DurationFormatter('%h').format(sample), '2');
        expect(
          DurationFormatter('%h').format(const Duration(hours: 23)),
          '23',
        );
        expect(
          DurationFormatter('%h').format(const Duration(hours: 24)),
          '0',
        );
      });

      test('%H emits total hours', () {
        expect(DurationFormatter('%H').format(sample), '26');
        expect(
          DurationFormatter('%H').format(const Duration(days: 2)),
          '48',
        );
      });

      test('%m emits minutes within the hour', () {
        expect(DurationFormatter('%m').format(sample), '5');
        expect(
          DurationFormatter('%m').format(const Duration(minutes: 59)),
          '59',
        );
        expect(
          DurationFormatter('%m').format(const Duration(minutes: 60)),
          '0',
        );
      });

      test('%M emits total minutes', () {
        expect(DurationFormatter('%M').format(sample), '1565');
        expect(
          DurationFormatter('%M').format(const Duration(hours: 2)),
          '120',
        );
      });

      test('%s emits seconds within the minute', () {
        expect(DurationFormatter('%s').format(sample), '9');
        expect(
          DurationFormatter('%s').format(const Duration(seconds: 59)),
          '59',
        );
        expect(
          DurationFormatter('%s').format(const Duration(seconds: 60)),
          '0',
        );
      });

      test('%S emits total seconds', () {
        expect(DurationFormatter('%S').format(sample), '93909');
        expect(
          DurationFormatter('%S').format(const Duration(minutes: 2)),
          '120',
        );
      });

      test('%l emits milliseconds within the second', () {
        expect(DurationFormatter('%l').format(sample), '42');
        expect(
          DurationFormatter('%l').format(const Duration(milliseconds: 999)),
          '999',
        );
        expect(
          DurationFormatter('%l').format(const Duration(milliseconds: 1000)),
          '0',
        );
      });

      test('%L emits total milliseconds', () {
        expect(DurationFormatter('%L').format(sample), '93909042');
        expect(
          DurationFormatter('%L').format(const Duration(seconds: 2)),
          '2000',
        );
      });

      test('%u emits microseconds within the millisecond', () {
        const d = Duration(milliseconds: 1, microseconds: 7);

        expect(DurationFormatter('%u').format(d), '7');
        expect(
          DurationFormatter('%u').format(const Duration(microseconds: 999)),
          '999',
        );
        expect(
          DurationFormatter('%u').format(const Duration(microseconds: 1000)),
          '0',
        );
      });

      test('%U emits total microseconds', () {
        const d = Duration(milliseconds: 1, microseconds: 7);

        expect(DurationFormatter('%U').format(d), '1007');
        expect(DurationFormatter('%U').format(sample), '93909042000');
      });

      test('%n emits a minus sign only for negative durations', () {
        expect(DurationFormatter('%n').format(sample), '');
        expect(DurationFormatter('%n').format(-sample), '-');
        expect(DurationFormatter('%n').format(Duration.zero), '');
      });

      test('%% emits a literal percent sign', () {
        expect(DurationFormatter('%%').format(sample), '%');
        expect(DurationFormatter('100%%').format(sample), '100%');
        expect(DurationFormatter('%%%%').format(sample), '%%');
      });

      test('numeric conversions use the absolute value', () {
        const negative = Duration(hours: -26, minutes: -5, seconds: -9);

        expect(DurationFormatter('%d').format(negative), '1');
        expect(DurationFormatter('%h').format(negative), '2');
        expect(DurationFormatter('%H').format(negative), '26');
        expect(DurationFormatter('%m').format(negative), '5');
        expect(DurationFormatter('%M').format(negative), '1565');
        expect(DurationFormatter('%s').format(negative), '9');
        expect(DurationFormatter('%S').format(negative), '93909');
        expect(DurationFormatter('%l').format(negative), '0');
        expect(DurationFormatter('%L').format(negative), '93909000');
        expect(DurationFormatter('%u').format(negative), '0');
        expect(DurationFormatter('%U').format(negative), '93909000000');
      });

      test('every conversion formats Duration.zero without error', () {
        const all = '%d%h%H%m%M%s%S%l%L%u%U%n%%';

        expect(DurationFormatter(all).format(Duration.zero), '00000000000%');
      });
    });

    group('width and flags', () {
      test('width of zero applies no padding', () {
        expect(DurationFormatter('%0d').format(sample), '1');
        expect(DurationFormatter('%-d').format(sample), '1');
      });

      test('pads with spaces on the left by default', () {
        expect(DurationFormatter('%5S').format(sample), '93909');
        expect(DurationFormatter('%3h').format(sample), '  2');
        expect(DurationFormatter('%7M').format(sample), '   1565');
      });

      test('zero flag pads with zeros on the left', () {
        expect(DurationFormatter('%02h').format(sample), '02');
        expect(DurationFormatter('%03l').format(sample), '042');
        expect(DurationFormatter('%06S').format(sample), '093909');
      });

      test('minus flag left-justifies with trailing spaces', () {
        expect(DurationFormatter('%-3d').format(sample), '1  ');
        expect(DurationFormatter('%-4h|').format(sample), '2   |');
      });

      test('minus flag overrides zero flag regardless of flag order', () {
        expect(DurationFormatter('%-05d').format(sample), '1    ');
        expect(DurationFormatter('%0-5d').format(sample), '1    ');
      });

      test('repeated flags are idempotent', () {
        expect(DurationFormatter('%003h').format(sample), '002');
        expect(DurationFormatter('%--3h').format(sample), '2  ');
      });

      test('does not truncate values wider than the field', () {
        expect(DurationFormatter('%1S').format(sample), '93909');
        expect(DurationFormatter('%-1S').format(sample), '93909');
        expect(DurationFormatter('%01S').format(sample), '93909');
      });

      test('parses multi-digit widths', () {
        expect(
          DurationFormatter('%12S').format(sample),
          '       93909',
        );
        expect(
          DurationFormatter('%010L').format(sample),
          '0093909042',
        );
      });

      test('width applies to %n and %% as well', () {
        expect(DurationFormatter('%2n').format(-sample), ' -');
        expect(DurationFormatter('%-2n|').format(-sample), '- |');
        expect(DurationFormatter('%3%').format(sample), '  %');
        expect(DurationFormatter('%03%').format(sample), '00%');
      });
    });

    group('literals', () {
      test('preserves literal text around conversions', () {
        expect(
          DurationFormatter('[%H] hours, [%m] minutes').format(sample),
          '[26] hours, [5] minutes',
        );
      });

      test('preserves leading and trailing literals', () {
        expect(DurationFormatter('>>%d<<').format(sample), '>>1<<');
      });

      test('handles adjacent conversions with no literal between them', () {
        expect(DurationFormatter('%d%h%m').format(sample), '125');
      });

      test('preserves non-ASCII literal text', () {
        expect(
          DurationFormatter('⏱ %H h — %02m min ✓').format(sample),
          '⏱ 26 h — 05 min ✓',
        );
      });

      test('preserves whitespace and newlines', () {
        expect(
          DurationFormatter('  %d\n\t%h ').format(sample),
          '  1\n\t2 ',
        );
      });
    });

    group('documentation examples', () {
      test('%02H:%02m:%02s → 26:05:09', () {
        expect(DurationFormatter('%02H:%02m:%02s').format(sample), '26:05:09');
      });

      test('%d day(s) %02h:%02m → 1 day(s) 02:05', () {
        expect(
          DurationFormatter('%d day(s) %02h:%02m').format(sample),
          '1 day(s) 02:05',
        );
      });

      test('%S.%03l s → 93909.042 s', () {
        expect(DurationFormatter('%S.%03l s').format(sample), '93909.042 s');
      });

      test('%n%M min → 1565 min', () {
        expect(DurationFormatter('%n%M min').format(sample), '1565 min');
      });

      test('(-d) %n%M min → -1565 min', () {
        expect(DurationFormatter('%n%M min').format(-sample), '-1565 min');
      });

      test('100%% → 100%', () {
        expect(DurationFormatter('100%%').format(sample), '100%');
      });
    });

    group('reuse', () {
      test('one instance formats many durations consistently', () {
        final formatter = DurationFormatter('%02H:%02m:%02s');

        expect(formatter.format(Duration.zero), '00:00:00');
        expect(formatter.format(const Duration(seconds: 1)), '00:00:01');
        expect(formatter.format(const Duration(minutes: 1)), '00:01:00');
        expect(formatter.format(const Duration(hours: 1)), '01:00:00');
        expect(formatter.format(const Duration(hours: 100)), '100:00:00');
        expect(formatter.format(sample), '26:05:09');
      });

      test('format has no side effects between calls', () {
        final formatter = DurationFormatter('%d|%h');

        final first = formatter.format(sample);
        final second = formatter.format(sample);

        expect(first, '1|2');
        expect(second, first);
      });
    });
  });
}

// packages/extensions/test/duration/unit_formatter_test.dart

import 'package:extensions/duration/unit_formatter.dart' show UnitFormatter;
import 'package:test/test.dart';

void main() {
  const f = UnitFormatter();

  group('UnitFormatter prefix handling', () {
    test('copies literal text before the token verbatim', () {
      expect(f.doFormat(on: 17, using: 'Day count = %D'), 'Day count = 17');
    });

    test('resolves %% to % in the prefix', () {
      expect(f.doFormat(on: 5, using: '100%% = %D'), '100% = 5');
    });

    test('returns a token-free template with %% resolved', () {
      expect(f.doFormat(on: 9, using: 'abc %% def'), 'abc % def');
    });

    test('returns an empty template unchanged', () {
      expect(f.doFormat(on: 9, using: ''), '');
    });
  });

  group('UnitFormatter tail handling', () {
    test('returns everything after the first token raw', () {
      expect(
        f.doFormat(on: 8, using: '%2Y %t|one|many|S'),
        ' 8 %t|one|many|S',
      );
    });

    test('leaves %% in the tail unresolved', () {
      expect(f.doFormat(on: 3, using: '%D and 50%%'), '3 and 50%%');
    });
  });

  group('UnitFormatter numeric rendering', () {
    test('bare token renders the value with no padding', () {
      expect(f.doFormat(on: 42, using: '%D'), '42');
    });

    test('zero renders as 0 when not suppressed', () {
      expect(f.doFormat(on: 0, using: '%D'), '0');
    });

    test('width pads with spaces by default', () {
      expect(f.doFormat(on: 42, using: '%5D'), '   42');
    });

    test('width with 0 flag pads with zeros', () {
      expect(f.doFormat(on: 42, using: '%05D'), '00042');
    });

    test('precision zero-fills to the minimum digit count', () {
      expect(f.doFormat(on: 42, using: '%.5D'), '00042');
    });

    test('C rule: precision suppresses the 0 flag, width space-pads', () {
      expect(f.doFormat(on: 42, using: '%08.5D'), '   00042');
    });

    test('width narrower than the value leaves it unpadded', () {
      expect(f.doFormat(on: 12345, using: '%3D'), '12345');
    });
  });

  group('UnitFormatter suppression', () {
    test('* renders empty for zero', () {
      expect(f.doFormat(on: 0, using: '%*D'), '');
    });

    test('* leaves non-zero values untouched', () {
      expect(f.doFormat(on: 5, using: '%*D'), '5');
    });

    test('* renders empty for zero on a plurality token', () {
      expect(f.doFormat(on: 0, using: '%*t|year|years|Y'), '');
    });

    test('* keeps surrounding prefix and tail intact', () {
      expect(f.doFormat(on: 0, using: 'a %*D b'), 'a  b');
    });
  });

  group('UnitFormatter grouping', () {
    test('groups thousands with the given separator', () {
      expect(f.doFormat(on: 1000, using: '%_,W'), '1,000');
    });

    test('accepts an arbitrary separator character', () {
      expect(f.doFormat(on: 1000, using: '%_^W'), '1^000');
    });

    test('groups every three digits from the right', () {
      expect(f.doFormat(on: 1234567, using: '%_.W'), '1.234.567');
    });

    test('leaves values under four digits ungrouped', () {
      expect(f.doFormat(on: 999, using: '%_,W'), '999');
    });

    test('space-pads the grouped value to the width', () {
      expect(f.doFormat(on: 1000, using: '%_,8W'), '   1,000');
    });

    test('grouped without width or pad renders the grouped value', () {
      expect(f.doFormat(on: 1234, using: '%_,W'), '1,234');
    });
  });

  group('UnitFormatter zero-padded grouping', () {
    test('g flag groups the pad: width counts digits, then groups', () {
      expect(f.doFormat(on: 1000, using: '%_,g08W'), '00,001,000');
    });

    test('g flag without width groups just the value', () {
      expect(f.doFormat(on: 1234, using: '%_,g0W'), '1,234');
    });

    test('default ungrouped pad: width counts characters', () {
      expect(f.doFormat(on: 1000, using: '%_,08W'), '0001,000');
    });

    test('ungrouped pad without width renders the grouped value', () {
      expect(f.doFormat(on: 1234, using: '%_,0W'), '1,234');
    });
  });

  group('UnitFormatter plurality', () {
    test('emits the singular arm for exactly 1', () {
      expect(f.doFormat(on: 1, using: '%t|year|years|Y'), 'year');
    });

    test('emits the plural arm for values above 1', () {
      expect(f.doFormat(on: 2, using: '%t|year|years|Y'), 'years');
    });

    test('emits the plural arm for 0', () {
      expect(f.doFormat(on: 0, using: '%t|year|years|Y'), 'years');
    });

    test('resolves %% inside an arm', () {
      expect(f.doFormat(on: 1, using: '%t|a%%b|c|s'), 'a%b');
    });

    test('resolves %| inside an arm', () {
      expect(f.doFormat(on: 2, using: '%t|a|c%|d|s'), 'c|d');
    });

    test('treats any other % inside an arm as a literal percent', () {
      expect(f.doFormat(on: 1, using: '%t|50%25 off|deals|s'), '50%25 off');
    });

    test('treats a trailing % inside an arm followed by pipe via escape', () {
      // '%x' is not an escape: '%' passes through, 'x' follows normally.
      expect(f.doFormat(on: 2, using: '%t|one|%x rate|s'), '%x rate');
    });

    test('allows empty arms', () {
      expect(f.doFormat(on: 1, using: '%t||many|s'), '');
      expect(f.doFormat(on: 3, using: '%t|one||s'), '');
    });
  });

  group('UnitFormatter unit letters', () {
    test('accepts every recognized unit letter', () {
      for (final q in const ['Y', 'M', 'W', 'D', 'H', 'm', 's', 'S', 'u']) {
        expect(f.doFormat(on: 7, using: '%$q'), '7', reason: 'unit $q');
      }
    });
  });

  group('UnitFormatter contract assertions', () {
    test('rejects a negative value', () {
      expect(
        () => f.doFormat(on: -1, using: '%D'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects a separator flag with no separator character', () {
      expect(
        () => f.doFormat(on: 1, using: '%_'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects a precision dot with no digits', () {
      expect(
        () => f.doFormat(on: 1, using: '%5.D'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects a token missing its terminator', () {
      expect(
        () => f.doFormat(on: 1, using: 'x%'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects an unknown unit letter', () {
      expect(
        () => f.doFormat(on: 1, using: '%x'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects t without an opening pipe', () {
      expect(
        () => f.doFormat(on: 1, using: '%t x'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects a plurality missing its second pipe', () {
      expect(
        () => f.doFormat(on: 1, using: '%t|one'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects a plurality missing its closing pipe', () {
      expect(
        () => f.doFormat(on: 1, using: '%t|one|many'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects a plurality with a bad driving unit letter', () {
      expect(
        () => f.doFormat(on: 1, using: '%t|one|many|x'),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('UnitFormatter multi-unit chaining', () {
    test('feeding the tail back in renders successive units', () {
      const template = '%Y years, %M months';

      final first = f.doFormat(on: 3, using: template);
      expect(first, '3 years, %M months');

      final second = f.doFormat(on: 2, using: first);
      expect(second, '3 years, 2 months');
    });

    test('an emitted plurality arm can itself carry the next token', () {
      // Arms are emitted literally, so an arm containing '%D' becomes a
      // formattable token for the next call in the chain.
      const template = '%t|%D day|%D days|D later';

      final first = f.doFormat(on: 5, using: template);
      expect(first, '%D days later');

      final second = f.doFormat(on: 5, using: first);
      expect(second, '5 days later');
    });
  });
}

// test/duration/unit_formatter_test.dart
//
// Focused branch coverage for the formatting DSL. The exhaustive 350-case
// sweep lives in sea_trial_test.dart; this file pins each grammar feature
// individually.

import 'package:extensions/duration/unit_formatter.dart' show UnitFormatter;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = UnitFormatter();

  String fmt(int on, String using) => formatter.doFormat(on: on, using: using);

  group('UnitFormatter prefix and passthrough', () {
    test('copies literal text before the token', () {
      expect(fmt(17, 'Day count = %D'), 'Day count = 17');
    });

    test('resolves %% escapes in the prefix', () {
      expect(fmt(5, '%%%D'), '%5');
    });

    test('returns a token-free template with %% resolved', () {
      expect(fmt(9, 'no tokens, 100%% done'), 'no tokens, 100% done');
    });

    test('leaves everything after the first token untouched', () {
      expect(fmt(8, '%2Y %t|one|many|S'), ' 8 %t|one|many|S');
      expect(fmt(3, '%Yy %Mmo %Dd'), '3y %Mmo %Dd');
    });
  });

  group('UnitFormatter numeric rendering', () {
    test('renders the bare value', () {
      expect(fmt(12345, '%D'), '12345');
    });

    test('space-pads to the field width', () {
      expect(fmt(5, '%4D'), '   5');
    });

    test('zero-pads to the field width', () {
      expect(fmt(42, '%05D'), '00042');
    });

    test('precision zero-fills the digits', () {
      expect(fmt(7, '%.3D'), '007');
    });

    test('precision suppresses the zero-pad flag, per C', () {
      expect(fmt(7, '%7.3D'), '    007');
      expect(fmt(7, '%07.3D'), '    007');
    });

    test('groups thousands with the given separator', () {
      expect(fmt(1234567, '%_,D'), '1,234,567');
      expect(fmt(1000000, '%_^s'), '1^000^000');
    });

    test('space-pads a grouped value to the width', () {
      expect(fmt(1000, '%_,8D'), '   1,000');
      expect(fmt(1234567, '%_,8D'), '1,234,567');
    });

    test('ungrouped zero-pad counts characters and pads outside the '
        'grouping', () {
      expect(fmt(1000, '%_,07W'), '001,000');
      expect(fmt(1234, '%_,0D'), '1,234');
    });

    test('grouped zero-pad counts digits and groups the fill', () {
      expect(fmt(1000, '%_,g08W'), '00,001,000');
      expect(fmt(12, '%_,g0D'), '12');
    });

    test('precision combines with grouping', () {
      expect(fmt(1000, '%_,.5W'), '01,000');
    });
  });

  group('UnitFormatter suppression', () {
    test('suppresses a zero value entirely', () {
      expect(fmt(0, '%*D'), '');
      expect(fmt(5, '%*D'), '5');
    });

    test('suppresses a zero plurality token', () {
      expect(fmt(0, '%*t|year|years|Y'), '');
      expect(fmt(1, '%*t|year|years|Y'), 'year');
    });
  });

  group('UnitFormatter plurality', () {
    test('selects the singular arm only for exactly one', () {
      expect(fmt(1, '%t|one|many|S'), 'one');
      expect(fmt(0, '%t|one|many|S'), 'many');
      expect(fmt(2, '%t|one|many|S'), 'many');
    });

    test('resolves %| and %% escapes inside the arms', () {
      expect(fmt(1, '%t|a%|b|c%%d|Y'), 'a|b');
      expect(fmt(3, '%t|a%|b|c%%d|Y'), 'c%d');
    });
  });

  group('UnitFormatter sign contract', () {
    test('asserts on a negative value', () {
      expect(() => fmt(-1, '%D'), throwsAssertionError);
    });
  });
}

// packages/extensions/test/datetime/src/datetime_delta_format_test.dart
//
// The formatter is deprecated but remains in lib, so it still counts toward
// coverage; the ignore below silences the in-package deprecation warnings.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:extensions/datetime/src/datetime_delta.dart'
    show DateTimeDelta;
import 'package:extensions/datetime/src/datetime_delta_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeDeltaFormat default pattern', () {
    test('renders years, months, days, and cascaded h:m:s', () {
      const delta = DateTimeDelta(
        isFuture: true,
        years: 2,
        months: 3,
        days: 5,
        hours: 1,
        minutes: 20,
        seconds: 30,
      );
      expect(delta.format(), '[02] (3) 5 01:20:30');
    });

    test('cascade keeps zero-valued lower units visible when a higher unit '
        'is non-zero', () {
      const delta = DateTimeDelta(
        isFuture: true,
        years: 1,
        months: 0,
        days: 0,
        hours: 0,
        minutes: 0,
        seconds: 0,
      );
      expect(delta.format(), '[01] (0) 0 00:00:00');
    });

    test('drops gated segments when everything is zero', () {
      const delta = DateTimeDelta(isFuture: true);
      expect(delta.format(), '0 ::');
    });

    test('prefixes a minus sign for a past delta', () {
      const delta = DateTimeDelta(isFuture: false, days: 2, hours: 3);
      expect(delta.format(), '-2 03:00:00');
    });
  });

  group('DateTimeDeltaFormat custom patterns', () {
    const delta = DateTimeDelta(
      isFuture: true,
      years: 2,
      months: 0,
      days: 7,
      hours: 0,
      minutes: 0,
      seconds: 0,
    );

    test('unconditional segment always renders', () {
      expect(delta.format(r'${D}'), '7');
    });

    test('star-gated segment renders only for non-zero values', () {
      expect(delta.format(r'$*{M}'), '');
      expect(delta.format(r'$*{Y}'), '2');
    });

    test('cascaded year segment has no higher unit to consult', () {
      const zeroYears = DateTimeDelta(isFuture: true, years: 0, days: 1);
      expect(zeroYears.format(r'$*{Y>}'), '');
      expect(delta.format(r'$*{Y>}'), '2');
    });

    test('repeated symbols zero-pad to the requested width', () {
      expect(delta.format(r'${YYY}'), '002');
    });

    test('bracketed width keeps the surrounding brackets', () {
      expect(delta.format(r'${[DD]}'), '[07]');
    });

    test('content without a unit letter falls back to days', () {
      expect(delta.format(r'${qqq}'), '7');
    });

    test('a lone dollar sign is a literal', () {
      expect(delta.format(r'$'), r'$');
    });

    test('a dollar sign without a brace is a literal', () {
      expect(delta.format(r'$x'), r'$x');
    });

    test('an unclosed brace degrades to literals', () {
      expect(delta.format(r'${Y'), r'${Y');
    });

    test('an empty result from a past delta stays unsigned', () {
      const past = DateTimeDelta(isFuture: false, days: 0);
      expect(past.format(r'$*{D}'), '');
    });

    test('a non-empty result from a past delta is signed', () {
      const past = DateTimeDelta(isFuture: false, days: 4);
      expect(past.format(r'${D}'), '-4');
    });

    test('null components format as zero', () {
      const sparse = DateTimeDelta(isFuture: true, days: 3);
      expect(sparse.format(r'${Y} ${D} ${s}'), '0 3 0');
    });
  });
}

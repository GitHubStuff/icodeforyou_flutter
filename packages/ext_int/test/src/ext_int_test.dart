// packages/ext_int/test/src/ext_int_test.dart

import 'package:ext_int/ext_int.dart' show ExtInt;
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntExt', () {
    group('toColor', () {
      test('maps a 32-bit ARGB integer to the equivalent Color', () {
        expect(0xFF2196F3.toColor(), const Color(0xFF2196F3));
      });

      test('preserves the alpha channel', () {
        expect(0x802196F3.toColor().a, closeTo(0x80 / 0xFF, 1e-9));
      });

      test('treats a 24-bit value as fully transparent', () {
        expect(0x2196F3.toColor().a, 0);
      });

      test('maps zero to transparent black', () {
        expect(0.toColor(), const Color(0x00000000));
      });

      test('maps 0xFFFFFFFF to opaque white', () {
        expect(0xFFFFFFFF.toColor(), const Color(0xFFFFFFFF));
      });
    });

    group('toSpeech', () {
      const singular = 'day';
      const plural = 'days';

      test('uses the singular form for 1', () {
        expect(1.toSpeech(singular: singular, plural: plural), '1 day');
      });

      test('uses the singular form for -1 and keeps the sign', () {
        expect(
          (-1).toSpeech(singular: singular, plural: plural),
          '-1 day',
        );
      });

      test('uses the plural form for 0', () {
        expect(0.toSpeech(singular: singular, plural: plural), '0 days');
      });

      test('uses the plural form for positive counts above 1', () {
        expect(12.toSpeech(singular: singular, plural: plural), '12 days');
      });

      test('uses the plural form for negative counts below -1', () {
        expect(
          (-12).toSpeech(singular: singular, plural: plural),
          '-12 days',
        );
      });

      test('does not insert thousands separators', () {
        expect(
          1000000.toSpeech(singular: singular, plural: plural),
          '1000000 days',
        );
      });

      test('supports irregular plurals supplied by the caller', () {
        expect(
          3.toSpeech(singular: 'child', plural: 'children'),
          '3 children',
        );
      });
    });

    group('toSimpleSpeech', () {
      test('uses the bare name for 1', () {
        expect(1.toSimpleSpeech(name: 'file'), '1 file');
      });

      test('uses the bare name for -1', () {
        expect((-1).toSimpleSpeech(name: 'file'), '-1 file');
      });

      test('appends an s for 0', () {
        expect(0.toSimpleSpeech(name: 'file'), '0 files');
      });

      test('appends an s for counts above 1', () {
        expect(4.toSimpleSpeech(name: 'file'), '4 files');
      });

      test('appends an s for counts below -1', () {
        expect((-4).toSimpleSpeech(name: 'file'), '-4 files');
      });

      test('delegates plural derivation to toSpeech', () {
        expect(
          7.toSimpleSpeech(name: 'item'),
          7.toSpeech(singular: 'item', plural: 'items'),
        );
      });
    });

    group('toUtc', () {
      test('maps zero to the Unix epoch', () {
        expect(0.toUtc(), DateTime.utc(1970));
      });

      test('interprets the value as microseconds', () {
        expect(
          1700000000000000.toUtc(),
          DateTime.utc(2023, 11, 14, 22, 13, 20),
        );
      });

      test('preserves sub-second precision', () {
        expect(
          1700000000123456.toUtc(),
          DateTime.utc(2023, 11, 14, 22, 13, 20, 123, 456),
        );
      });

      test('handles negative values before the epoch', () {
        expect(
          (-1000000).toUtc(),
          DateTime.utc(1969, 12, 31, 23, 59, 59),
        );
      });

      test('always returns a UTC DateTime', () {
        expect(1700000000000000.toUtc().isUtc, isTrue);
      });

      test('is the inverse of microsecondsSinceEpoch', () {
        final original = DateTime.utc(2001, 9, 9, 1, 46, 40, 1, 1);
        expect(original.microsecondsSinceEpoch.toUtc(), original);
      });
    });
  });
}

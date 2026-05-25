// packages/extensions/test/int_ext_test/int_ext2_test.dart
import 'package:extensions/int_ext/int_ext.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntExt.toColor', () {
    test('interprets the int as a 32-bit ARGB color', () {
      expect(0xFF112233.toColor(), const Color(0xFF112233));
    });

    test('a fully transparent value round-trips', () {
      expect(0x00000000.toColor(), const Color(0x00000000));
    });
  });

  group('IntExt.toUtc', () {
    test('interprets the int as a UTC microsecond epoch timestamp', () {
      final result = 1700000000000000.toUtc();

      expect(
        result,
        DateTime.fromMicrosecondsSinceEpoch(1700000000000000, isUtc: true),
      );
      expect(result.isUtc, isTrue);
    });

    test('zero maps to the UTC epoch', () {
      final result = 0.toUtc();

      expect(result, DateTime.utc(1970));
      expect(result.isUtc, isTrue);
    });
  });
}

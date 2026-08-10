// test/int/int_ext_test.dart

import 'package:extensions/int/int_ext.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntExt', () {
    test('toColor interprets the value as 32-bit ARGB', () {
      expect(0xFF112233.toColor(), const Color(0xFF112233));
    });

    test('toUtc interprets the value as UTC microseconds since epoch', () {
      final expected = DateTime.utc(2024);
      expect(expected.microsecondsSinceEpoch.toUtc(), expected);
      expect(expected.microsecondsSinceEpoch.toUtc().isUtc, isTrue);
    });
  });
}

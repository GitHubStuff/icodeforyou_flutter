// extensions/test/src/to_microseconds_or_null_ext_test.dart

import 'package:extensions/extensions.dart' show StringExt;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringExt.toMicrosecondsOrNull', () {
    test('returns microseconds for valid ISO 8601 date-time string', () {
      const input = '2024-01-15T10:30:00.000Z';
      final result = input.toMicrosecondsOrNull();
      expect(result, DateTime.parse(input).microsecondsSinceEpoch);
    });

    test('returns microseconds for valid date-only string', () {
      const input = '2024-06-01';
      final result = input.toMicrosecondsOrNull();
      expect(result, DateTime.parse(input).microsecondsSinceEpoch);
    });

    test('returns null for invalid date string', () {
      expect('not-a-date'.toMicrosecondsOrNull(), isNull);
    });

    test('returns null for empty string', () {
      expect(''.toMicrosecondsOrNull(), isNull);
    });

    test('returns null for partially valid string', () {
      expect('2024-13-01'.toMicrosecondsOrNull(), isNull);
    });
  });
}

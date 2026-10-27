// packages/sincewhen_screens/test/src/util/timestamp_display_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sincewhen_screens/sincewhen_screens.dart' show TimestampDisplay;

void main() {
  group('TimestampDisplay', () {
    test('noValue constant is an em dash', () {
      expect(TimestampDisplay.noValue, equals('—'));
    });

    group('format', () {
      test(
        'formats timestamp according to the display contract in local time',
        () {
          final localDateTime = DateTime(2024, 7, 14, 18, 27, 47);
          final micros = localDateTime.microsecondsSinceEpoch;

          final expectedDatePart = DateFormat(
            'EEE dd-MMM-yyyy h:mm:ss',
          ).format(localDateTime);
          final expectedMeridian = DateFormat(
            'a',
          ).format(localDateTime).toLowerCase();
          final expected = '$expectedDatePart $expectedMeridian';

          expect(TimestampDisplay.format(micros), equals(expected));
        },
      );

      test(
        'formats morning timestamp with lowercase am and no leading zero on hour',
        () {
          final localDateTime = DateTime(2026, 1, 5, 9, 5, 3);
          final micros = localDateTime.microsecondsSinceEpoch;

          final expectedDatePart = DateFormat(
            'EEE dd-MMM-yyyy h:mm:ss',
          ).format(localDateTime);
          final expectedMeridian = DateFormat(
            'a',
          ).format(localDateTime).toLowerCase();
          final expected = '$expectedDatePart $expectedMeridian';

          expect(TimestampDisplay.format(micros), equals(expected));
        },
      );
    });

    group('formatOrPlaceholder', () {
      test('returns default placeholder when timestamp is null', () {
        expect(
          TimestampDisplay.formatOrPlaceholder(null),
          equals(TimestampDisplay.noValue),
        );
      });

      test(
        'returns custom placeholder when provided and timestamp is null',
        () {
          expect(
            TimestampDisplay.formatOrPlaceholder(null, placeholder: 'N/A'),
            equals('N/A'),
          );
        },
      );

      test('formats timestamp when non-null', () {
        final localDateTime = DateTime(2025, 12, 31, 23, 59, 59);
        final micros = localDateTime.microsecondsSinceEpoch;

        final expected = TimestampDisplay.format(micros);

        expect(
          TimestampDisplay.formatOrPlaceholder(micros),
          equals(expected),
        );
      });
    });
  });
}

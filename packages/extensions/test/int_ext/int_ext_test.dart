// int_ext_test.dart
import 'package:extensions/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntExt', () {
    group('toUtc', () {
      test('should convert epoch start to UTC DateTime', () {
        // Arrange
        const epochMicroseconds = 0;

        // Act
        final result = epochMicroseconds.toUtc();

        // Assert
        expect(result.microsecondsSinceEpoch, equals(0));
        expect(result.isUtc, isTrue);
        expect(result.year, equals(1970));
        expect(result.month, equals(1));
        expect(result.day, equals(1));
        expect(result.hour, equals(0));
        expect(result.minute, equals(0));
        expect(result.second, equals(0));
        expect(result.millisecond, equals(0));
        expect(result.microsecond, equals(0));
      });

      test('should convert positive microseconds to UTC DateTime', () {
        // Arrange
        final expectedDateTime = DateTime.utc(2023, 12, 25, 12, 0, 0);
        final microseconds = expectedDateTime.microsecondsSinceEpoch;

        // Act
        final result = microseconds.toUtc();

        // Assert
        expect(result.microsecondsSinceEpoch, equals(microseconds));
        expect(result.isUtc, isTrue);
        expect(result.year, equals(2023));
        expect(result.month, equals(12));
        expect(result.day, equals(25));
        expect(result.hour, equals(12));
        expect(result.minute, equals(0));
        expect(result.second, equals(0));
      });

      test('should convert negative microseconds to UTC DateTime', () {
        // Arrange
        const negativeMicroseconds = -86400000000; // 1 day before epoch

        // Act
        final result = negativeMicroseconds.toUtc();

        // Assert
        expect(result.microsecondsSinceEpoch, equals(negativeMicroseconds));
        expect(result.isUtc, isTrue);
        expect(result.year, equals(1969));
        expect(result.month, equals(12));
        expect(result.day, equals(31));
      });

      test('should preserve microsecond precision', () {
        // Arrange
        final baseDateTime = DateTime.utc(2023, 12, 25, 12, 0, 0, 123, 456);
        final microsecondsWithPrecision = baseDateTime.microsecondsSinceEpoch;

        // Act
        final result = microsecondsWithPrecision.toUtc();

        // Assert
        expect(
          result.microsecondsSinceEpoch,
          equals(microsecondsWithPrecision),
        );
        expect(result.isUtc, isTrue);
        expect(result.millisecond, equals(123));
        expect(result.microsecond, equals(456));
      });

      test('should convert large future timestamp to UTC DateTime', () {
        // Arrange
        final futureDateTime = DateTime.utc(2100, 1, 1, 0, 0, 0);
        final futureMicroseconds = futureDateTime.microsecondsSinceEpoch;

        // Act
        final result = futureMicroseconds.toUtc();

        // Assert
        expect(result.microsecondsSinceEpoch, equals(futureMicroseconds));
        expect(result.isUtc, isTrue);
        expect(result.year, equals(2100));
        expect(result.month, equals(1));
        expect(result.day, equals(1));
      });

      test('should convert small positive value to UTC DateTime', () {
        // Arrange
        const smallMicroseconds = 1000000; // 1 second after epoch

        // Act
        final result = smallMicroseconds.toUtc();

        // Assert
        expect(result.microsecondsSinceEpoch, equals(smallMicroseconds));
        expect(result.isUtc, isTrue);
        expect(result.year, equals(1970));
        expect(result.month, equals(1));
        expect(result.day, equals(1));
        expect(result.hour, equals(0));
        expect(result.minute, equals(0));
        expect(result.second, equals(1));
      });

      test('should convert millisecond precision timestamp correctly', () {
        // Arrange
        final dateTimeWithMillisOnly = DateTime.utc(
          2023,
          12,
          25,
          12,
          0,
          0,
          123,
          0,
        );
        final millisecondsOnly = dateTimeWithMillisOnly.microsecondsSinceEpoch;

        // Act
        final result = millisecondsOnly.toUtc();

        // Assert
        expect(result.microsecondsSinceEpoch, equals(millisecondsOnly));
        expect(result.isUtc, isTrue);
        expect(result.millisecond, equals(123));
        expect(result.microsecond, equals(0));
      });

      test('should ensure returned DateTime is always UTC', () {
        // Arrange
        final testDateTime = DateTime.utc(2023, 12, 25, 12, 0, 0);
        final testMicroseconds = testDateTime.microsecondsSinceEpoch;

        // Act
        final result = testMicroseconds.toUtc();

        // Assert
        expect(result.isUtc, isTrue);
        expect(result.timeZoneName, equals('UTC'));
        expect(result.timeZoneOffset, equals(Duration.zero));
      });

      test(
        'should handle microsecond values that create exact minute boundaries',
        () {
          // Arrange
          final baseDateTime = DateTime.utc(2023, 12, 25, 12, 0, 0);
          final oneMinuteLater = baseDateTime.add(Duration(minutes: 1));
          final exactMinuteMicroseconds = oneMinuteLater.microsecondsSinceEpoch;

          // Act
          final result = exactMinuteMicroseconds.toUtc();

          // Assert
          expect(
            result.microsecondsSinceEpoch,
            equals(exactMinuteMicroseconds),
          );
          expect(result.isUtc, isTrue);
          expect(result.minute, equals(1));
          expect(result.second, equals(0));
          expect(result.millisecond, equals(0));
          expect(result.microsecond, equals(0));
        },
      );

      test('should roundtrip conversion preserve original value', () {
        // Arrange
        final originalDateTime = DateTime.utc(
          2023,
          12,
          25,
          14,
          30,
          12,
          345,
          678,
        );
        final originalMicroseconds = originalDateTime.microsecondsSinceEpoch;

        // Act
        final dateTime = originalMicroseconds.toUtc();
        final convertedBack = dateTime.microsecondsSinceEpoch;

        // Assert
        expect(convertedBack, equals(originalMicroseconds));
        expect(dateTime.isUtc, isTrue);
      });

      test('should handle maximum and minimum safe integer values', () {
        // Arrange
        const maxSafeInt = 9007199254740991; // JavaScript safe integer limit
        const minSafeInt = -9007199254740991;

        // Act
        final maxResult = maxSafeInt.toUtc();
        final minResult = minSafeInt.toUtc();

        // Assert
        expect(maxResult.microsecondsSinceEpoch, equals(maxSafeInt));
        expect(maxResult.isUtc, isTrue);
        expect(minResult.microsecondsSinceEpoch, equals(minSafeInt));
        expect(minResult.isUtc, isTrue);
      });
    });
  });
}

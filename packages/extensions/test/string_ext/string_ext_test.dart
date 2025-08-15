// string_ext_test.dart
import 'package:extensions/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringExt', () {
    group('toMicrosecondsOrNull', () {
      test('should return microseconds for valid ISO 8601 date string', () {
        // Arrange
        const dateString = '2023-12-25T10:30:45.123456Z';
        final expectedMicroseconds = DateTime.parse(
          dateString,
        ).microsecondsSinceEpoch;

        // Act
        final result = dateString.toMicrosecondsOrNull();

        // Assert
        expect(result, equals(expectedMicroseconds));
        expect(result, isA<int>());
      });

      test('should return microseconds for valid date string without time', () {
        // Arrange
        const dateString = '2023-12-25';
        final expectedMicroseconds = DateTime.parse(
          dateString,
        ).microsecondsSinceEpoch;

        // Act
        final result = dateString.toMicrosecondsOrNull();

        // Assert
        expect(result, equals(expectedMicroseconds));
      });

      test(
        'should return microseconds for valid date-time string with timezone',
        () {
          // Arrange
          const dateString = '2023-12-25T10:30:45+02:00';
          final expectedMicroseconds = DateTime.parse(
            dateString,
          ).microsecondsSinceEpoch;

          // Act
          final result = dateString.toMicrosecondsOrNull();

          // Assert
          expect(result, equals(expectedMicroseconds));
        },
      );

      test('should return microseconds for valid local date-time string', () {
        // Arrange
        const dateString = '2023-12-25T10:30:45';
        final expectedMicroseconds = DateTime.parse(
          dateString,
        ).microsecondsSinceEpoch;

        // Act
        final result = dateString.toMicrosecondsOrNull();

        // Assert
        expect(result, equals(expectedMicroseconds));
      });

      test('should return null for invalid date string', () {
        // Arrange
        const invalidDateString = 'not-a-date';

        // Act
        final result = invalidDateString.toMicrosecondsOrNull();

        // Assert
        expect(result, isNull);
      });

      test('should return null for empty string', () {
        // Arrange
        const emptyString = '';

        // Act
        final result = emptyString.toMicrosecondsOrNull();

        // Assert
        expect(result, isNull);
      });

      test('should return null for malformed date string', () {
        // Arrange
        const malformedDate = '2023/12/25'; // Wrong separator format

        // Act
        final result = malformedDate.toMicrosecondsOrNull();

        // Assert
        expect(result, isNull);
      });

      test('should return null for partially valid date string', () {
        // Arrange
        const partialDate = '25-12-2023'; // Wrong date order format

        // Act
        final result = partialDate.toMicrosecondsOrNull();

        // Assert
        expect(result, isNull);
      });

      test('should return null for string with invalid time format', () {
        // Arrange
        const invalidTime = '2023-12-25X10:30:45'; // Invalid T separator

        // Act
        final result = invalidTime.toMicrosecondsOrNull();

        // Assert
        expect(result, isNull);
      });

      test('should return null for numeric string that is not a date', () {
        // Arrange
        const numericString = '12345';

        // Act
        final result = numericString.toMicrosecondsOrNull();

        // Assert
        expect(result, isNull);
      });

      test('should return null for string with special characters', () {
        // Arrange
        const specialCharsString = '@#\$%^&*()';

        // Act
        final result = specialCharsString.toMicrosecondsOrNull();

        // Assert
        expect(result, isNull);
      });

      test('should return null for whitespace-only string', () {
        // Arrange
        const whitespaceString = '   ';

        // Act
        final result = whitespaceString.toMicrosecondsOrNull();

        // Assert
        expect(result, isNull);
      });

      test('should handle edge case: epoch start date', () {
        // Arrange
        const epochStart = '1970-01-01T00:00:00.000Z';

        // Act
        final result = epochStart.toMicrosecondsOrNull();

        // Assert
        expect(result, equals(0));
      });

      test('should handle edge case: far future date', () {
        // Arrange
        const futureDate = '2100-12-31T23:59:59.999999Z';
        final expectedMicroseconds = DateTime.parse(
          futureDate,
        ).microsecondsSinceEpoch;

        // Act
        final result = futureDate.toMicrosecondsOrNull();

        // Assert
        expect(result, equals(expectedMicroseconds));
        expect(result, greaterThan(0));
      });
    });
  });
}

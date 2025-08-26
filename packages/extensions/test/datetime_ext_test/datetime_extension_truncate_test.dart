// datetime_extension_test.dart

import 'package:extensions/datetime_ext/datetime_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExt', () {
    group('truncate', () {
      late DateTime testDateTime;
      late DateTime testDateTimeUtc;

      setUp(() {
        // Create test DateTime with all components set
        testDateTime = DateTime(2024, 8, 24, 15, 30, 45, 123, 456);
        testDateTimeUtc = DateTime.utc(2024, 8, 24, 15, 30, 45, 123, 456);
      });

      test('should truncate to microsecond precision (default behavior)', () {
        // Act
        final result = testDateTime.truncate(atDateTimeUnit: DateTimeUnit.usec);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 8);
        expect(result.day, 24);
        expect(result.hour, 15);
        expect(result.minute, 30);
        expect(result.second, 45);
        expect(result.millisecond, 123);
        expect(result.microsecond, 456);
        expect(result.isUtc, false);
      });

      test('should truncate to millisecond precision', () {
        // Act
        final result = testDateTime.truncate(atDateTimeUnit: DateTimeUnit.msec);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 8);
        expect(result.day, 24);
        expect(result.hour, 15);
        expect(result.minute, 30);
        expect(result.second, 45);
        expect(result.millisecond, 123);
        expect(result.microsecond, 0); // Should be truncated
        expect(result.isUtc, false);
      });

      test('should truncate to minute precision', () {
        // Act
        final result = testDateTime.truncate(
          atDateTimeUnit: DateTimeUnit.minute,
        );

        // Assert
        expect(result.year, 2024);
        expect(result.month, 8);
        expect(result.day, 24);
        expect(result.hour, 15);
        expect(result.minute, 30);
        expect(result.second, 0); // Should be truncated
        expect(result.millisecond, 0); // Should be truncated
        expect(result.microsecond, 0); // Should be truncated
        expect(result.isUtc, false);
      });

      test('should truncate to hour precision', () {
        // Act
        final result = testDateTime.truncate(atDateTimeUnit: DateTimeUnit.hour);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 8);
        expect(result.day, 24);
        expect(result.hour, 15);
        expect(result.minute, 0); // Should be truncated
        expect(result.second, 0); // Should be truncated
        expect(result.millisecond, 0); // Should be truncated
        expect(result.microsecond, 0); // Should be truncated
        expect(result.isUtc, false);
      });

      test('should truncate to day precision', () {
        // Act
        final result = testDateTime.truncate(atDateTimeUnit: DateTimeUnit.day);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 8);
        expect(result.day, 24);
        expect(result.hour, 0); // Should be truncated
        expect(result.minute, 0); // Should be truncated
        expect(result.second, 0); // Should be truncated
        expect(result.millisecond, 0); // Should be truncated
        expect(result.microsecond, 0); // Should be truncated
        expect(result.isUtc, false);
      });

      test('should truncate to month precision', () {
        // Act
        final result = testDateTime.truncate(
          atDateTimeUnit: DateTimeUnit.month,
        );

        // Assert
        expect(result.year, 2024);
        expect(result.month, 8);
        expect(result.day, 1); // Should be reset to 1
        expect(result.hour, 0); // Should be truncated
        expect(result.minute, 0); // Should be truncated
        expect(result.second, 0); // Should be truncated
        expect(result.millisecond, 0); // Should be truncated
        expect(result.microsecond, 0); // Should be truncated
        expect(result.isUtc, false);
      });

      test('should truncate to year precision', () {
        // Act
        final result = testDateTime.truncate(atDateTimeUnit: DateTimeUnit.year);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 1); // Should be reset to 1
        expect(result.day, 1); // Should be reset to 1
        expect(result.hour, 0); // Should be truncated
        expect(result.minute, 0); // Should be truncated
        expect(result.second, 0); // Should be truncated
        expect(result.millisecond, 0); // Should be truncated
        expect(result.microsecond, 0); // Should be truncated
        expect(result.isUtc, false);
      });

      test('should preserve UTC when truncating UTC DateTime', () {
        // Act
        final result = testDateTimeUtc.truncate(
          atDateTimeUnit: DateTimeUnit.second,
        );

        // Assert
        expect(result.year, 2024);
        expect(result.month, 8);
        expect(result.day, 24);
        expect(result.hour, 15);
        expect(result.minute, 30);
        expect(result.second, 45);
        expect(result.millisecond, 0); // Should be truncated
        expect(result.microsecond, 0); // Should be truncated
        expect(result.isUtc, true); // Should preserve UTC
      });

      test('should preserve local time when truncating local DateTime', () {
        // Act
        final result = testDateTime.truncate(
          atDateTimeUnit: DateTimeUnit.minute,
        );

        // Assert
        expect(result.isUtc, false); // Should preserve local time
      });

      test('should handle edge case where next is null', () {
        // This tests the ?? {} fallback in the code
        // We need to test a DateTimeUnit that might not have a next
        // Act
        final result = testDateTime.truncate(atDateTimeUnit: DateTimeUnit.usec);

        // Assert - should not throw and should preserve all values
        expect(result.year, 2024);
        expect(result.month, 8);
        expect(result.day, 24);
        expect(result.hour, 15);
        expect(result.minute, 30);
        expect(result.second, 45);
        expect(result.millisecond, 123);
        expect(result.microsecond, 456);
      });

      test('should handle different month values correctly', () {
        // Arrange
        final februaryDateTime = DateTime(2024, 2, 15, 10, 20, 30, 400, 500);

        // Act
        final result = februaryDateTime.truncate(
          atDateTimeUnit: DateTimeUnit.month,
        );

        // Assert
        expect(result.year, 2024);
        expect(result.month, 2);
        expect(result.day, 1); // Should be reset to 1
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.millisecond, 0);
        expect(result.microsecond, 0);
      });

      test('should handle year boundary correctly', () {
        // Arrange
        final newYearDateTime = DateTime(2025, 1, 1, 0, 0, 0, 1, 1);

        // Act
        final result = newYearDateTime.truncate(
          atDateTimeUnit: DateTimeUnit.second,
        );

        // Assert
        expect(result.year, 2025);
        expect(result.month, 1);
        expect(result.day, 1);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.millisecond, 0); // Should be truncated
        expect(result.microsecond, 0); // Should be truncated
      });

      test('should handle zero values correctly', () {
        // Arrange
        final zeroDateTime = DateTime(2024, 1, 1, 0, 0, 0, 0, 0);

        // Act
        final result = zeroDateTime.truncate(
          atDateTimeUnit: DateTimeUnit.minute,
        );

        // Assert
        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 1);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.millisecond, 0);
        expect(result.microsecond, 0);
      });

      test('should handle maximum values correctly', () {
        // Arrange
        final maxDateTime = DateTime(2024, 12, 31, 23, 59, 59, 999, 999);

        // Act
        final result = maxDateTime.truncate(atDateTimeUnit: DateTimeUnit.hour);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 12);
        expect(result.day, 31);
        expect(result.hour, 23);
        expect(result.minute, 0); // Should be truncated
        expect(result.second, 0); // Should be truncated
        expect(result.millisecond, 0); // Should be truncated
        expect(result.microsecond, 0); // Should be truncated
      });

      test('should use DateTime.utc constructor for UTC dates', () {
        // Arrange
        final utcDateTime = DateTime.utc(2024, 6, 15, 12, 30, 45, 100, 200);

        // Act
        final result = utcDateTime.truncate(atDateTimeUnit: DateTimeUnit.day);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 6);
        expect(result.day, 15);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.millisecond, 0);
        expect(result.microsecond, 0);
        expect(result.isUtc, true);
      });

      test('should use DateTime.new constructor for local dates', () {
        // Arrange
        final localDateTime = DateTime(2024, 6, 15, 12, 30, 45, 100, 200);

        // Act
        final result = localDateTime.truncate(atDateTimeUnit: DateTimeUnit.day);

        // Assert
        expect(result.year, 2024);
        expect(result.month, 6);
        expect(result.day, 15);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.millisecond, 0);
        expect(result.microsecond, 0);
        expect(result.isUtc, false);
      });
    });
  });
}

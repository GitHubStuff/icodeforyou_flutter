// timestamp_test.dart
import 'package:extensions/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExt', () {
    group('timeStamp', () {
      test('should format timestamp with single digit hour, minute, second, millisecond', () {
        // Arrange
        final dateTime = DateTime(2023, 12, 25, 9, 5, 3, 7);
        
        // Act
        final result = dateTime.timeStamp();
        
        // Assert
        expect(result, equals('09:05:03.007'));
      });

      test('should format timestamp with double digit hour, minute, second', () {
        // Arrange
        final dateTime = DateTime(2023, 12, 25, 14, 23, 45, 123);
        
        // Act
        final result = dateTime.timeStamp();
        
        // Assert
        expect(result, equals('14:23:45.123'));
      });

      test('should format midnight timestamp correctly', () {
        // Arrange
        final dateTime = DateTime(2023, 12, 25, 0, 0, 0, 0);
        
        // Act
        final result = dateTime.timeStamp();
        
        // Assert
        expect(result, equals('00:00:00.000'));
      });

      test('should format end of day timestamp correctly', () {
        // Arrange
        final dateTime = DateTime(2023, 12, 25, 23, 59, 59, 999);
        
        // Act
        final result = dateTime.timeStamp();
        
        // Assert
        expect(result, equals('23:59:59.999'));
      });

      test('should pad single digit milliseconds with two leading zeros', () {
        // Arrange
        final dateTime = DateTime(2023, 12, 25, 12, 30, 45, 5);
        
        // Act
        final result = dateTime.timeStamp();
        
        // Assert
        expect(result, equals('12:30:45.005'));
      });

      test('should pad double digit milliseconds with one leading zero', () {
        // Arrange
        final dateTime = DateTime(2023, 12, 25, 12, 30, 45, 67);
        
        // Act
        final result = dateTime.timeStamp();
        
        // Assert
        expect(result, equals('12:30:45.067'));
      });

      test('should not pad triple digit milliseconds', () {
        // Arrange
        final dateTime = DateTime(2023, 12, 25, 12, 30, 45, 567);
        
        // Act
        final result = dateTime.timeStamp();
        
        // Assert
        expect(result, equals('12:30:45.567'));
      });

      test('should handle various hour ranges correctly', () {
        // Arrange & Act & Assert
        expect(DateTime(2023, 1, 1, 1, 0, 0, 0).timeStamp(), equals('01:00:00.000'));
        expect(DateTime(2023, 1, 1, 12, 0, 0, 0).timeStamp(), equals('12:00:00.000'));
        expect(DateTime(2023, 1, 1, 22, 0, 0, 0).timeStamp(), equals('22:00:00.000'));
      });

      test('should handle various minute ranges correctly', () {
        // Arrange & Act & Assert
        expect(DateTime(2023, 1, 1, 12, 1, 0, 0).timeStamp(), equals('12:01:00.000'));
        expect(DateTime(2023, 1, 1, 12, 30, 0, 0).timeStamp(), equals('12:30:00.000'));
        expect(DateTime(2023, 1, 1, 12, 59, 0, 0).timeStamp(), equals('12:59:00.000'));
      });

      test('should handle various second ranges correctly', () {
        // Arrange & Act & Assert
        expect(DateTime(2023, 1, 1, 12, 30, 1, 0).timeStamp(), equals('12:30:01.000'));
        expect(DateTime(2023, 1, 1, 12, 30, 30, 0).timeStamp(), equals('12:30:30.000'));
        expect(DateTime(2023, 1, 1, 12, 30, 59, 0).timeStamp(), equals('12:30:59.000'));
      });

      test('should maintain format consistency across different times', () {
        // Arrange
        final morningTime = DateTime(2023, 12, 25, 8, 15, 30, 250);
        final afternoonTime = DateTime(2023, 12, 25, 16, 45, 12, 89);
        final eveningTime = DateTime(2023, 12, 25, 21, 5, 8, 4);
        
        // Act
        final morningResult = morningTime.timeStamp();
        final afternoonResult = afternoonTime.timeStamp();
        final eveningResult = eveningTime.timeStamp();
        
        // Assert
        expect(morningResult, equals('08:15:30.250'));
        expect(afternoonResult, equals('16:45:12.089'));
        expect(eveningResult, equals('21:05:08.004'));
        
        // Verify format structure
        expect(morningResult.length, equals(12));
        expect(afternoonResult.length, equals(12));
        expect(eveningResult.length, equals(12));
        
        // Verify separators are in correct positions
        expect(morningResult[2], equals(':'));
        expect(morningResult[5], equals(':'));
        expect(morningResult[8], equals('.'));
      });

      test('should handle microseconds correctly by using only millisecond portion', () {
        // Arrange - DateTime with microseconds (123456 microseconds = 123 milliseconds + 456 microseconds)
        final dateTime = DateTime.fromMicrosecondsSinceEpoch(
          DateTime(2023, 12, 25, 12, 30, 45).microsecondsSinceEpoch + 123456
        );
        
        // Act
        final result = dateTime.timeStamp();
        
        // Assert
        expect(result, equals('12:30:45.123')); // Only millisecond portion (123)
      });
    });
  });
}
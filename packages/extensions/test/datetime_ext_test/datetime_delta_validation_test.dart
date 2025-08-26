// test_datetime_delta_validation.dart
// ignore_for_file: avoid_print

import 'package:extensions/datetime_ext/datetime_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeDelta Validation Tests', () {
    // ✅ Valid UTC dates for positive test cases
    late DateTime validUtcStart;
    late DateTime validUtcEnd;

    setUp(() {
      validUtcStart = DateTime(2023, 1, 1).toUtc();
      validUtcEnd = DateTime(2023, 6, 15).toUtc();
    });

    group('UTC Validation', () {
      test('should throw ArgumentError when startTime is not UTC', () {
        // Arrange
        final nonUtcStartTime = DateTime.now(); // Local timezone
        final utcEndTime = DateTime.now().toUtc();

        // Act & Assert
        expect(
          () => DateTimeDelta.delta(
            startTime: nonUtcStartTime,
            endTime: utcEndTime,
          ),
          throwsA(
            isA<ArgumentError>()
                .having(
                  (e) => e.message,
                  'message',
                  contains('startTime must be UTC'),
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('Use startTime.toUtc()'),
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('Current timezone offset:'),
                ),
          ),
        );
      });

      test('should throw ArgumentError when endTime is not UTC', () {
        // Arrange
        final utcStartTime = DateTime.now().toUtc();
        final nonUtcEndTime = DateTime.now(); // Local timezone

        // Act & Assert
        expect(
          () => DateTimeDelta.delta(
            startTime: utcStartTime,
            endTime: nonUtcEndTime,
          ),
          throwsA(
            isA<ArgumentError>()
                .having(
                  (e) => e.message,
                  'message',
                  contains('endTime must be UTC'),
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('Use endTime.toUtc()'),
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('Current timezone offset:'),
                ),
          ),
        );
      });

      test('should throw ArgumentError when both times are not UTC', () {
        // Arrange
        final nonUtcStartTime = DateTime(2023, 1, 1, 10, 30); // Local
        final nonUtcEndTime = DateTime(2023, 6, 15, 14, 45); // Local

        // Act & Assert - Should fail on startTime first
        expect(
          () => DateTimeDelta.delta(
            startTime: nonUtcStartTime,
            endTime: nonUtcEndTime,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('startTime must be UTC'),
            ),
          ),
        );
      });

      test('should NOT throw when both times are properly UTC', () {
        // Arrange & Act
        expect(
          () => DateTimeDelta.delta(
            startTime: validUtcStart,
            endTime: validUtcEnd,
          ),
          returnsNormally,
        );
      });

      test('should NOT throw when endTime defaults to UTC now', () {
        // Arrange & Act - endTime should default to DateTime.now().toUtc()
        expect(
          () => DateTimeDelta.delta(
            startTime: validUtcStart,
            // endTime omitted - should default to UTC
          ),
          returnsNormally,
        );
      });
    });

    group('Parameter Validation', () {
      test(
        'should throw ArgumentError when firstDateTimeUnit smaller than precision',
        () {
          // Arrange - precision is larger unit (higher in hierarchy) than firstDateTimeUnit

          // Act & Assert
          expect(
            () => DateTimeDelta.delta(
              startTime: validUtcStart,
              endTime: validUtcEnd,
              firstDateTimeUnit: DateTimeUnit.day, // Smaller unit
              precision: DateTimeUnit.month, // Larger unit - invalid!
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains(
                  'firstDateTimeUnit (DateTimeUnit.day) cannot be smaller than precision (DateTimeUnit.month)',
                ),
              ),
            ),
          );
        },
      );

      test('should NOT throw when firstDateTimeUnit equals precision', () {
        // Arrange & Act
        expect(
          () => DateTimeDelta.delta(
            startTime: validUtcStart,
            endTime: validUtcEnd,
            firstDateTimeUnit: DateTimeUnit.day,
            precision: DateTimeUnit.day, // Same unit - valid
          ),
          returnsNormally,
        );
      });

      test('should NOT throw when firstDateTimeUnit larger than precision', () {
        // Arrange & Act
        expect(
          () => DateTimeDelta.delta(
            startTime: validUtcStart,
            endTime: validUtcEnd,
            firstDateTimeUnit: DateTimeUnit.year, // Larger unit
            precision: DateTimeUnit.day, // Smaller unit - valid
          ),
          returnsNormally,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle identical UTC times without error', () {
        // Arrange
        final sameTime = DateTime(2023, 6, 15, 12, 30, 45).toUtc();

        // Act
        final delta = DateTimeDelta.delta(
          startTime: sameTime,
          endTime: sameTime,
        );

        // Assert
        expect(delta.toString(), equals('0'));
      });

      test('should handle extreme date ranges', () {
        // Arrange
        final veryOldDate = DateTime(1900, 1, 1).toUtc();
        final futureDate = DateTime(2100, 12, 31).toUtc();

        // Act & Assert - Should not throw
        expect(
          () =>
              DateTimeDelta.delta(startTime: veryOldDate, endTime: futureDate),
          returnsNormally,
        );
      });

      test('should handle reversed time order (end before start)', () {
        // Arrange
        final laterTime = DateTime(2023, 12, 31).toUtc();
        final earlierTime = DateTime(2023, 1, 1).toUtc();

        // Act
        final delta = DateTimeDelta.delta(
          startTime: laterTime, // Later time as start
          endTime: earlierTime, // Earlier time as end
        );

        // Assert - Should indicate past direction
        expect(delta.isFuture, isFalse);
        expect(delta.toString(), startsWith('-'));
      });
    });

    group('Real-World Scenarios', () {
      test('should fail gracefully with common timezone mistakes', () {
        // Arrange - Common mistake: using DateTime.now() directly
        final nowLocal = DateTime.now();
        final startUtc = DateTime(2023, 1, 1).toUtc();

        // Act & Assert
        expect(
          () => DateTimeDelta.delta(
            startTime: startUtc,
            endTime: nowLocal, // ❌ Common mistake
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('endTime must be UTC'),
            ),
          ),
        );
      });

      test('should provide helpful timezone offset information', () {
        // Arrange
        final localTime = DateTime(2023, 6, 15, 14, 30); // Has timezone offset
        final utcTime = DateTime.now().toUtc();

        // Act & Assert
        try {
          DateTimeDelta.delta(startTime: localTime, endTime: utcTime);
          fail('Expected ArgumentError');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('Current timezone offset:'));
          expect(e.toString(), contains('Use startTime.toUtc()'));
        }
      });
    });
  });
}

// Helper function for debugging test failures
void debugTimezoneInfo(DateTime dateTime) {
  print('DateTime: $dateTime');
  print('Is UTC: ${dateTime.isUtc}');
  print('Timezone offset: ${dateTime.timeZoneOffset}');
  print('UTC equivalent: ${dateTime.toUtc()}');
}

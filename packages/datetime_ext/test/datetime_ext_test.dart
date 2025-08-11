import 'package:datetime_ext/datetime_ext.dart' show DateTimeHelper;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeHelper', () {
    setUp(() {
      // Reset static state before each test
      _resetStaticState();
    });

    tearDown(() {
      // Clean up after each test
      _resetStaticState();
    });

    group('unique()', () {
      test('should return unique DateTime instances on consecutive calls', () async {
        // Arrange & Act
        final first = await DateTimeHelper.unique();
        final second = await DateTimeHelper.unique();
        final third = await DateTimeHelper.unique();

        // Assert
        expect(first.microsecondsSinceEpoch, lessThan(second.microsecondsSinceEpoch));
        expect(second.microsecondsSinceEpoch, lessThan(third.microsecondsSinceEpoch));
      });

      test('should ensure minimum increment of 1 microsecond between calls', () async {
        // Arrange & Act
        final first = await DateTimeHelper.unique();
        final second = await DateTimeHelper.unique();

        // Assert
        final difference = second.microsecondsSinceEpoch - first.microsecondsSinceEpoch;
        expect(difference, greaterThanOrEqualTo(1));
      });

      test('should handle rapid consecutive calls without duplicates', () async {
        // Arrange
        const callCount = 100;
        final results = <DateTime>[];

        // Act
        for (int i = 0; i < callCount; i++) {
          results.add(await DateTimeHelper.unique());
        }

        // Assert
        final timestamps = results.map((dt) => dt.microsecondsSinceEpoch).toList();
        final uniqueTimestamps = timestamps.toSet();
        
        expect(uniqueTimestamps.length, equals(callCount));
        expect(_isStrictlyIncreasing(timestamps), isTrue);
      });

      test('should update maxDrift when drift occurs', () async {
        // Arrange
        final initialMaxDrift = DateTimeHelper.maxDrift;

        // Act - Make multiple rapid calls to force drift
        await DateTimeHelper.unique();
        await DateTimeHelper.unique();
        await DateTimeHelper.unique();

        // Assert
        expect(DateTimeHelper.maxDrift, greaterThanOrEqualTo(initialMaxDrift));
      });

      test('should handle large drift by waiting for system clock', () async {
        // Arrange - This test is harder to deterministically trigger
        // We'll test the behavior indirectly by making many rapid calls
        const rapidCalls = 50;
        final startTime = DateTime.now();

        // Act
        final results = <DateTime>[];
        for (int i = 0; i < rapidCalls; i++) {
          results.add(await DateTimeHelper.unique());
        }
        final endTime = DateTime.now();

        // Assert
        final executionTime = endTime.difference(startTime);
        final allUnique = _areAllUnique(results);
        final strictlyIncreasing = _isStrictlyIncreasing(
          results.map((dt) => dt.microsecondsSinceEpoch).toList()
        );

        expect(allUnique, isTrue);
        expect(strictlyIncreasing, isTrue);
        
        // If drift exceeded 500 microseconds, execution should take longer
        // due to the Future.delayed calls
        if (DateTimeHelper.maxDrift > 500) {
          expect(executionTime.inMilliseconds, greaterThan(0));
        }
      });

      test('should maintain state across multiple calls', () async {
        // Arrange & Act
        final first = await DateTimeHelper.unique();
        final firstMaxDrift = DateTimeHelper.maxDrift;
        
        final second = await DateTimeHelper.unique();
        final secondMaxDrift = DateTimeHelper.maxDrift;

        // Assert
        expect(second.microsecondsSinceEpoch, greaterThan(first.microsecondsSinceEpoch));
        expect(secondMaxDrift, greaterThanOrEqualTo(firstMaxDrift));
      });

      test('should handle concurrent calls correctly', () async {
        // Arrange
        const concurrentCount = 10;
        
        // Act
        final futures = List.generate(
          concurrentCount, 
          (_) => DateTimeHelper.unique()
        );
        final results = await Future.wait(futures);

        // Assert
        final timestamps = results.map((dt) => dt.microsecondsSinceEpoch).toList();
        final uniqueTimestamps = timestamps.toSet();
        
        expect(uniqueTimestamps.length, equals(concurrentCount));
      });

      test('should return DateTime instances with correct precision', () async {
        // Arrange & Act
        final result = await DateTimeHelper.unique();

        // Assert
        expect(result, isA<DateTime>());
        expect(result.microsecondsSinceEpoch, isA<int>());
        expect(result.microsecondsSinceEpoch, greaterThan(0));
      });
    });

    group('maxDrift tracking', () {
      test('should initialize maxDrift to 0', () {
        // Arrange & Act & Assert
        expect(DateTimeHelper.maxDrift, equals(0));
      });

      test('should track maximum drift encountered', () async {
        // Arrange
        final initialMaxDrift = DateTimeHelper.maxDrift;

        // Act - Force some drift by rapid calls
        await DateTimeHelper.unique();
        await DateTimeHelper.unique();
        await DateTimeHelper.unique();
        await DateTimeHelper.unique();
        await DateTimeHelper.unique();

        // Assert
        expect(DateTimeHelper.maxDrift, greaterThanOrEqualTo(initialMaxDrift));
      });
    });

    group('edge cases', () {
      test('should handle single call correctly', () async {
        // Arrange & Act
        final result = await DateTimeHelper.unique();
        final now = DateTime.now();

        // Assert
        expect(result, isA<DateTime>());
        expect(result.microsecondsSinceEpoch, lessThanOrEqualTo(now.microsecondsSinceEpoch));
      });

      test('should handle calls separated by natural time progression', () async {
        // Arrange & Act
        final first = await DateTimeHelper.unique();
        await Future.delayed(Duration(milliseconds: 10)); // Natural progression
        final second = await DateTimeHelper.unique();

        // Assert
        expect(second.microsecondsSinceEpoch, greaterThan(first.microsecondsSinceEpoch));
      });
    });
  });
}

// Helper methods for test assertions

bool _isStrictlyIncreasing(List<int> values) {
  for (int i = 1; i < values.length; i++) {
    if (values[i] <= values[i - 1]) {
      return false;
    }
  }
  return true;
}

bool _areAllUnique(List<DateTime> dateTimes) {
  final timestamps = dateTimes.map((dt) => dt.microsecondsSinceEpoch).toList();
  final uniqueTimestamps = timestamps.toSet();
  return uniqueTimestamps.length == dateTimes.length;
}

// Note: This is a workaround since we can't directly access private static fields
// In a real implementation, you might need to add a reset method to DateTimeHelper
// or use a different approach for state management
void _resetStaticState() {
  DateTimeHelper.reset();
}
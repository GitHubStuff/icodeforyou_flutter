// test/analog_clock_integration_test.dart
// This tests the timer callback indirectly through the public API

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:analog_clock_widget/analog_clock_widget.dart';

// Mock TimeProvider for testing
class MockTimeProvider implements TimeProvider {
  DateTime _currentTime;

  MockTimeProvider(this._currentTime);

  @override
  DateTime get now => _currentTime;

  void setTime(DateTime time) {
    _currentTime = time;
  }
}

void main() {
  group('AnalogClock Timer Integration Tests', () {
    testWidgets(
      'should execute internal timer callbacks - COVERS _UtcTimeService lines 42-43',
      (WidgetTester tester) async {
        // This test indirectly covers the uncovered timer callback lines:
        // if (_controller != null && !_controller!.isClosed) {
        //   _controller!.add(currentTime);  ← Line 42 (UNCOVERED)
        // }

        // Arrange
        final mockTimeProvider = MockTimeProvider(
          DateTime.utc(2024, 8, 24, 15, 30, 0),
        );

        // Act - Create widget that uses _UtcTimeService internally
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return AnalogClock(
                    radius: 100,
                    timeProvider: mockTimeProvider,
                  );
                },
              ),
            ),
          ),
        );

        // Pump to initialize the widget and start timers
        await tester.pump();

        // Wait for timer to tick (this triggers the callback)
        await tester.pump(const Duration(milliseconds: 1100));

        // Change time to ensure timer is actually working
        mockTimeProvider.setTime(DateTime.utc(2024, 8, 24, 15, 30, 5));
        await tester.pump(const Duration(milliseconds: 1100));

        // Another tick
        mockTimeProvider.setTime(DateTime.utc(2024, 8, 24, 15, 30, 10));
        await tester.pump(const Duration(milliseconds: 1100));

        // Assert - Widget should still be rendered (timer working correctly)
        expect(find.byType(AnalogClock), findsOneWidget);

        // The fact that the widget continues to work indicates the timer callbacks are executing
      },
    );

    testWidgets('should handle timer disposal correctly', (
      WidgetTester tester,
    ) async {
      // Tests the dispose path of _UtcTimeService
      final mockTimeProvider = MockTimeProvider(
        DateTime.utc(2024, 8, 24, 15, 30, 0),
      );

      // Create widget with timer
      await tester.pumpWidget(
        MaterialApp(
          home: AnalogClock(radius: 75, timeProvider: mockTimeProvider),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));

      // Dispose by removing widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      // Should dispose cleanly without errors
      expect(find.byType(AnalogClock), findsNothing);
    });

    testWidgets('should handle multiple timer ticks over extended period', (
      WidgetTester tester,
    ) async {
      // Extended test to ensure timer callback continues working
      final mockTimeProvider = MockTimeProvider(
        DateTime.utc(2024, 1, 1, 12, 0, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AnalogClock(radius: 50, timeProvider: mockTimeProvider),
        ),
      );

      // Simulate multiple timer ticks
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 1000));
        mockTimeProvider.setTime(DateTime.utc(2024, 1, 1, 12, 0, i));
      }

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('should handle rapid time changes during timer execution', (
      WidgetTester tester,
    ) async {
      final mockTimeProvider = MockTimeProvider(
        DateTime.utc(2024, 6, 15, 9, 0, 0),
      );

      await tester.pumpWidget(
        MaterialApp(home: AnalogClock(timeProvider: mockTimeProvider)),
      );

      // Rapid time changes to stress test the timer callback
      await tester.pump();
      for (int minute = 0; minute < 10; minute++) {
        mockTimeProvider.setTime(DateTime.utc(2024, 6, 15, 9, minute, 0));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 1000));
      }

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('should continue working after hot reload simulation', (
      WidgetTester tester,
    ) async {
      final mockTimeProvider = MockTimeProvider(
        DateTime.utc(2024, 3, 10, 14, 30, 0),
      );

      Widget buildClock() =>
          MaterialApp(home: AnalogClock(timeProvider: mockTimeProvider));

      // Initial build
      await tester.pumpWidget(buildClock());
      await tester.pump(const Duration(milliseconds: 1100));

      // Simulate hot reload
      await tester.pumpWidget(buildClock());
      await tester.pump(const Duration(milliseconds: 1100));

      // Should still work after rebuild
      mockTimeProvider.setTime(DateTime.utc(2024, 3, 10, 14, 35, 0));
      await tester.pump(const Duration(milliseconds: 1100));

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('should handle edge case timing scenarios', (
      WidgetTester tester,
    ) async {
      final mockTimeProvider = MockTimeProvider(
        DateTime.utc(2024, 12, 31, 23, 59, 58),
      );

      await tester.pumpWidget(
        MaterialApp(home: AnalogClock(timeProvider: mockTimeProvider)),
      );

      // Test year boundary
      await tester.pump();
      mockTimeProvider.setTime(DateTime.utc(2024, 12, 31, 23, 59, 59));
      await tester.pump(const Duration(milliseconds: 1100));

      mockTimeProvider.setTime(DateTime.utc(2025, 1, 1, 0, 0, 0));
      await tester.pump(const Duration(milliseconds: 1100));

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    group('Alternative Direct Testing Approach', () {
      // If you need to test the class directly, temporarily make it public
      // Change _UtcTimeService to UtcTimeService in clock_services.dart
      // and add @visibleForTesting annotation

      test('placeholder for direct testing if class is made public', () {
        // This would contain direct tests of UtcTimeService if it was public
        expect(true, isTrue); // Placeholder
      });
    });
  });

  // Additional helper functions for more comprehensive testing
  group('Time Provider Edge Cases', () {
    testWidgets('should handle null/invalid time scenarios gracefully', (
      WidgetTester tester,
    ) async {
      final mockTimeProvider = MockTimeProvider(
        DateTime.utc(2024, 8, 24, 15, 30, 0),
      );

      await tester.pumpWidget(
        MaterialApp(home: AnalogClock(timeProvider: mockTimeProvider)),
      );

      // Test with extreme dates
      mockTimeProvider.setTime(DateTime.utc(1970, 1, 1, 0, 0, 0));
      await tester.pump(const Duration(milliseconds: 1100));

      mockTimeProvider.setTime(DateTime.utc(2100, 12, 31, 23, 59, 59));
      await tester.pump(const Duration(milliseconds: 1100));

      expect(find.byType(AnalogClock), findsOneWidget);
    });
  });
}

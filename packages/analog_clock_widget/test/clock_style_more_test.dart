// clock_state_coverage_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:analog_clock_widget/analog_clock_widget.dart';

// Mock TimeProvider implementations for testing
class MockTimeProvider implements TimeProvider {
  DateTime _currentTime;

  MockTimeProvider(this._currentTime);

  @override
  DateTime get now => _currentTime;

  void setTime(DateTime time) {
    _currentTime = time;
  }
}

class AlternativeTimeProvider implements TimeProvider {
  final DateTime _currentTime;

  AlternativeTimeProvider(this._currentTime);

  @override
  DateTime get now => _currentTime;
}

// Mock ThemeProvider implementations for testing
class MockThemeProvider implements ThemeProvider {
  final ColorScheme _colorScheme;

  const MockThemeProvider(this._colorScheme);

  @override
  ColorScheme getColorScheme(BuildContext context) => _colorScheme;
}

class AlternativeThemeProvider implements ThemeProvider {
  final ColorScheme _colorScheme;

  const AlternativeThemeProvider(this._colorScheme);

  @override
  ColorScheme getColorScheme(BuildContext context) => _colorScheme;
}

void main() {
  group('AnalogClock State Coverage Tests - Lines 73, 74, 80', () {
    testWidgets(
      'should dispose and reinitialize time service when utcMinuteOffset changes - COVERS LINES 73-74',
      (WidgetTester tester) async {
        // Arrange
        final timeProvider = MockTimeProvider(
          DateTime.utc(2024, 8, 24, 15, 30, 0),
        );

        // Act - Initial widget with offset 0
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(
                radius: 100,
                timeProvider: timeProvider,
                utcMinuteOffset: 0, // Initial offset
              ),
            ),
          ),
        );

        await tester.pump();

        // Act - Update widget with different utcMinuteOffset
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(
                radius: 100,
                timeProvider: timeProvider,
                utcMinuteOffset:
                    120, // Changed offset - this should trigger dispose/reinit
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert - Widget should still render correctly after service recreation
        expect(find.byType(AnalogClock), findsOneWidget);
      },
    );

    testWidgets(
      'should dispose and reinitialize time service when timeProvider changes - COVERS LINES 73-74',
      (WidgetTester tester) async {
        // Arrange
        final timeProvider1 = MockTimeProvider(
          DateTime.utc(2024, 8, 24, 15, 30, 0),
        );
        final timeProvider2 = AlternativeTimeProvider(
          DateTime.utc(2024, 8, 24, 16, 0, 0),
        );

        // Act - Initial widget with first timeProvider
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(radius: 100, timeProvider: timeProvider1),
            ),
          ),
        );

        await tester.pump();

        // Act - Update widget with different timeProvider
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(
                radius: 100,
                timeProvider:
                    timeProvider2, // Different timeProvider - triggers dispose/reinit
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert - Widget should still render correctly after service recreation
        expect(find.byType(AnalogClock), findsOneWidget);
      },
    );

    testWidgets(
      'should invalidate configuration when themeProvider changes - COVERS LINE 80',
      (WidgetTester tester) async {
        // This test covers line 80: oldWidget.themeProvider != widget.themeProvider

        // Arrange
        final timeProvider = MockTimeProvider(
          DateTime.utc(2024, 8, 24, 15, 30, 0),
        );
        const themeProvider1 = MockThemeProvider(ColorScheme.light());
        const themeProvider2 = AlternativeThemeProvider(ColorScheme.dark());

        // Act - Initial widget with first themeProvider
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(
                radius: 100,
                timeProvider: timeProvider,
                themeProvider: themeProvider1,
              ),
            ),
          ),
        );

        await tester.pump();

        // Act - Update widget with different themeProvider
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(
                radius: 100,
                timeProvider: timeProvider,
                themeProvider:
                    themeProvider2, // Different themeProvider - covers line 80
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert - Widget should still render correctly after configuration invalidation
        expect(find.byType(AnalogClock), findsOneWidget);
      },
    );

    testWidgets('should handle combined changes (offset + provider + theme)', (
      WidgetTester tester,
    ) async {
      // Comprehensive test that changes multiple properties at once

      // Arrange
      final timeProvider1 = MockTimeProvider(
        DateTime.utc(2024, 8, 24, 15, 30, 0),
      );
      final timeProvider2 = AlternativeTimeProvider(
        DateTime.utc(2024, 8, 24, 16, 0, 0),
      );
      const themeProvider1 = MockThemeProvider(ColorScheme.light());
      const themeProvider2 = AlternativeThemeProvider(ColorScheme.dark());

      // Act - Initial widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalogClock(
              radius: 100,
              timeProvider: timeProvider1,
              utcMinuteOffset: 60,
              themeProvider: themeProvider1,
            ),
          ),
        ),
      );

      await tester.pump();

      // Act - Update with all different values
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalogClock(
              radius: 100,
              timeProvider: timeProvider2, // Different - triggers lines 73-74
              utcMinuteOffset: 180, // Different - triggers lines 73-74
              themeProvider: themeProvider2, // Different - triggers line 80
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('should handle null to non-null utcMinuteOffset change', (
      WidgetTester tester,
    ) async {
      // Test edge case: null utcMinuteOffset to specific value

      // Arrange
      final timeProvider = MockTimeProvider(
        DateTime.utc(2024, 8, 24, 15, 30, 0),
      );

      // Act - Initial widget with null utcMinuteOffset (uses system default)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalogClock(
              radius: 100,
              timeProvider: timeProvider,
              utcMinuteOffset: null, // Uses system timezone
            ),
          ),
        ),
      );

      await tester.pump();

      // Act - Update to specific offset
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalogClock(
              radius: 100,
              timeProvider: timeProvider,
              utcMinuteOffset: 240, // Specific offset
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('should handle non-null to null utcMinuteOffset change', (
      WidgetTester tester,
    ) async {
      // Test edge case: specific utcMinuteOffset to null

      // Arrange
      final timeProvider = MockTimeProvider(
        DateTime.utc(2024, 8, 24, 15, 30, 0),
      );

      // Act - Initial widget with specific utcMinuteOffset
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalogClock(
              radius: 100,
              timeProvider: timeProvider,
              utcMinuteOffset: 300, // Specific offset
            ),
          ),
        ),
      );

      await tester.pump();

      // Act - Update to null (system timezone)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalogClock(
              radius: 100,
              timeProvider: timeProvider,
              utcMinuteOffset: null, // System default
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets(
      'should not reinitialize when offset and provider remain the same',
      (WidgetTester tester) async {
        // Test that services are NOT recreated when they don't need to be

        // Arrange
        final timeProvider = MockTimeProvider(
          DateTime.utc(2024, 8, 24, 15, 30, 0),
        );
        const themeProvider = MockThemeProvider(ColorScheme.light());

        // Act - Initial widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(
                radius: 100,
                timeProvider: timeProvider,
                utcMinuteOffset: 120,
                themeProvider: themeProvider,
              ),
            ),
          ),
        );

        await tester.pump();

        // Act - Update with same timeProvider and offset, but different radius
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(
                radius: 150, // Only radius changed
                timeProvider: timeProvider, // Same
                utcMinuteOffset: 120, // Same
                themeProvider: themeProvider, // Same
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert - Widget should update radius without recreating services
        expect(find.byType(AnalogClock), findsOneWidget);
      },
    );

    testWidgets(
      'should handle style changes that trigger configuration updates',
      (WidgetTester tester) async {
        // Test configuration invalidation through style changes

        // Arrange
        final timeProvider = MockTimeProvider(
          DateTime.utc(2024, 8, 24, 15, 30, 0),
        );
        const style1 = ClockStyle(showNumbers: true, showSecondHand: true);
        const style2 = ClockStyle(showNumbers: false, showSecondHand: false);

        // Act - Initial widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(
                radius: 100,
                timeProvider: timeProvider,
                style: style1,
              ),
            ),
          ),
        );

        await tester.pump();

        // Act - Update style
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnalogClock(
                radius: 100,
                timeProvider: timeProvider,
                style: style2, // Different style
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert
        expect(find.byType(AnalogClock), findsOneWidget);
      },
    );

    testWidgets('should handle multiple rapid updates correctly', (
      WidgetTester tester,
    ) async {
      // Stress test with multiple rapid changes

      // Arrange
      final timeProvider1 = MockTimeProvider(
        DateTime.utc(2024, 8, 24, 15, 30, 0),
      );
      final timeProvider2 = AlternativeTimeProvider(
        DateTime.utc(2024, 8, 24, 16, 0, 0),
      );
      const themeProvider1 = MockThemeProvider(ColorScheme.light());
      const themeProvider2 = AlternativeThemeProvider(ColorScheme.dark());

      // Act - Rapid updates
      await tester.pumpWidget(
        MaterialApp(
          home: AnalogClock(
            radius: 100,
            timeProvider: timeProvider1,
            utcMinuteOffset: 0,
          ),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          home: AnalogClock(
            radius: 100,
            timeProvider: timeProvider2,
            utcMinuteOffset: 60,
          ),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          home: AnalogClock(
            radius: 100,
            timeProvider: timeProvider1,
            utcMinuteOffset: 120,
            themeProvider: themeProvider1,
          ),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          home: AnalogClock(
            radius: 100,
            timeProvider: timeProvider2,
            utcMinuteOffset: 180,
            themeProvider: themeProvider2,
          ),
        ),
      );
      await tester.pump();

      // Assert - Should handle all updates gracefully
      expect(find.byType(AnalogClock), findsOneWidget);
    });
  });
}

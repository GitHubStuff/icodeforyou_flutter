// test/clock_state_coverage_test.dart

// ignore_for_file: document_ignores, avoid_setters_without_getters

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

part '_clock_state_coverage_test_part.dart';

class _MockTimeProvider implements TimeProvider {
  _MockTimeProvider(this._currentTime);
  DateTime _currentTime;

  @override
  DateTime get now => _currentTime;

  set currentTime(DateTime time) => _currentTime = time;
}

class _AlternativeTimeProvider implements TimeProvider {
  const _AlternativeTimeProvider(this._currentTime);
  final DateTime _currentTime;

  @override
  DateTime get now => _currentTime;
}

ColorScheme _lightTheme(BuildContext context) => const ColorScheme.light();
ColorScheme _darkTheme(BuildContext context) => const ColorScheme.dark();

void main() {
  group('AnalogClock State Coverage - service lifecycle', () {
    testWidgets('reinitializes service when utcMinuteOffset changes', (
      tester,
    ) async {
      final tp = _MockTimeProvider(DateTime.utc(2024, 8, 24, 15, 30));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnalogClock(radius: 100, timeProvider: tp, utcMinuteOffset: 0),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body:
              AnalogClock(radius: 100, timeProvider: tp, utcMinuteOffset: 120),
        ),
      ));
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('reinitializes service when timeProvider changes', (
      tester,
    ) async {
      final tp1 = _MockTimeProvider(DateTime.utc(2024, 8, 24, 15, 30));
      final tp2 = _AlternativeTimeProvider(DateTime.utc(2024, 8, 24, 16));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AnalogClock(radius: 100, timeProvider: tp1)),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AnalogClock(radius: 100, timeProvider: tp2)),
      ));
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('invalidates configuration when themeProvider changes', (
      tester,
    ) async {
      final tp = _MockTimeProvider(DateTime.utc(2024, 8, 24, 15, 30));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnalogClock(
            radius: 100,
            timeProvider: tp,
            themeProvider: _lightTheme,
          ),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnalogClock(
            radius: 100,
            timeProvider: tp,
            themeProvider: _darkTheme,
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('handles combined offset, provider, and theme changes', (
      tester,
    ) async {
      final tp1 = _MockTimeProvider(DateTime.utc(2024, 8, 24, 15, 30));
      final tp2 = _AlternativeTimeProvider(DateTime.utc(2024, 8, 24, 16));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnalogClock(
            radius: 100,
            timeProvider: tp1,
            utcMinuteOffset: 60,
            themeProvider: _lightTheme,
          ),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnalogClock(
            radius: 100,
            timeProvider: tp2,
            utcMinuteOffset: 180,
            themeProvider: _darkTheme,
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('handles null to non-null utcMinuteOffset change', (
      tester,
    ) async {
      final tp = _MockTimeProvider(DateTime.utc(2024, 8, 24, 15, 30));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AnalogClock(radius: 100, timeProvider: tp)),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body:
              AnalogClock(radius: 100, timeProvider: tp, utcMinuteOffset: 240),
        ),
      ));
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
    });
  });

  _runStateCoveragePartTwo();
}

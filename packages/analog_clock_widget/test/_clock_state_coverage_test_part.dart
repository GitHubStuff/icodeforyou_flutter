// test/_clock_state_coverage_test_part.dart

part of 'clock_state_coverage_test.dart';

void _runStateCoveragePartTwo() {
  group('AnalogClock State Coverage - configuration updates', () {
    testWidgets('handles non-null to null utcMinuteOffset change', (
      tester,
    ) async {
      final tp = _MockTimeProvider(DateTime.utc(2024, 8, 24, 15, 30));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body:
              AnalogClock(radius: 100, timeProvider: tp, utcMinuteOffset: 300),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AnalogClock(radius: 100, timeProvider: tp)),
      ));
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('does not reinitialize when only radius changes', (
      tester,
    ) async {
      final tp = _MockTimeProvider(DateTime.utc(2024, 8, 24, 15, 30));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnalogClock(
            radius: 100,
            timeProvider: tp,
            utcMinuteOffset: 120,
            themeProvider: _lightTheme,
          ),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnalogClock(
            radius: 150,
            timeProvider: tp,
            utcMinuteOffset: 120,
            themeProvider: _lightTheme,
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('handles style change that triggers configuration update', (
      tester,
    ) async {
      final tp = _MockTimeProvider(DateTime.utc(2024, 8, 24, 15, 30));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AnalogClock(radius: 100, timeProvider: tp)),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnalogClock(
            radius: 100,
            timeProvider: tp,
            style: const ClockStyle(
              showNumbers: false,
              showSecondHand: false,
            ),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('handles multiple rapid widget updates', (tester) async {
      final tp1 = _MockTimeProvider(DateTime.utc(2024, 8, 24, 15, 30));
      final tp2 = _AlternativeTimeProvider(DateTime.utc(2024, 8, 24, 16));

      await tester.pumpWidget(MaterialApp(
        home: AnalogClock(radius: 100, timeProvider: tp1, utcMinuteOffset: 0),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: AnalogClock(radius: 100, timeProvider: tp2, utcMinuteOffset: 60),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: AnalogClock(
          radius: 100,
          timeProvider: tp1,
          utcMinuteOffset: 120,
          themeProvider: _lightTheme,
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: AnalogClock(
          radius: 100,
          timeProvider: tp2,
          utcMinuteOffset: 180,
          themeProvider: _darkTheme,
        ),
      ));
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
    });
  });
}

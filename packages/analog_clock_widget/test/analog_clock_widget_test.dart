// analog_clock_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the widget - adjust path as needed
import 'package:analog_clock_widget/analog_clock_widget.dart';

void main() {
  group('AnalogClock Widget Tests', () {
    test('can create AnalogClock instance', () {
      expect(() => AnalogClock(), returnsNormally);
    });

    test('radius assertion works correctly', () {
      expect(() => AnalogClock(radius: 30), returnsNormally);
      expect(() => AnalogClock(radius: 29.9), throwsA(isA<ArgumentError>()));
      expect(() => AnalogClock(radius: 1000), returnsNormally);
    });

    testWidgets('throws assertion error for radius below minimum', (
      WidgetTester tester,
    ) async {
      expect(() => AnalogClock(radius: 20), throwsA(isA<ArgumentError>()));
    });

    testWidgets('renders without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: AnalogClock())));

      // Let the widget settle
      await tester.pump();

      // Dispose the widget properly
      await tester.pumpWidget(Container());
      await tester.pump();
    });

    testWidgets('finds AnalogClock widget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: AnalogClock())));

      expect(find.byType(AnalogClock), findsOneWidget);
    });
  });
}

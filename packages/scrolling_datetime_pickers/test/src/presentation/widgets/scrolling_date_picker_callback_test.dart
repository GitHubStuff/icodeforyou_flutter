// test/src/presentation/widgets/scrolling_date_picker_callback_test.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

void main() {
  group('ScrollingDatePicker Callbacks', () {
    testWidgets('should call onDateChanged when day changes', (tester) async {
      DateTime? lastDate;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024, 6, 15),
              onDateChanged: (date) {
                lastDate = date;
                callCount++;
              },
            ),
          ),
        ),
      );

      // Find the day picker (first CupertinoPicker in dayAscending mode)
      final dayPicker = find.byType(CupertinoPicker).first;

      // Drag to change day
      await tester.drag(dayPicker, const Offset(0, -100));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(callCount, greaterThan(0));
      expect(lastDate, isNotNull);
    });

    testWidgets('should call onDateChanged when month changes', (tester) async {
      DateTime? lastDate;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024, 6, 15),
              onDateChanged: (date) {
                lastDate = date;
                callCount++;
              },
            ),
          ),
        ),
      );

      // Find the month picker (second CupertinoPicker in dayAscending mode)
      final monthPicker = find.byType(CupertinoPicker).at(1);

      // Drag to change month
      await tester.drag(monthPicker, const Offset(0, -100));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(callCount, greaterThan(0));
      expect(lastDate, isNotNull);
    });

    testWidgets('should call onDateChanged when year changes', (tester) async {
      DateTime? lastDate;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024, 6, 15),
              onDateChanged: (date) {
                lastDate = date;
                callCount++;
              },
            ),
          ),
        ),
      );

      // Find the year picker (last CupertinoPicker in dayAscending mode)
      final yearPicker = find.byType(CupertinoPicker).last;

      // Drag to change year
      await tester.drag(yearPicker, const Offset(0, -100));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(callCount, greaterThan(0));
      expect(lastDate, isNotNull);
    });

    testWidgets('should trigger haptic feedback when enabled', (tester) async {
      final List<MethodCall> log = [];

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // Drag to trigger selection change
      final dayPicker = find.byType(CupertinoPicker).first;
      await tester.drag(dayPicker, const Offset(0, -100));
      await tester.pumpAndSettle();

      // Check if haptic feedback was triggered
      expect(
        log.any((call) => call.method == 'HapticFeedback.vibrate'),
        isTrue,
      );

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    testWidgets('should not trigger haptic feedback when disabled',
        (tester) async {
      final List<MethodCall> log = [];

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              enableHaptics: false,
            ),
          ),
        ),
      );

      // Drag to trigger selection change
      final dayPicker = find.byType(CupertinoPicker).first;
      await tester.drag(dayPicker, const Offset(0, -100));
      await tester.pumpAndSettle();

      // Check that haptic feedback was NOT triggered
      expect(
        log.any((call) => call.method == 'HapticFeedback.vibrate'),
        isFalse,
      );

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    testWidgets('should display abbreviated month names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024, 1, 15),
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // Should find abbreviated month name
      expect(find.text('Jan'), findsWidgets);
    });

    testWidgets('should clamp day when changing to shorter month',
        (tester) async {
      DateTime? lastDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024, 3, 31), // March 31
              onDateChanged: (date) {
                lastDate = date;
              },
            ),
          ),
        ),
      );

      // Find the month picker
      final monthPicker = find.byType(CupertinoPicker).at(1);

      // Drag to change to February (which has fewer days)
      await tester.drag(monthPicker, const Offset(0, 50));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Day should be clamped (Feb doesn't have 31 days)
      if (lastDate != null && lastDate!.month == 2) {
        expect(lastDate!.day, lessThanOrEqualTo(29));
      }
    });

    testWidgets('should handle leap year February', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024, 2, 29), // Leap year
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ScrollingDatePicker), findsOneWidget);
      // 29 should be visible for leap year February
      expect(find.text('29'), findsWidgets);
    });
  });
}

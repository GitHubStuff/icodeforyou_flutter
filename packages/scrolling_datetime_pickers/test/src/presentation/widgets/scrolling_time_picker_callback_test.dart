// test/src/presentation/widgets/scrolling_time_picker_callback_test.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

void main() {
  group('ScrollingTimePicker Callbacks', () {
    testWidgets('should call onDateTimeChanged when hour changes',
        (tester) async {
      DateTime? lastDateTime;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              initialDateTime: DateTime(2024, 1, 1, 12, 0, 0),
              onDateTimeChanged: (dateTime) {
                lastDateTime = dateTime;
                callCount++;
              },
            ),
          ),
        ),
      );

      // Find the hour picker (first CupertinoPicker)
      final hourPicker = find.byType(CupertinoPicker).first;

      // Drag to change hour
      await tester.drag(hourPicker, const Offset(0, -100));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(callCount, greaterThan(0));
      expect(lastDateTime, isNotNull);
    });

    testWidgets('should call onDateTimeChanged when minute changes',
        (tester) async {
      DateTime? lastDateTime;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              initialDateTime: DateTime(2024, 1, 1, 12, 0, 0),
              onDateTimeChanged: (dateTime) {
                lastDateTime = dateTime;
                callCount++;
              },
            ),
          ),
        ),
      );

      // Find the minute picker (second CupertinoPicker)
      final minutePicker = find.byType(CupertinoPicker).at(1);

      // Drag to change minute
      await tester.drag(minutePicker, const Offset(0, -100));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(callCount, greaterThan(0));
      expect(lastDateTime, isNotNull);
      expect(lastDateTime?.minute, isNot(0));
    });

    testWidgets('should call onDateTimeChanged when AM/PM changes',
        (tester) async {
      DateTime? lastDateTime;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              initialDateTime: DateTime(2024, 1, 1, 10, 0, 0), // 10 AM
              onDateTimeChanged: (dateTime) {
                lastDateTime = dateTime;
                callCount++;
              },
            ),
          ),
        ),
      );

      // Find the AM/PM picker (last CupertinoPicker)
      final amPmPicker = find.byType(CupertinoPicker).last;

      // Drag to change AM/PM
      await tester.drag(amPmPicker, const Offset(0, -50));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(callCount, greaterThan(0));
      expect(lastDateTime, isNotNull);
      expect(lastDateTime?.hour, 22); // 10 PM
    });

    testWidgets('should call onDateTimeChanged when seconds change',
        (tester) async {
      DateTime? lastDateTime;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              initialDateTime: DateTime(2024, 1, 1, 12, 0, 0),
              showSeconds: true,
              onDateTimeChanged: (dateTime) {
                lastDateTime = dateTime;
                callCount++;
              },
            ),
          ),
        ),
      );

      // Find the seconds picker (third CupertinoPicker)
      final secondsPicker = find.byType(CupertinoPicker).at(2);

      // Drag to change seconds
      await tester.drag(secondsPicker, const Offset(0, -100));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(callCount, greaterThan(0));
      expect(lastDateTime, isNotNull);
      expect(lastDateTime?.second, isNot(0));
    });

    testWidgets('should trigger haptic feedback when enabled', (tester) async {
      final List<MethodCall> log = [];

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              enableHaptics: true,
            ),
          ),
        ),
      );

      // Drag to trigger selection change
      final hourPicker = find.byType(CupertinoPicker).first;
      await tester.drag(hourPicker, const Offset(0, -100));
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
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              enableHaptics: false,
            ),
          ),
        ),
      );

      // Drag to trigger selection change
      final hourPicker = find.byType(CupertinoPicker).first;
      await tester.drag(hourPicker, const Offset(0, -100));
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

    testWidgets('should display correct time format', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              initialDateTime: DateTime(2024, 1, 1, 13, 5, 9), // 1:05:09 PM
              showSeconds: true,
              onDateTimeChanged: (_) {},
            ),
          ),
        ),
      );

      // Check for properly formatted values
      expect(find.text('1'), findsWidgets); // Hour without leading zero
      expect(find.text('05'), findsWidgets); // Minute with leading zero
      expect(find.text('09'), findsWidgets); // Second with leading zero
      expect(find.text('PM'), findsOneWidget);
    });
  });
}

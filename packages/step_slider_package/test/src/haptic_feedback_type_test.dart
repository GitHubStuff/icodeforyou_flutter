// test/src/haptic_feedback_type_test.dart
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_slider_package/step_slider_package.dart';

void main() {
  group('HapticFeedbackType', () {
    group('enum values', () {
      test('has light value', () {
        expect(HapticFeedbackType.light, isNotNull);
        expect(HapticFeedbackType.light.index, 0);
      });

      test('has medium value', () {
        expect(HapticFeedbackType.medium, isNotNull);
        expect(HapticFeedbackType.medium.index, 1);
      });

      test('has heavy value', () {
        expect(HapticFeedbackType.heavy, isNotNull);
        expect(HapticFeedbackType.heavy.index, 2);
      });

      test('has selection value', () {
        expect(HapticFeedbackType.selection, isNotNull);
        expect(HapticFeedbackType.selection.index, 3);
      });

      test('has vibrate value', () {
        expect(HapticFeedbackType.vibrate, isNotNull);
        expect(HapticFeedbackType.vibrate.index, 4);
      });

      test('has exactly 5 values', () {
        expect(HapticFeedbackType.values.length, 5);
      });

      test('values are in expected order', () {
        expect(HapticFeedbackType.values, [
          HapticFeedbackType.light,
          HapticFeedbackType.medium,
          HapticFeedbackType.heavy,
          HapticFeedbackType.selection,
          HapticFeedbackType.vibrate,
        ]);
      });
    });

    group('enum names', () {
      test('light has correct name', () {
        expect(HapticFeedbackType.light.name, 'light');
      });

      test('medium has correct name', () {
        expect(HapticFeedbackType.medium.name, 'medium');
      });

      test('heavy has correct name', () {
        expect(HapticFeedbackType.heavy.name, 'heavy');
      });

      test('selection has correct name', () {
        expect(HapticFeedbackType.selection.name, 'selection');
      });

      test('vibrate has correct name', () {
        expect(HapticFeedbackType.vibrate.name, 'vibrate');
      });
    });
  });

  group('HapticFeedbackType trigger (via StepSlider)', () {
    late List<String> hapticCalls;

    Widget buildTestWidget(HapticFeedbackType type) {
      return MaterialApp(
        home: Scaffold(
          body: StepSlider(
            initialValue: 50,
            enableHapticFeedback: true,
            hapticFeedbackType: type,
          ),
        ),
      );
    }

    setUp(() {
      hapticCalls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          // vibrate() passes no arguments, others pass a String
          final argument = call.arguments as String? ?? 'HapticFeedbackType.vibrate';
          hapticCalls.add(argument);
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('light triggers HapticFeedback.lightImpact', (tester) async {
      await tester.pumpWidget(buildTestWidget(HapticFeedbackType.light));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(hapticCalls, contains('HapticFeedbackType.lightImpact'));
    });

    testWidgets('medium triggers HapticFeedback.mediumImpact', (tester) async {
      await tester.pumpWidget(buildTestWidget(HapticFeedbackType.medium));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(hapticCalls, contains('HapticFeedbackType.mediumImpact'));
    });

    testWidgets('heavy triggers HapticFeedback.heavyImpact', (tester) async {
      await tester.pumpWidget(buildTestWidget(HapticFeedbackType.heavy));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(hapticCalls, contains('HapticFeedbackType.heavyImpact'));
    });

    testWidgets('selection triggers HapticFeedback.selectionClick', (tester) async {
      await tester.pumpWidget(buildTestWidget(HapticFeedbackType.selection));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(hapticCalls, contains('HapticFeedbackType.selectionClick'));
    });

    testWidgets('vibrate triggers HapticFeedback.vibrate', (tester) async {
      await tester.pumpWidget(buildTestWidget(HapticFeedbackType.vibrate));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(hapticCalls, contains('HapticFeedbackType.vibrate'));
    });

    testWidgets('each type triggers exactly once per tap', (tester) async {
      await tester.pumpWidget(buildTestWidget(HapticFeedbackType.light));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(hapticCalls.length, 1);
    });

    testWidgets('multiple taps trigger multiple haptics', (tester) async {
      await tester.pumpWidget(buildTestWidget(HapticFeedbackType.light));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(hapticCalls.length, 3);
      expect(
        hapticCalls.every((c) => c == 'HapticFeedbackType.lightImpact'),
        isTrue,
      );
    });

    testWidgets('all haptic types are distinct', (tester) async {
      final results = <HapticFeedbackType, String>{};

      for (final type in HapticFeedbackType.values) {
        hapticCalls.clear();
        await tester.pumpWidget(buildTestWidget(type));
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        if (hapticCalls.isNotEmpty) {
          results[type] = hapticCalls.first;
        }
      }

      // Verify all types produce unique haptic calls
      final uniqueCalls = results.values.toSet();
      expect(uniqueCalls.length, HapticFeedbackType.values.length);
    });
  });
}

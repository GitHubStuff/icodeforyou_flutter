// test/src/presentation/widgets/datetime_popover/datetime_picker_field_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

void main() {
  group('DateTimePickerField', () {
    Widget buildTestApp({required Widget child}) {
      return MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            child: const Text('Select Date'),
          ),
        ),
      );

      expect(find.text('Select Date'), findsOneWidget);
    });

    testWidgets('should show popover on tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            child: Container(
              width: 100,
              height: 50,
              color: Colors.blue,
              child: const Center(child: Text('Tap Me')),
            ),
          ),
        ),
      );

      // Tap the field
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      // Popover should be shown
      expect(find.text('Set'), findsOneWidget);
    });

    testWidgets('should not show popover when disabled', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            enabled: false,
            child: const Text('Disabled'),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      // Popover should NOT be shown
      expect(find.text('Set'), findsNothing);
    });

    testWidgets('should call onDateTimeSelected with result', (tester) async {
      DateTime? selectedDateTime;

      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (result) => selectedDateTime = result,
            initialDateTime: DateTime(2024, 6, 15, 10, 30),
            child: const Text('Select'),
          ),
        ),
      );

      // Open popover
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Confirm selection
      await tester.tap(find.text('Set'));
      await tester.pumpAndSettle();

      expect(selectedDateTime, isNotNull);
      expect(selectedDateTime!.year, 2024);
      expect(selectedDateTime!.month, 6);
      expect(selectedDateTime!.day, 15);
    });

    testWidgets('should call onDateTimeSelected with null on dismiss', (
      tester,
    ) async {
      DateTime? selectedDateTime;
      bool wasCalled = false;

      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (result) {
              selectedDateTime = result;
              wasCalled = true;
            },
            child: const Text('Select'),
          ),
        ),
      );

      // Open popover
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Tap outside to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(wasCalled, isTrue);
      expect(selectedDateTime, isNull);
    });

    testWidgets('should pass all customization options to popover', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            option: DateTimeOption.date,
            confirmButtonText: 'Done',
            child: const Text('Select'),
          ),
        ),
      );

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Should show custom confirm text
      expect(find.text('Done'), findsOneWidget);
      // Should show date picker only (no tabs)
      expect(find.text('DATE'), findsNothing);
      expect(find.text('TIME'), findsNothing);
    });

    testWidgets('should use date only option', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            option: DateTimeOption.date,
            child: const Text('Select Date'),
          ),
        ),
      );

      await tester.tap(find.text('Select Date'));
      await tester.pumpAndSettle();

      expect(find.byType(ScrollingDatePicker), findsOneWidget);
      expect(find.byType(ScrollingTimePicker), findsNothing);
    });

    testWidgets('should use time only option', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            option: DateTimeOption.time,
            child: const Text('Select Time'),
          ),
        ),
      );

      await tester.tap(find.text('Select Time'));
      await tester.pumpAndSettle();

      expect(find.byType(ScrollingTimePicker), findsOneWidget);
    });

    testWidgets('should use dateTime option with tabs', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            option: DateTimeOption.dateTime,
            child: const Text('Select DateTime'),
          ),
        ),
      );

      await tester.tap(find.text('Select DateTime'));
      await tester.pumpAndSettle();

      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('TIME'), findsOneWidget);
    });

    testWidgets('should apply custom styles', (tester) async {
      const customDateStyle = TextStyle(color: Colors.red, fontSize: 20);

      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            headerDateTextStyle: customDateStyle,
            child: const Text('Select'),
          ),
        ),
      );

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Verify popover is shown with custom styling
      expect(find.text('Set'), findsOneWidget);
    });

    testWidgets('should show custom confirm widget', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            confirmWidget: const Icon(Icons.check, key: Key('custom_icon')),
            child: const Text('Select'),
          ),
        ),
      );

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_icon')), findsOneWidget);
    });

    testWidgets('should handle dayAscending false', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            option: DateTimeOption.date,
            dayAscending: false,
            child: const Text('Select'),
          ),
        ),
      );

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(find.byType(ScrollingDatePicker), findsOneWidget);
    });

    testWidgets('should handle showSeconds false', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            option: DateTimeOption.time,
            showSeconds: false,
            child: const Text('Select'),
          ),
        ),
      );

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(find.byType(ScrollingTimePicker), findsOneWidget);
    });

    testWidgets('should use custom picker sizes', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            portraitPickerSize: const Size(300, 250),
            landscapePickerSize: const Size(400, 200),
            child: const Text('Select'),
          ),
        ),
      );

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(find.text('Set'), findsOneWidget);
    });

    testWidgets('should apply divider configuration', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            dividerConfiguration: const DividerConfiguration(
              color: Colors.red,
              thickness: 2.0,
            ),
            child: const Text('Select'),
          ),
        ),
      );

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(find.text('Set'), findsOneWidget);
    });

    testWidgets('should apply fade configuration', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            fadeConfiguration: FadeConfiguration.dark(),
            child: const Text('Select'),
          ),
        ),
      );

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(find.text('Set'), findsOneWidget);
    });

    testWidgets('should work with complex child widget', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text('Pick a date'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.text('Pick a date'), findsOneWidget);

      await tester.tap(find.text('Pick a date'));
      await tester.pumpAndSettle();

      expect(find.text('Set'), findsOneWidget);
    });

    testWidgets('should absorb pointer events when enabled', (tester) async {
      bool childTapped = false;

      await tester.pumpWidget(
        buildTestApp(
          child: DateTimePickerField(
            onDateTimeSelected: (_) {},
            enabled: true,
            child: GestureDetector(
              onTap: () => childTapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      // Child's onTap should not be called due to AbsorbPointer
      expect(childTapped, isFalse);
      // Popover should be shown instead
      expect(find.text('Set'), findsOneWidget);
    });
  });
}

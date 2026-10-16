// packages/sincewhen_screens/test/src/widgets/event_timestamp_row_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'package:sincewhen_screens/src/util/timestamp_display.dart';
import 'package:sincewhen_screens/src/widgets/event_timestamp_row.dart';

void main() {
  group('EventTimestampRow', () {
    test('static constants have expected values', () {
      expect(EventTimestampRow.fieldLabel, equals('Event'));
      expect(EventTimestampRow.clearTooltip, equals('Clear event date/time'));
    });

    testWidgets(
      'renders placeholder and no clear button when eventTimestamp is null',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventTimestampRow(
                eventTimestamp: null,
                onEventSelected: (_) {},
                onEventCleared: () {},
              ),
            ),
          ),
        );

        expect(find.text(TimestampDisplay.noValue), findsOneWidget);
        expect(find.byType(IconButton), findsNothing);
        expect(find.byIcon(Icons.clear), findsNothing);

        final pickerField = tester.widget<DateTimePickerField>(
          find.byType(DateTimePickerField),
        );
        expect(pickerField.initialDateTime, isNull);

        final inputDecorator = tester.widget<InputDecorator>(
          find.byType(InputDecorator),
        );
        expect(inputDecorator.isEmpty, isTrue);
        expect(inputDecorator.decoration.suffixIcon, isNull);
      },
    );

    testWidgets(
      'renders formatted timestamp and clear button when eventTimestamp is non-null',
      (tester) async {
        final now = DateTime(2026, 6, 15, 14, 30);
        final timestampMicros = now.microsecondsSinceEpoch;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventTimestampRow(
                eventTimestamp: timestampMicros,
                onEventSelected: (_) {},
                onEventCleared: () {},
              ),
            ),
          ),
        );

        final expectedFormatted = TimestampDisplay.format(timestampMicros);
        expect(find.text(expectedFormatted), findsOneWidget);

        final clearButtonFinder = find.byTooltip(
          EventTimestampRow.clearTooltip,
        );
        expect(clearButtonFinder, findsOneWidget);
        expect(find.byIcon(Icons.clear), findsOneWidget);

        final pickerField = tester.widget<DateTimePickerField>(
          find.byType(DateTimePickerField),
        );
        expect(
          pickerField.initialDateTime?.microsecondsSinceEpoch,
          equals(timestampMicros),
        );

        final inputDecorator = tester.widget<InputDecorator>(
          find.byType(InputDecorator),
        );
        expect(inputDecorator.isEmpty, isFalse);
        expect(inputDecorator.decoration.suffixIcon, isNotNull);
      },
    );

    testWidgets('tapping clear button triggers onEventCleared callback', (
      tester,
    ) async {
      var cleared = false;
      final now = DateTime(2026, 6, 15, 14, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventTimestampRow(
              eventTimestamp: now.microsecondsSinceEpoch,
              onEventSelected: (_) {},
              onEventCleared: () {
                cleared = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip(EventTimestampRow.clearTooltip));
      await tester.pump();

      expect(cleared, isTrue);
    });

    testWidgets(
      'calls onEventSelected when DateTimePickerField emits non-null date',
      (tester) async {
        DateTime? selectedDate;
        final targetDate = DateTime(2026, 10, 20, 8, 45);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventTimestampRow(
                eventTimestamp: null,
                onEventSelected: (dt) {
                  selectedDate = dt;
                },
                onEventCleared: () {},
              ),
            ),
          ),
        );

        final pickerField = tester.widget<DateTimePickerField>(
          find.byType(DateTimePickerField),
        );

        pickerField.onDateTimeSelected(targetDate);
        await tester.pump();

        expect(selectedDate, equals(targetDate));
      },
    );

    testWidgets('ignores null dismissal signal from DateTimePickerField', (
      tester,
    ) async {
      var wasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventTimestampRow(
              eventTimestamp: null,
              onEventSelected: (_) {
                wasCalled = true;
              },
              onEventCleared: () {},
            ),
          ),
        ),
      );

      final pickerField = tester.widget<DateTimePickerField>(
        find.byType(DateTimePickerField),
      );

      pickerField.onDateTimeSelected(null);
      await tester.pump();

      expect(wasCalled, isFalse);
    });
  });
}

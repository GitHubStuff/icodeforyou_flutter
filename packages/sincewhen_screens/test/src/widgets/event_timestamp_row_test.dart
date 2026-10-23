// packages/sincewhen_screens/test/src/widgets/event_timestamp_row_test.dart

import 'package:datetime_pickers/datetime_pickers.dart' show FatPicker;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show EventTimestampPickerSheet, EventTimestampRow, TimestampDisplay;

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12);
  final event = DateTime(2026, 6, 15, 14, 30);
  final eventMicros = event.microsecondsSinceEpoch;

  Future<void> pumpRow(
    WidgetTester tester, {
    required int? eventTimestamp,
    ValueChanged<DateTime>? onEventSelected,
    VoidCallback? onEventCleared,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventTimestampRow(
            eventTimestamp: eventTimestamp,
            onEventSelected: onEventSelected ?? (_) {},
            onEventCleared: onEventCleared ?? () {},
            now: () => fixedNow,
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(
    WidgetTester tester, {
    required String fieldText,
  }) async {
    await tester.tap(find.text(fieldText));
    await tester.pumpAndSettle();
  }

  Future<void> tapSheetButton(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(TextButton, label));
    await tester.pumpAndSettle();
  }

  group('EventTimestampRow', () {
    test('static constants have expected values', () {
      expect(EventTimestampRow.fieldLabel, equals('Date & time'));
      expect(EventTimestampRow.clearTooltip, equals('Clear event date/time'));
      expect(EventTimestampRow.focusedBorderWidth, equals(2));
    });

    test('now defaults to DateTime.now', () {
      const row = EventTimestampRow(
        eventTimestamp: null,
        onEventSelected: _noopDateTime,
        onEventCleared: _noop,
      );
      expect(row.now, equals(DateTime.now));
    });

    group('rendering', () {
      testWidgets(
        'shows placeholder and no clear button when eventTimestamp is null',
        (tester) async {
          await pumpRow(tester, eventTimestamp: null);

          expect(find.text(TimestampDisplay.noValue), findsOneWidget);
          expect(find.text(EventTimestampRow.fieldLabel), findsOneWidget);
          expect(find.byType(IconButton), findsNothing);
          expect(find.byIcon(Icons.clear), findsNothing);

          final inputDecorator = tester.widget<InputDecorator>(
            find.byType(InputDecorator),
          );
          expect(inputDecorator.isEmpty, isTrue);
          expect(inputDecorator.decoration.suffixIcon, isNull);
          expect(
            inputDecorator.decoration.labelText,
            equals(EventTimestampRow.fieldLabel),
          );
        },
      );

      testWidgets(
        'shows formatted timestamp and clear button when eventTimestamp is set',
        (tester) async {
          await pumpRow(tester, eventTimestamp: eventMicros);

          expect(
            find.text(TimestampDisplay.format(eventMicros)),
            findsOneWidget,
          );
          expect(
            find.byTooltip(EventTimestampRow.clearTooltip),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.clear), findsOneWidget);

          final inputDecorator = tester.widget<InputDecorator>(
            find.byType(InputDecorator),
          );
          expect(inputDecorator.isEmpty, isFalse);
          expect(inputDecorator.decoration.suffixIcon, isNotNull);
        },
      );
    });

    group('clearing', () {
      testWidgets('tapping clear button calls onEventCleared', (tester) async {
        var cleared = false;
        await pumpRow(
          tester,
          eventTimestamp: eventMicros,
          onEventCleared: () => cleared = true,
        );

        await tester.tap(find.byTooltip(EventTimestampRow.clearTooltip));
        await tester.pump();

        expect(cleared, isTrue);
        expect(find.byType(EventTimestampPickerSheet), findsNothing);
      });
    });

    group('picking', () {
      testWidgets(
        'tapping the field opens the sheet seeded with the current value',
        (tester) async {
          await pumpRow(tester, eventTimestamp: eventMicros);

          await openSheet(
            tester,
            fieldText: TimestampDisplay.format(eventMicros),
          );

          expect(find.byType(EventTimestampPickerSheet), findsOneWidget);
          final picker = tester.widget<FatPicker>(find.byType(FatPicker));
          expect(picker.initialDateTime, equals(event));
        },
      );

      testWidgets(
        'tapping the field with no value opens the sheet seeded with now()',
        (tester) async {
          await pumpRow(tester, eventTimestamp: null);

          await openSheet(tester, fieldText: TimestampDisplay.noValue);

          final picker = tester.widget<FatPicker>(find.byType(FatPicker));
          expect(picker.initialDateTime, equals(fixedNow));
        },
      );

      testWidgets('confirming the sheet calls onEventSelected', (tester) async {
        DateTime? selected;
        await pumpRow(
          tester,
          eventTimestamp: eventMicros,
          onEventSelected: (dateTime) => selected = dateTime,
        );

        await openSheet(
          tester,
          fieldText: TimestampDisplay.format(eventMicros),
        );
        await tapSheetButton(tester, EventTimestampPickerSheet.doneLabel);

        expect(selected, equals(event));
        expect(find.byType(EventTimestampPickerSheet), findsNothing);
      });

      testWidgets('cancelling the sheet does not call onEventSelected', (
        tester,
      ) async {
        var called = false;
        await pumpRow(
          tester,
          eventTimestamp: eventMicros,
          onEventSelected: (_) => called = true,
        );

        await openSheet(
          tester,
          fieldText: TimestampDisplay.format(eventMicros),
        );
        await tapSheetButton(tester, EventTimestampPickerSheet.cancelLabel);

        expect(called, isFalse);
        expect(find.byType(EventTimestampPickerSheet), findsNothing);
      });

      testWidgets('dismissing the sheet via the barrier is swallowed', (
        tester,
      ) async {
        var called = false;
        await pumpRow(
          tester,
          eventTimestamp: null,
          onEventSelected: (_) => called = true,
        );

        await openSheet(tester, fieldText: TimestampDisplay.noValue);
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();

        expect(called, isFalse);
        expect(find.byType(EventTimestampPickerSheet), findsNothing);
      });
    });
  });
}

void _noop() {}

void _noopDateTime(DateTime _) {}

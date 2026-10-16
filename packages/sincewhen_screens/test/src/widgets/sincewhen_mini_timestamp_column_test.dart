// packages/sincewhen_screens/test/src/widgets/sincewhen_mini_timestamp_column_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sincewhen_models/sincewhen_models.dart' show SinceWhenItem;
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show
        EventTimestampRow,
        SinceWhenMiniReady,
        SinceWhenMiniTimestampColumn,
        TimestampDisplay,
        TimestampRow;
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart'
    show SinceWhenMiniDimensions;

void main() {
  group('SinceWhenMiniTimestampColumn', () {
    test('static label constants have expected values', () {
      expect(SinceWhenMiniTimestampColumn.createdLabel, equals('Created'));
      expect(SinceWhenMiniTimestampColumn.reviewedLabel, equals('Reviewed'));
      expect(SinceWhenMiniTimestampColumn.editedLabel, equals('Edited'));
      expect(SinceWhenMiniTimestampColumn.sequenceLabel, equals('Sequence'));
    });

    SinceWhenMiniReady createReadyState({
      int created = 1000,
      int reviewed = 2000,
      int edited = 3000,
      int? eventTimestamp = 4000,
      SinceWhenItem? original,
    }) {
      return SinceWhenMiniReady(
        original: original,
        createdTimestamp: created,
        reviewedTimestamp: reviewed,
        editedTimestamp: edited,
        content: 'Content',
        metaData: 'Metadata',
        tldr: 'TLDR',
        eventTimestamp: eventTimestamp,
      );
    }

    testWidgets(
      'renders all timestamp rows, gaps, and event row with correct values',
      (tester) async {
        final state = createReadyState(
          created: 1000,
          reviewed: 2000,
          edited: 3000,
          eventTimestamp: 4000,
          original: const SinceWhenItem(
            id: 1,
            createdTimestamp: 1000,
            reviewedTimestamp: 2000,
            editedTimestamp: 3000,
            sequenceNumber: 7,
            content: 'Content',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SinceWhenMiniTimestampColumn(
                state: state,
                onEventSelected: (_) {},
                onEventCleared: () {},
              ),
            ),
          ),
        );

        // Verify all 4 TimestampRow widgets and their values
        final timestampRows = tester
            .widgetList<TimestampRow>(find.byType(TimestampRow))
            .toList();
        expect(timestampRows.length, equals(4));

        expect(
          timestampRows[0].label,
          equals(SinceWhenMiniTimestampColumn.createdLabel),
        );
        expect(timestampRows[0].value, equals(TimestampDisplay.format(1000)));

        expect(
          timestampRows[1].label,
          equals(SinceWhenMiniTimestampColumn.reviewedLabel),
        );
        expect(timestampRows[1].value, equals(TimestampDisplay.format(2000)));

        expect(
          timestampRows[2].label,
          equals(SinceWhenMiniTimestampColumn.editedLabel),
        );
        expect(timestampRows[2].value, equals(TimestampDisplay.format(3000)));

        expect(
          timestampRows[3].label,
          equals(SinceWhenMiniTimestampColumn.sequenceLabel),
        );
        expect(timestampRows[3].value, equals('7'));

        // Verify EventTimestampRow
        final eventRow = tester.widget<EventTimestampRow>(
          find.byType(EventTimestampRow),
        );
        expect(eventRow.eventTimestamp, equals(4000));

        // Verify only the 4 direct separating gaps inside SinceWhenMiniTimestampColumn's Column
        final columnFinder = find.descendant(
          of: find.byType(SinceWhenMiniTimestampColumn),
          matching: find.byType(Column),
        );
        final columnWidget = tester.widget<Column>(columnFinder.first);
        final directGaps = columnWidget.children.whereType<Gap>().toList();

        expect(directGaps.length, equals(4));
        for (final gap in directGaps) {
          expect(
            gap.mainAxisExtent,
            equals(SinceWhenMiniDimensions.timestampRowGap),
          );
        }
      },
    );

    testWidgets(
      'renders default sequenceNumber 0 in create mode (original is null)',
      (tester) async {
        final state = createReadyState(original: null);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SinceWhenMiniTimestampColumn(
                state: state,
                onEventSelected: (_) {},
                onEventCleared: () {},
              ),
            ),
          ),
        );

        final sequenceRow = tester
            .widgetList<TimestampRow>(find.byType(TimestampRow))
            .last;
        expect(
          sequenceRow.label,
          equals(SinceWhenMiniTimestampColumn.sequenceLabel),
        );
        expect(sequenceRow.value, equals('0'));
      },
    );

    testWidgets(
      'forwards onEventSelected and onEventCleared to EventTimestampRow',
      (tester) async {
        DateTime? selectedDate;
        var cleared = false;

        final state = createReadyState();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SinceWhenMiniTimestampColumn(
                state: state,
                onEventSelected: (dt) => selectedDate = dt,
                onEventCleared: () => cleared = true,
              ),
            ),
          ),
        );

        final eventRow = tester.widget<EventTimestampRow>(
          find.byType(EventTimestampRow),
        );

        final targetDate = DateTime(2026, 12, 25);
        eventRow.onEventSelected(targetDate);
        expect(selectedDate, equals(targetDate));

        eventRow.onEventCleared();
        expect(cleared, isTrue);
      },
    );
  });
}

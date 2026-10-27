// packages/sincewhen_screens/test/src/widgets/timestamp_row_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sincewhen_screens/sincewhen_screens.dart' show TimestampRow;
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart'
    show SinceWhenMiniDimensions;

void main() {
  group('TimestampRow', () {
    testWidgets('renders label and value with expected texts and text styles', (
      tester,
    ) async {
      const labelText = 'Created';
      const valueText = 'Tue 14-Jul-2026 6:27:47 pm';

      late TextTheme ambientTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ambientTheme = Theme.of(context).textTheme;
                return const TimestampRow(
                  label: labelText,
                  value: valueText,
                );
              },
            ),
          ),
        ),
      );

      final labelFinder = find.text(labelText);
      final valueFinder = find.text(valueText);

      expect(labelFinder, findsOneWidget);
      expect(valueFinder, findsOneWidget);

      final labelWidget = tester.widget<Text>(labelFinder);
      final valueWidget = tester.widget<Text>(valueFinder);

      expect(labelWidget.style, equals(ambientTheme.labelLarge));
      expect(valueWidget.style, equals(ambientTheme.bodyLarge));
    });

    testWidgets(
      'renders Gap between label and value with labelValueGap height',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimestampRow(
                label: 'Reviewed',
                value: '12345',
              ),
            ),
          ),
        );

        final columnFinder = find.descendant(
          of: find.byType(TimestampRow),
          matching: find.byType(Column),
        );
        expect(columnFinder, findsOneWidget);

        final columnWidget = tester.widget<Column>(columnFinder);
        expect(
          columnWidget.crossAxisAlignment,
          equals(CrossAxisAlignment.start),
        );

        final gapWidget = tester.widget<Gap>(find.byType(Gap));
        expect(
          gapWidget.mainAxisExtent,
          equals(SinceWhenMiniDimensions.labelValueGap),
        );
      },
    );
  });
}

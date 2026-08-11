// packages/custom_widgets/test/src/uniform_cluster/button_pair_test.dart

import 'package:custom_widgets/custom_widgets.dart' show ButtonPair;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [pair] inside a width-bounded Material scaffold.
Future<void> _pump(WidgetTester tester, ButtonPair pair) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 300, child: pair)),
      ),
    ),
  );
}

void main() {
  group('ButtonPair', () {
    testWidgets('horizontal leads with outlined Cancel and trails with '
        'filled Save', (tester) async {
      await _pump(tester, ButtonPair(onPrimary: () {}, onSecondary: () {}));

      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(OutlinedButton)).dx,
        lessThan(tester.getTopLeft(find.byType(FilledButton)).dx),
      );
    });

    testWidgets('vertical stacks filled Save above outlined Cancel',
        (tester) async {
      await _pump(
        tester,
        ButtonPair(
          onPrimary: () {},
          onSecondary: () {},
          axis: Axis.vertical,
        ),
      );

      expect(
        tester.getTopLeft(find.byType(FilledButton)).dy,
        lessThan(tester.getTopLeft(find.byType(OutlinedButton)).dy),
      );
    });

    testWidgets('routes taps to the matching callbacks', (tester) async {
      var primary = 0;
      var secondary = 0;
      await _pump(
        tester,
        ButtonPair(
          onPrimary: () => primary++,
          onSecondary: () => secondary++,
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(primary, 1);
      expect(secondary, 1);
    });

    testWidgets('renders custom labels', (tester) async {
      await _pump(
        tester,
        ButtonPair(
          onPrimary: () {},
          onSecondary: () {},
          primaryText: 'Apply',
          secondaryText: 'Discard',
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Apply'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Discard'), findsOneWidget);
    });

    testWidgets('null callbacks disable the buttons', (tester) async {
      await _pump(
        tester,
        const ButtonPair(onPrimary: null, onSecondary: null),
      );

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isFalse,
      );
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).enabled,
        isFalse,
      );
    });
  });
}

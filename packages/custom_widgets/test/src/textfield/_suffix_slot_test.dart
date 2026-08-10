// packages/custom_widgets/test/src/textfield/_suffix_slot_test.dart

import 'package:custom_widgets/src/textfield/_suffix_slot.dart'
    show SuffixSlot;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuffixSlot', () {
    test('publishes tap-target constraints for the decorator', () {
      expect(SuffixSlot.constraints.minWidth, kMinInteractiveDimension);
      expect(SuffixSlot.constraints.minHeight, kMinInteractiveDimension);
    });

    testWidgets('centres its child in a fixed, right-inset square',
        (tester) async {
      const childKey = Key('affordance');

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SuffixSlot(
              child: SizedBox(key: childKey, width: 10, height: 10),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(SuffixSlot),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, const EdgeInsets.only(right: 8));

      final squareFinder = find.descendant(
        of: find.byType(SuffixSlot),
        matching: find.byWidgetPredicate(
          (w) =>
              w is SizedBox &&
              w.width == kMinInteractiveDimension &&
              w.height == kMinInteractiveDimension,
        ),
      );
      expect(squareFinder, findsOneWidget);
      expect(
        tester.getCenter(find.byKey(childKey)),
        tester.getCenter(squareFinder),
      );
    });
  });
}

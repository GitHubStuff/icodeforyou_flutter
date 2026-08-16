// packages/ice_chips/test/src/ice_chip_tray/ice_chip_tray_layout_test.dart
//
// Constructors are deliberately invoked WITHOUT `const` so the
// constructor lines execute at runtime and register in LCOV.
// Const invocations are canonicalized at compile time and never hit
// the constructor body, which is why those lines showed 0 hits.
// ignore_for_file: prefer_const_constructors

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_layout.dart';

void main() {
  Widget chipAt(int index) => Text('chip $index');

  Future<void> pumpLayout(
    WidgetTester tester,
    IceChipsTrayLayout layout, {
    int chipCount = 3,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) => layout.build(context, chipCount, chipAt),
        ),
      ),
    );
  }

  group('IceChipsTrayLayoutWrap', () {
    test('constructor applies documented defaults', () {
      final layout = IceChipsTrayLayoutWrap();

      expect(layout.spacing, 8);
      expect(layout.runSpacing, 8);
      expect(layout.alignment, WrapAlignment.start);
      expect(layout.runAlignment, WrapAlignment.start);
      expect(layout.crossAxisAlignment, WrapCrossAlignment.start);
    });

    testWidgets('build produces a Wrap honoring configuration', (tester) async {
      final layout = IceChipsTrayLayoutWrap(
        spacing: 12,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
      );

      await pumpLayout(tester, layout);

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 12);
      expect(wrap.runSpacing, 16);
      expect(wrap.alignment, WrapAlignment.center);
      expect(wrap.runAlignment, WrapAlignment.end);
      expect(wrap.crossAxisAlignment, WrapCrossAlignment.center);

      expect(find.text('chip 0'), findsOneWidget);
      expect(find.text('chip 1'), findsOneWidget);
      expect(find.text('chip 2'), findsOneWidget);
    });
  });

  group('IceChipsTrayLayoutList', () {
    test('constructor applies documented defaults', () {
      final layout = IceChipsTrayLayoutList();

      expect(layout.scrollDirection, Axis.vertical);
      expect(layout.shrinkWrap, isFalse);
      expect(layout.padding, isNull);
      expect(layout.physics, isNull);
      expect(layout.itemExtent, isNull);
    });

    testWidgets('build produces a ListView honoring configuration', (
      tester,
    ) async {
      final layout = IceChipsTrayLayoutList(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: EdgeInsets.all(4),
        physics: NeverScrollableScrollPhysics(),
        itemExtent: 48,
      );

      await pumpLayout(tester, layout, chipCount: 2);

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, Axis.horizontal);
      expect(listView.shrinkWrap, isTrue);
      expect(listView.padding, EdgeInsets.all(4));
      expect(listView.physics, isA<NeverScrollableScrollPhysics>());
      expect(listView.itemExtent, 48);

      expect(find.text('chip 0'), findsOneWidget);
      expect(find.text('chip 1'), findsOneWidget);
    });
  });

  group('IceChipsTrayLayoutRow', () {
    test('constructor applies documented defaults', () {
      final layout = IceChipsTrayLayoutRow();

      expect(layout.spacing, 8);
      expect(layout.mainAxisSize, MainAxisSize.max);
      expect(layout.mainAxisAlignment, MainAxisAlignment.start);
      expect(layout.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('build produces a Row with spacing between chips', (
      tester,
    ) async {
      final layout = IceChipsTrayLayoutRow(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
      );

      await pumpLayout(tester, layout);

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisSize, MainAxisSize.min);
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(row.crossAxisAlignment, CrossAxisAlignment.start);

      expect(find.text('chip 0'), findsOneWidget);
      expect(find.text('chip 1'), findsOneWidget);
      expect(find.text('chip 2'), findsOneWidget);

      // Three chips → two spacing gaps, none before the first chip.
      final gaps = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(Row),
              matching: find.byType(SizedBox),
            ),
          )
          .where((box) => box.width == 10);
      expect(gaps.length, 2);
    });
  });
}

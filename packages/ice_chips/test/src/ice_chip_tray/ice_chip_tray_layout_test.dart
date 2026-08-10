// packages/ice_chips/test/src/ice_chip_tray/ice_chip_tray_layout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_layout.dart'
    show
        IceChipsTrayLayout,
        IceChipsTrayLayoutList,
        IceChipsTrayLayoutRow,
        IceChipsTrayLayoutWrap;

/// Number of placeholder chips pumped into every layout under test.
/// Two guarantees both the `i == 0` and `i > 0` arms of the row
/// spacing logic execute.
const _kChipCount = 2;

/// Builds a labeled placeholder standing in for a real chip.
Widget _chipAt(int index) => Text('chip-$index');

/// Pumps [layout] inside a [MaterialApp] and returns after settling.
Future<void> _pumpLayout(
  WidgetTester tester,
  IceChipsTrayLayout layout,
) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) =>
              layout.build(context, _kChipCount, _chipAt),
        ),
      ),
    ),
  );
}

void main() {
  group('IceChipsTrayLayoutWrap', () {
    testWidgets('builds a Wrap honoring every parameter', (tester) async {
      const layout = IceChipsTrayLayoutWrap(
        spacing: 4,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
      );

      await _pumpLayout(tester, layout);

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 4);
      expect(wrap.runSpacing, 6);
      expect(wrap.alignment, WrapAlignment.center);
      expect(wrap.runAlignment, WrapAlignment.end);
      expect(wrap.crossAxisAlignment, WrapCrossAlignment.center);
      expect(find.text('chip-0'), findsOneWidget);
      expect(find.text('chip-1'), findsOneWidget);
    });

    test('defaults match documented values', () {
      const layout = IceChipsTrayLayoutWrap();
      expect(layout.spacing, 8);
      expect(layout.runSpacing, 8);
      expect(layout.alignment, WrapAlignment.start);
      expect(layout.runAlignment, WrapAlignment.start);
      expect(layout.crossAxisAlignment, WrapCrossAlignment.start);
    });
  });

  group('IceChipsTrayLayoutList', () {
    testWidgets('builds a lazy ListView honoring every parameter',
        (tester) async {
      const layout = IceChipsTrayLayoutList(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: EdgeInsets.all(12),
        physics: NeverScrollableScrollPhysics(),
        itemExtent: 40,
      );

      await _pumpLayout(tester, layout);

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, Axis.horizontal);
      expect(listView.shrinkWrap, isTrue);
      expect(listView.padding, const EdgeInsets.all(12));
      expect(listView.physics, isA<NeverScrollableScrollPhysics>());
      expect(listView.itemExtent, 40);
      expect(find.text('chip-0'), findsOneWidget);
      expect(find.text('chip-1'), findsOneWidget);
    });

    test('defaults match documented values', () {
      const layout = IceChipsTrayLayoutList();
      expect(layout.scrollDirection, Axis.vertical);
      expect(layout.shrinkWrap, isFalse);
      expect(layout.padding, isNull);
      expect(layout.physics, isNull);
      expect(layout.itemExtent, isNull);
    });
  });

  group('IceChipsTrayLayoutRow', () {
    testWidgets('builds a Row with spacing between chips',
        (tester) async {
      const layout = IceChipsTrayLayoutRow(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
      );

      await _pumpLayout(tester, layout);

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisSize, MainAxisSize.min);
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
      expect(row.crossAxisAlignment, CrossAxisAlignment.end);
      // Two chips → exactly one spacing SizedBox between them.
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 10,
        ),
        findsOneWidget,
      );
      expect(find.text('chip-0'), findsOneWidget);
      expect(find.text('chip-1'), findsOneWidget);
    });

    test('defaults match documented values', () {
      const layout = IceChipsTrayLayoutRow();
      expect(layout.spacing, 8);
      expect(layout.mainAxisSize, MainAxisSize.max);
      expect(layout.mainAxisAlignment, MainAxisAlignment.start);
      expect(layout.crossAxisAlignment, CrossAxisAlignment.center);
    });
  });
}

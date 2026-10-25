// packages/app_navigation/test/src/widgets/dock_row_test.dart

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot;
import 'package:app_navigation/src/widgets/button_widget.dart' show NavButton;
import 'package:app_navigation/src/widgets/dock_row.dart' show DockRow;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;

Widget _placeholder() => const SizedBox.shrink();

enum _Items implements NavButtonProperties {
  home(NavSlot.pinned, Icons.home, 'Home'),
  search(NavSlot.pinned, Icons.search, 'Search'),
  settings(NavSlot.pinned, Icons.settings, 'Settings'),
  more(NavSlot.more, Icons.more_horiz, 'More');

  const _Items(this.slot, this.iconData, this.caption);

  @override
  final NavSlot slot;

  @override
  final IconData iconData;

  @override
  final String caption;

  @override
  HapticIntensity get haptic => HapticIntensity.primary;

  @override
  Widget Function() get viewBuilder => _placeholder;
}

const Size _size = Size(80, 64);

const List<_Items> _fitted = [
  _Items.home,
  _Items.search,
  _Items.settings,
  _Items.more,
];

Widget _harness({
  required List<_Items> buttons,
  required ValueChanged<_Items>? onTap,
  _Items? highlighted,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: DockRow<_Items>(
          buttons: buttons,
          size: _size,
          onTap: onTap,
          highlighted: highlighted,
        ),
      ),
    ),
  );
}

NavButton<_Items> _buttonFor(WidgetTester tester, _Items item) =>
    tester.widget<NavButton<_Items>>(find.byKey(ValueKey<_Items>(item)));

void main() {
  group('DockRow', () {
    testWidgets('renders one NavButton per item in list order', (tester) async {
      await tester.pumpWidget(_harness(buttons: _fitted, onTap: (_) {}));

      final rendered = tester
          .widgetList<NavButton<_Items>>(find.byType(NavButton<_Items>))
          .map((button) => button.item)
          .toList();

      expect(rendered, _fitted);
    });

    testWidgets('keys each NavButton by its item', (tester) async {
      await tester.pumpWidget(_harness(buttons: _fitted, onTap: (_) {}));

      for (final item in _fitted) {
        expect(find.byKey(ValueKey<_Items>(item)), findsOneWidget);
      }
    });

    testWidgets('passes the shared size to every NavButton', (tester) async {
      await tester.pumpWidget(_harness(buttons: _fitted, onTap: (_) {}));

      for (final item in _fitted) {
        expect(_buttonFor(tester, item).size, _size);
      }
    });

    testWidgets('row height equals size.height', (tester) async {
      await tester.pumpWidget(_harness(buttons: _fitted, onTap: (_) {}));

      final box = tester.getSize(find.byType(DockRow<_Items>));

      expect(box.height, _size.height);
    });

    testWidgets('spaces buttons evenly across the full width', (tester) async {
      await tester.pumpWidget(_harness(buttons: _fitted, onTap: (_) {}));

      final row = tester.widget<Row>(find.byType(Row));
      final rowWidth = tester.getSize(find.byType(Row)).width;
      final left = tester.getTopLeft(find.byKey(const ValueKey(_Items.home)));
      final right = tester.getTopRight(find.byKey(const ValueKey(_Items.more)));

      expect(row.mainAxisAlignment, MainAxisAlignment.spaceEvenly);
      expect(rowWidth, tester.getSize(find.byType(DockRow<_Items>)).width);
      expect(left.dx, greaterThan(0));
      expect(right.dx, lessThan(rowWidth));
    });

    testWidgets('wraps the row in a bottom-only SafeArea', (tester) async {
      await tester.pumpWidget(_harness(buttons: _fitted, onTap: (_) {}));

      final safeArea = tester.widget<SafeArea>(
        find.descendant(
          of: find.byType(DockRow<_Items>),
          matching: find.byType(SafeArea),
        ),
      );

      expect(safeArea.top, isFalse);
      expect(safeArea.bottom, isTrue);
    });

    group('highlighted', () {
      testWidgets('marks only the highlighted item as selected', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            buttons: _fitted,
            onTap: (_) {},
            highlighted: _Items.search,
          ),
        );

        for (final item in _fitted) {
          expect(
            _buttonFor(tester, item).selected,
            item == _Items.search,
            reason: '$item',
          );
        }
      });

      testWidgets('can highlight the more item', (tester) async {
        await tester.pumpWidget(
          _harness(
            buttons: _fitted,
            onTap: (_) {},
            highlighted: _Items.more,
          ),
        );

        expect(_buttonFor(tester, _Items.more).selected, isTrue);
        expect(_buttonFor(tester, _Items.home).selected, isFalse);
      });

      testWidgets('null highlights nothing', (tester) async {
        await tester.pumpWidget(_harness(buttons: _fitted, onTap: (_) {}));

        for (final item in _fitted) {
          expect(_buttonFor(tester, item).selected, isFalse);
        }
      });
    });

    group('onTap', () {
      testWidgets('delivers the tapped item', (tester) async {
        final taps = <_Items>[];
        await tester.pumpWidget(_harness(buttons: _fitted, onTap: taps.add));

        await tester.tap(find.byKey(const ValueKey(_Items.settings)));
        await tester.pump();

        expect(taps, [_Items.settings]);
      });

      testWidgets('delivers more exactly like any other item', (tester) async {
        final taps = <_Items>[];
        await tester.pumpWidget(_harness(buttons: _fitted, onTap: taps.add));

        await tester.tap(find.byKey(const ValueKey(_Items.more)));
        await tester.pump();

        expect(taps, [_Items.more]);
      });

      testWidgets('null disables every NavButton', (tester) async {
        await tester.pumpWidget(_harness(buttons: _fitted, onTap: null));

        for (final item in _fitted) {
          expect(_buttonFor(tester, item).onTap, isNull);
        }
      });
    });

    testWidgets('renders an empty row for an empty list', (tester) async {
      await tester.pumpWidget(_harness(buttons: const [], onTap: (_) {}));

      expect(find.byType(NavButton<_Items>), findsNothing);
      expect(tester.getSize(find.byType(DockRow<_Items>)).height, _size.height);
    });
  });
}

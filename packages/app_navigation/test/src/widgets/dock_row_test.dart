// packages/app_navigation/test/src/widgets/dock_row_test.dart

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot;
import 'package:app_navigation/src/widgets/button_widget.dart' show NavButton;
import 'package:app_navigation/src/widgets/dock_row.dart' show DockRow;
import 'package:app_navigation/src/widgets/more_nav_button.dart'
    show MoreNavButton;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;

Widget _placeholder() => const SizedBox.shrink();

enum _Items implements NavButtonProperties {
  home(NavSlot.pinned, Icons.home, 'Home'),
  search(NavSlot.pinned, Icons.search, 'Search'),
  settings(NavSlot.pinned, Icons.settings, 'Settings'),
  more(NavSlot.more, Icons.more_horiz, 'More'),
  library(NavSlot.overflow, Icons.video_library, 'Library'),
  profile(NavSlot.overflow, Icons.person, 'Profile');

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

const List<_Items> _dock = [
  _Items.home,
  _Items.search,
  _Items.settings,
  _Items.more,
];

const List<_Items> _dockWithoutMore = [
  _Items.home,
  _Items.search,
  _Items.settings,
];

const List<_Items> _overflow = [_Items.library, _Items.profile];

Widget _harness({
  required List<_Items> buttons,
  required ValueChanged<_Items>? onTap,
  List<_Items> overflow = _overflow,
  _Items? selected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: DockRow<_Items>(
          buttons: buttons,
          overflow: overflow,
          size: _size,
          onTap: onTap,
          selected: selected,
        ),
      ),
    ),
  );
}

Finder _keyed(_Items item) => find.byKey(ValueKey<_Items>(item));

NavButton<_Items> _buttonFor(WidgetTester tester, _Items item) =>
    tester.widget<NavButton<_Items>>(_keyed(item));

MoreNavButton<_Items> _moreButton(WidgetTester tester) =>
    tester.widget<MoreNavButton<_Items>>(_keyed(_Items.more));

NavButton<_Items> _moreInnerButton(WidgetTester tester) =>
    tester.widget<NavButton<_Items>>(
      find.descendant(
        of: _keyed(_Items.more),
        matching: find.byType(NavButton<_Items>),
      ),
    );

void main() {
  group('DockRow', () {
    group('rendering', () {
      testWidgets('renders a NavButton per non-more item in list order', (
        tester,
      ) async {
        await tester.pumpWidget(_harness(buttons: _dock, onTap: (_) {}));

        final rendered = tester
            .widgetList<NavButton<_Items>>(find.byType(NavButton<_Items>))
            .map((button) => button.item)
            .toList();

        expect(rendered, [..._dockWithoutMore, _Items.more]);
        expect(find.byType(MoreNavButton<_Items>), findsOneWidget);
      });

      testWidgets('renders the more slot as a MoreNavButton', (tester) async {
        await tester.pumpWidget(_harness(buttons: _dock, onTap: (_) {}));

        final more = _moreButton(tester);

        expect(more.item, _Items.more);
        expect(more.overflow, _overflow);
        expect(more.size, _size);
      });

      testWidgets('renders no MoreNavButton when buttons has no more', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            buttons: _dockWithoutMore,
            overflow: const [],
            onTap: (_) {},
          ),
        );

        expect(find.byType(MoreNavButton<_Items>), findsNothing);
        expect(find.byType(NavButton<_Items>), findsNWidgets(3));
      });

      testWidgets('keys every button by its item', (tester) async {
        await tester.pumpWidget(_harness(buttons: _dock, onTap: (_) {}));

        for (final item in _dock) {
          expect(_keyed(item), findsOneWidget);
        }
      });

      testWidgets('passes the shared size to every NavButton', (tester) async {
        await tester.pumpWidget(_harness(buttons: _dock, onTap: (_) {}));

        for (final item in _dockWithoutMore) {
          expect(_buttonFor(tester, item).size, _size);
        }
        expect(_moreInnerButton(tester).size, _size);
      });

      testWidgets('row height equals size.height', (tester) async {
        await tester.pumpWidget(_harness(buttons: _dock, onTap: (_) {}));

        expect(
          tester.getSize(find.byType(DockRow<_Items>)).height,
          _size.height,
        );
      });

      testWidgets('spaces buttons evenly across the full width', (
        tester,
      ) async {
        await tester.pumpWidget(_harness(buttons: _dock, onTap: (_) {}));

        final rowFinder = find.descendant(
          of: find.byType(DockRow<_Items>),
          matching: find.byType(Row),
        );
        final row = tester.widget<Row>(rowFinder.first);
        final rowWidth = tester.getSize(rowFinder.first).width;
        final left = tester.getTopLeft(_keyed(_Items.home));
        final right = tester.getTopRight(_keyed(_Items.more));

        expect(row.mainAxisAlignment, MainAxisAlignment.spaceEvenly);
        expect(rowWidth, tester.getSize(find.byType(DockRow<_Items>)).width);
        expect(left.dx, greaterThan(0));
        expect(right.dx, lessThan(rowWidth));
      });

      testWidgets('wraps the row in a bottom-only SafeArea', (tester) async {
        await tester.pumpWidget(_harness(buttons: _dock, onTap: (_) {}));

        final safeArea = tester.widget<SafeArea>(
          find.descendant(
            of: find.byType(DockRow<_Items>),
            matching: find.byType(SafeArea),
          ),
        );

        expect(safeArea.top, isFalse);
        expect(safeArea.bottom, isTrue);
      });

      testWidgets('renders an empty row for an empty list', (tester) async {
        await tester.pumpWidget(
          _harness(buttons: const [], overflow: const [], onTap: (_) {}),
        );

        expect(find.byType(NavButton<_Items>), findsNothing);
        expect(find.byType(MoreNavButton<_Items>), findsNothing);
        expect(
          tester.getSize(find.byType(DockRow<_Items>)).height,
          _size.height,
        );
      });
    });

    group('selected', () {
      testWidgets('marks only the selected dock item', (tester) async {
        await tester.pumpWidget(
          _harness(buttons: _dock, onTap: (_) {}, selected: _Items.search),
        );

        for (final item in _dockWithoutMore) {
          expect(
            _buttonFor(tester, item).selected,
            item == _Items.search,
            reason: '$item',
          );
        }
        expect(_moreInnerButton(tester).selected, isFalse);
      });

      testWidgets('marks more when the selected item is in overflow', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(buttons: _dock, onTap: (_) {}, selected: _Items.library),
        );

        expect(_moreButton(tester).selected, _Items.library);
        expect(_moreInnerButton(tester).selected, isTrue);
        for (final item in _dockWithoutMore) {
          expect(_buttonFor(tester, item).selected, isFalse, reason: '$item');
        }
      });

      testWidgets('null selects nothing', (tester) async {
        await tester.pumpWidget(_harness(buttons: _dock, onTap: (_) {}));

        for (final item in _dockWithoutMore) {
          expect(_buttonFor(tester, item).selected, isFalse);
        }
        expect(_moreInnerButton(tester).selected, isFalse);
      });
    });

    group('onTap', () {
      testWidgets('delivers the tapped dock item', (tester) async {
        final taps = <_Items>[];
        await tester.pumpWidget(_harness(buttons: _dock, onTap: taps.add));

        await tester.tap(_keyed(_Items.settings));
        await tester.pump();

        expect(taps, [_Items.settings]);
      });

      testWidgets('tapping more opens the popover and delivers nothing', (
        tester,
      ) async {
        final taps = <_Items>[];
        await tester.pumpWidget(_harness(buttons: _dock, onTap: taps.add));

        await tester.tap(_keyed(_Items.more));
        await tester.pumpAndSettle();

        expect(taps, isEmpty);
        expect(find.text('Library'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      });

      testWidgets('delivers the item picked from the popover', (tester) async {
        final taps = <_Items>[];
        await tester.pumpWidget(_harness(buttons: _dock, onTap: taps.add));

        await tester.tap(_keyed(_Items.more));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        expect(taps, [_Items.profile]);
        expect(find.text('Profile'), findsNothing);
      });

      testWidgets('null disables every button', (tester) async {
        await tester.pumpWidget(_harness(buttons: _dock, onTap: null));

        for (final item in _dockWithoutMore) {
          expect(_buttonFor(tester, item).onTap, isNull);
        }
        expect(_moreButton(tester).onSelect, isNull);
        expect(_moreInnerButton(tester).onTap, isNull);
      });
    });
  });
}

// packages/app_navigation/test/src/dock/dock_destination_buttons_test.dart

import 'package:app_navigation/app_navigation.dart'
    show NavigableDestinationAbstract;
import 'package:app_navigation/src/dock/dock_destination_buttons.dart';
import 'package:app_navigation/src/shared/dual_nav_button.dart';
import 'package:app_navigation/src/shared/dual_overflow_button.dart';
import 'package:app_navigation/src/shared/dual_popover_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _TestDestination implements NavigableDestinationAbstract {
  home(
    caption: 'Home',
    iconData: Icons.home,
    viewBuilder: _buildView,
  ),
  search(
    caption: 'Search',
    iconData: Icons.search,
    viewBuilder: _buildView,
  ),
  settings(
    caption: 'Settings',
    iconData: Icons.settings,
    viewBuilder: _buildView,
  ),
  profile(
    caption: 'Profile',
    iconData: Icons.person,
    viewBuilder: _buildView,
  );

  const _TestDestination({
    required this.caption,
    required this.iconData,
    required this.viewBuilder,
  });

  @override
  final String caption;

  @override
  final IconData iconData;

  @override
  final Widget Function() viewBuilder;

  static Widget _buildView() => const SizedBox.shrink();
}

void main() {
  group('DockDestinationButtons', () {
    Widget buildSubject({
      required List<_TestDestination> visible,
      required _TestDestination selected,
      required ValueChanged<_TestDestination> onSelect,
      List<_TestDestination> overflowed = const [],
      Map<_TestDestination, Size> sizeOverrides = const {},
      MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DockDestinationButtons<_TestDestination>(
            visible: visible,
            selected: selected,
            onSelect: onSelect,
            overflowed: overflowed,
            sizeOverrides: sizeOverrides,
            mainAxisAlignment: mainAxisAlignment,
          ),
        ),
      );
    }

    group('assertions', () {
      testWidgets(
        'throws AssertionError when visible is empty',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildSubject(
              visible: const [],
              selected: _TestDestination.home,
              onSelect: (_) {},
            ),
          );

          expect(tester.takeException(), isAssertionError);
        },
      );

      testWidgets(
        'throws AssertionError when destination is in visible and overflowed',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildSubject(
              visible: const [_TestDestination.home],
              overflowed: const [_TestDestination.home],
              selected: _TestDestination.home,
              onSelect: (_) {},
            ),
          );

          expect(tester.takeException(), isAssertionError);
        },
      );

      testWidgets(
        'throws AssertionError when sizeOverrides key is not in visible',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildSubject(
              visible: const [_TestDestination.home],
              sizeOverrides: const {
                _TestDestination.settings: Size(100, 70),
              },
              selected: _TestDestination.home,
              onSelect: (_) {},
            ),
          );

          expect(tester.takeException(), isAssertionError);
        },
      );
    });

    group('layout and rendering', () {
      testWidgets(
        'renders correct number of DualNavButtons without overflow button',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildSubject(
              visible: const [
                _TestDestination.home,
                _TestDestination.search,
              ],
              selected: _TestDestination.home,
              onSelect: (_) {},
            ),
          );

          expect(find.byType(DualNavButton), findsNWidgets(2));
          expect(
            find.byType(DualOverflowButton<_TestDestination>),
            findsNothing,
          );
          expect(find.text('Home'), findsOneWidget);
          expect(find.text('Search'), findsOneWidget);
          expect(find.byIcon(Icons.home), findsOneWidget);
          expect(find.byIcon(Icons.search), findsOneWidget);
        },
      );

      testWidgets(
        'renders default 80x60 size and respects custom sizeOverrides',
        (WidgetTester tester) async {
          const customSize = Size(96, 72);

          await tester.pumpWidget(
            buildSubject(
              visible: const [
                _TestDestination.home,
                _TestDestination.search,
              ],
              sizeOverrides: const {
                _TestDestination.search: customSize,
              },
              selected: _TestDestination.home,
              onSelect: (_) {},
            ),
          );

          final buttons = tester
              .widgetList<DualNavButton>(find.byType(DualNavButton))
              .toList();

          expect(buttons[0].size, equals(const Size(80, 60)));
          expect(buttons[1].size, equals(customSize));
        },
      );

      testWidgets(
        'applies custom mainAxisAlignment to Row',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildSubject(
              visible: const [_TestDestination.home],
              selected: _TestDestination.home,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              onSelect: (_) {},
            ),
          );

          final row = tester.widget<Row>(find.byType(Row));
          expect(row.mainAxisAlignment, equals(MainAxisAlignment.spaceBetween));
        },
      );

      testWidgets(
        'triggers onSelect callback when visible button is tapped',
        (WidgetTester tester) async {
          _TestDestination? selectedDestination;

          await tester.pumpWidget(
            buildSubject(
              visible: const [
                _TestDestination.home,
                _TestDestination.search,
              ],
              selected: _TestDestination.home,
              onSelect: (destination) => selectedDestination = destination,
            ),
          );

          await tester.tap(find.text('Search'));
          await tester.pump();

          expect(selectedDestination, equals(_TestDestination.search));
        },
      );
    });

    group('overflow rendering and selection', () {
      testWidgets(
        'renders DualOverflowButton and DualPopoverTiles when overflowed'
        ' is non-empty',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildSubject(
              visible: const [
                _TestDestination.home,
                _TestDestination.search,
              ],
              overflowed: const [
                _TestDestination.settings,
                _TestDestination.profile,
              ],
              selected: _TestDestination.home,
              onSelect: (_) {},
            ),
          );

          final overflowFinder = find.byType(
            DualOverflowButton<_TestDestination>,
          );
          expect(overflowFinder, findsOneWidget);

          final overflowWidget = tester
              .widget<DualOverflowButton<_TestDestination>>(overflowFinder);

          expect(overflowWidget.size, equals(const Size(80, 60)));
          expect(overflowWidget.isSelected, isFalse);
          expect(overflowWidget.initialScrollIndex, equals(0));
          expect(overflowWidget.popoverChildren.length, equals(2));

          final firstTile =
              overflowWidget.popoverChildren[0]
                  as DualPopoverTile<_TestDestination>;
          final secondTile =
              overflowWidget.popoverChildren[1]
                  as DualPopoverTile<_TestDestination>;

          expect(firstTile.value, equals(_TestDestination.settings));
          expect(firstTile.isSelected, isFalse);
          expect(secondTile.value, equals(_TestDestination.profile));
          expect(secondTile.isSelected, isFalse);
        },
      );

      testWidgets(
        'marks DualOverflowButton and matching tile selected with '
        'initialScrollIndex when overflowed item is active',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildSubject(
              visible: const [_TestDestination.home],
              overflowed: const [
                _TestDestination.settings,
                _TestDestination.profile,
              ],
              selected: _TestDestination.profile,
              onSelect: (_) {},
            ),
          );

          final overflowFinder = find.byType(
            DualOverflowButton<_TestDestination>,
          );
          final overflowWidget = tester
              .widget<DualOverflowButton<_TestDestination>>(overflowFinder);

          expect(overflowWidget.isSelected, isTrue);
          expect(overflowWidget.initialScrollIndex, equals(1));

          final secondTile =
              overflowWidget.popoverChildren[1]
                  as DualPopoverTile<_TestDestination>;
          expect(secondTile.isSelected, isTrue);
        },
      );

      testWidgets(
        'DualOverflowButton passes onSelect callback through',
        (WidgetTester tester) async {
          _TestDestination? selectedDestination;

          await tester.pumpWidget(
            buildSubject(
              visible: const [_TestDestination.home],
              overflowed: const [_TestDestination.settings],
              selected: _TestDestination.home,
              onSelect: (dest) => selectedDestination = dest,
            ),
          );

          final overflowFinder = find.byType(
            DualOverflowButton<_TestDestination>,
          );
          final overflowWidget = tester
              .widget<DualOverflowButton<_TestDestination>>(overflowFinder);

          overflowWidget.onSelected(_TestDestination.settings);
          expect(selectedDestination, equals(_TestDestination.settings));
        },
      );
    });
  });
}

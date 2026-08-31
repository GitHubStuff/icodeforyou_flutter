// packages/app_navigation/test/src/rail/rail_destination_buttons_test.dart
import 'package:app_navigation/app_navigation.dart';
import 'package:app_navigation/src/shared/dual_nav_button.dart';
import 'package:app_navigation/src/shared/dual_overflow_button.dart';
import 'package:app_navigation/src/shared/dual_popover_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _MockDestination implements NavigableDestinationAbstract {
  home(caption: 'Home', iconData: Icons.home),
  search(caption: 'Search', iconData: Icons.search),
  settings(caption: 'Settings', iconData: Icons.settings),
  profile(caption: 'Profile', iconData: Icons.person);

  const _MockDestination({
    required this.caption,
    required this.iconData,
  });

  @override
  final String caption;

  @override
  final IconData iconData;

  @override
  Widget Function() get viewBuilder =>
      () => Text('$name view');
}

void main() {
  Widget buildSubject({
    required List<_MockDestination> visible,
    required _MockDestination selected,
    required ValueChanged<_MockDestination> onSelect,
    List<_MockDestination> overflowed = const [],
    Map<_MockDestination, Size> sizeOverrides = const {},
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: RailDestinationButtons<_MockDestination>(
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

  group('RailDestinationButtons', () {
    testWidgets(
      'renders visible buttons without overflow button when overflowed is empty',
      (tester) async {
        _MockDestination? selectedDestination;

        await tester.pumpWidget(
          buildSubject(
            visible: const [_MockDestination.home, _MockDestination.search],
            selected: _MockDestination.home,
            onSelect: (dest) => selectedDestination = dest,
          ),
        );

        final flex = tester.widget<Flex>(find.byType(Flex));
        expect(flex.direction, equals(Axis.vertical));
        expect(flex.mainAxisAlignment, equals(MainAxisAlignment.spaceEvenly));

        final navButtons = tester
            .widgetList<DualNavButton>(find.byType(DualNavButton))
            .toList();
        expect(navButtons.length, equals(2));
        expect(find.byType(DualOverflowButton<_MockDestination>), findsNothing);

        // Verify Home button configuration (selected)
        expect(navButtons[0].isSelected, isTrue);
        expect(navButtons[0].size, equals(const Size(80, 60)));
        expect(
          navButtons[0].icon,
          isA<Icon>().having((i) => i.icon, 'icon', Icons.home),
        );
        expect(
          navButtons[0].caption,
          isA<Text>().having((t) => t.data, 'caption', 'Home'),
        );

        // Verify Search button configuration (unselected)
        expect(navButtons[1].isSelected, isFalse);
        expect(navButtons[1].size, equals(const Size(80, 60)));

        // Verify tapping triggers onSelect
        navButtons[1].onPressed();
        expect(selectedDestination, equals(_MockDestination.search));
      },
    );

    testWidgets(
      'renders overflow button and tiles when overflowed is non-empty (selected in visible)',
      (tester) async {
        _MockDestination? selectedDestination;

        await tester.pumpWidget(
          buildSubject(
            visible: const [_MockDestination.home],
            overflowed: const [
              _MockDestination.search,
              _MockDestination.settings,
            ],
            selected: _MockDestination.home,
            onSelect: (dest) => selectedDestination = dest,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        );

        final flex = tester.widget<Flex>(find.byType(Flex));
        expect(flex.mainAxisAlignment, equals(MainAxisAlignment.center));

        final overflowButtonFinder = find.byType(
          DualOverflowButton<_MockDestination>,
        );
        expect(overflowButtonFinder, findsOneWidget);

        final overflowButton = tester
            .widget<DualOverflowButton<_MockDestination>>(
              overflowButtonFinder,
            );

        expect(overflowButton.size, equals(const Size(80, 60)));
        expect(overflowButton.isSelected, isFalse);
        expect(overflowButton.initialScrollIndex, equals(0));
        expect(overflowButton.popoverChildren.length, equals(2));

        // Verify popover tile configurations
        final firstTile =
            overflowButton.popoverChildren[0]
                as DualPopoverTile<_MockDestination>;
        expect(firstTile.value, equals(_MockDestination.search));
        expect(firstTile.isSelected, isFalse);
        expect(
          firstTile.icon,
          isA<Icon>().having((i) => i.icon, 'icon', Icons.search),
        );
        expect(
          firstTile.label,
          isA<Text>().having((t) => t.data, 'label', 'Search'),
        );

        final secondTile =
            overflowButton.popoverChildren[1]
                as DualPopoverTile<_MockDestination>;
        expect(secondTile.value, equals(_MockDestination.settings));
        expect(secondTile.isSelected, isFalse);

        // Verify forwarding onSelect from overflow button
        overflowButton.onSelected(_MockDestination.settings);
        expect(selectedDestination, equals(_MockDestination.settings));
      },
    );

    testWidgets(
      'marks overflow button as selected and computes initialScrollIndex when selected is in overflowed',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            visible: const [_MockDestination.home],
            overflowed: const [
              _MockDestination.search,
              _MockDestination.settings,
              _MockDestination.profile,
            ],
            selected: _MockDestination.profile,
            onSelect: (_) {},
          ),
        );

        final overflowButton = tester
            .widget<DualOverflowButton<_MockDestination>>(
              find.byType(DualOverflowButton<_MockDestination>),
            );

        expect(overflowButton.isSelected, isTrue);
        expect(overflowButton.initialScrollIndex, equals(2));

        final selectedTile =
            overflowButton.popoverChildren[2]
                as DualPopoverTile<_MockDestination>;
        expect(selectedTile.isSelected, isTrue);
      },
    );

    testWidgets(
      'applies sizeOverrides to matching visible buttons',
      (tester) async {
        const customSize = Size(100, 75);

        await tester.pumpWidget(
          buildSubject(
            visible: const [_MockDestination.home, _MockDestination.search],
            selected: _MockDestination.home,
            onSelect: (_) {},
            sizeOverrides: const {
              _MockDestination.search: customSize,
            },
          ),
        );

        final navButtons = tester
            .widgetList<DualNavButton>(find.byType(DualNavButton))
            .toList();
        expect(navButtons[0].size, equals(const Size(80, 60)));
        expect(navButtons[1].size, equals(customSize));
      },
    );

    group('Assertions', () {
      testWidgets('throws AssertionError when visible is empty', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            visible: const [],
            selected: _MockDestination.home,
            onSelect: (_) {},
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
        expect(
          (exception as AssertionError).message,
          equals('visible must contain at least one destination'),
        );
      });

      testWidgets(
        'throws AssertionError when a destination is in both visible and overflowed',
        (tester) async {
          await tester.pumpWidget(
            buildSubject(
              visible: const [_MockDestination.home],
              overflowed: const [_MockDestination.home],
              selected: _MockDestination.home,
              onSelect: (_) {},
            ),
          );

          final exception = tester.takeException();
          expect(exception, isA<AssertionError>());
          expect(
            (exception as AssertionError).message,
            equals('A destination cannot be both visible and overflowed'),
          );
        },
      );

      testWidgets(
        'throws AssertionError when sizeOverrides contains keys not present in visible',
        (tester) async {
          await tester.pumpWidget(
            buildSubject(
              visible: const [_MockDestination.home],
              selected: _MockDestination.home,
              onSelect: (_) {},
              sizeOverrides: const {
                _MockDestination.search: Size(100, 100),
              },
            ),
          );

          final exception = tester.takeException();
          expect(exception, isA<AssertionError>());
          expect(
            (exception as AssertionError).message,
            equals('sizeOverrides may only name members of visible'),
          );
        },
      );
    });
  });
}

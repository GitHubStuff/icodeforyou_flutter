// packages/rail_navigation/test/src/widgets/rail_overflow_button_test.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_button_more.dart';
import 'package:rail_navigation/src/widgets/rail_overflow_button.dart';
import 'package:rail_navigation/src/widgets/rail_popover_tile.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    ),
  );
}

List<Widget> _tiles(int count) {
  return [
    for (var i = 0; i < count; i++)
      RailPopoverTile<String>(value: 'tile_$i', label: Text('Tile $i')),
  ];
}

void main() {
  group('RailOverflowButton', () {
    testWidgets('renders as a MoreRailButton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RailOverflowButton<String>(
            popoverChildren: _tiles(3),
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.byType(MoreRailButton), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('forwards visual parameters to MoreRailButton', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          RailOverflowButton<String>(
            popoverChildren: _tiles(3),
            onSelected: (_) {},
            caption: const Text('Extra'),
            size: const Size(64, 64),
            isSelected: true,
            tint: Colors.amber,
            hapticIntensity: HapticIntensity.none,
          ),
        ),
      );

      final inner = tester.widget<MoreRailButton>(find.byType(MoreRailButton));
      expect(inner.size, const Size(64, 64));
      expect(inner.isSelected, isTrue);
      expect(inner.tint, Colors.amber);
      expect(inner.hapticIntensity, HapticIntensity.none);
      expect(find.text('Extra'), findsOneWidget);
    });

    testWidgets('opens the popover when tapped', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RailOverflowButton<String>(
            popoverChildren: _tiles(3),
            onSelected: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(RailOverflowButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Tile 0'), findsOneWidget);
      expect(find.text('Tile 2'), findsOneWidget);
    });

    testWidgets('opens the popover scrolled to initialScrollIndex', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          RailOverflowButton<String>(
            popoverChildren: _tiles(10),
            onSelected: (_) {},
            initialScrollIndex: 3,
          ),
        ),
      );

      await tester.tap(find.byType(RailOverflowButton<String>));
      await tester.pumpAndSettle();

      final controller = tester
          .widget<ListView>(find.byType(ListView))
          .controller!;
      expect(controller.offset, 3 * 48);
    });

    testWidgets('invokes onSelected with the tapped tile value', (
      tester,
    ) async {
      String? selected;
      var canceled = 0;
      await tester.pumpWidget(
        _wrap(
          RailOverflowButton<String>(
            popoverChildren: _tiles(3),
            onSelected: (value) => selected = value,
            onCanceled: () => canceled++,
          ),
        ),
      );

      await tester.tap(find.byType(RailOverflowButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tile 1'));
      await tester.pumpAndSettle();

      expect(selected, 'tile_1');
      expect(canceled, 0);
      expect(find.text('Tile 1'), findsNothing);
    });

    testWidgets('invokes onCanceled when the popover is dismissed', (
      tester,
    ) async {
      String? selected;
      var canceled = 0;
      await tester.pumpWidget(
        _wrap(
          RailOverflowButton<String>(
            popoverChildren: _tiles(3),
            onSelected: (value) => selected = value,
            onCanceled: () => canceled++,
          ),
        ),
      );

      await tester.tap(find.byType(RailOverflowButton<String>));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(selected, isNull);
      expect(canceled, 1);
    });

    testWidgets('treats dismissal as a no-op when onCanceled is null', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          RailOverflowButton<String>(
            popoverChildren: _tiles(3),
            onSelected: (value) => selected = value,
          ),
        ),
      );

      await tester.tap(find.byType(RailOverflowButton<String>));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(selected, isNull);
      expect(find.text('Tile 0'), findsNothing);
    });

    testWidgets('invokes no callback when unmounted before the popover pops', (
      tester,
    ) async {
      String? selected;
      var canceled = 0;
      var showButton = true;
      late StateSetter setOuterState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setOuterState = setState;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: showButton
                      ? RailOverflowButton<String>(
                          popoverChildren: _tiles(3),
                          onSelected: (value) => selected = value,
                          onCanceled: () => canceled++,
                        )
                      : const SizedBox(),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RailOverflowButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Tile 0'), findsOneWidget);

      setOuterState(() => showButton = false);
      await tester.pump();
      expect(find.byType(RailOverflowButton<String>), findsNothing);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(selected, isNull);
      expect(canceled, 0);
    });
  });
}

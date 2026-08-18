// packages/rail_navigation/test/src/widgets/rail_popover_test.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_popover.dart';
import 'package:rail_navigation/src/widgets/rail_popover_tile.dart';

/// The anchor's key for the current test; reassigned per open.
late GlobalKey _anchorKey;

/// Pumps a screen with a 48x48 anchor at [alignment] and opens a
/// popover of [tileCount] tiles anchored to it.
///
/// Returns the popover's pending future; the popover is fully faded in
/// when this returns.
Future<Future<String?>> _openPopover(
  WidgetTester tester, {
  Alignment alignment = Alignment.bottomCenter,
  int tileCount = 3,
  int initialScrollIndex = 0,
  HapticIntensity scrollHaptic = HapticIntensity.light,
}) async {
  _anchorKey = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: alignment,
          child: SizedBox(key: _anchorKey, width: 48, height: 48),
        ),
      ),
    ),
  );

  final future = showRailPopover<String>(
    anchorContext: _anchorKey.currentContext!,
    initialScrollIndex: initialScrollIndex,
    scrollHaptic: scrollHaptic,
    children: [
      for (var i = 0; i < tileCount; i++)
        RailPopoverTile<String>(value: 'tile_$i', label: Text('Tile $i')),
    ],
  );
  await tester.pumpAndSettle();
  return future;
}

void main() {
  group('showRailPopover', () {
    testWidgets('opens upward from a bottom-edge anchor', (tester) async {
      final future = await _openPopover(tester);

      expect(find.text('Tile 0'), findsOneWidget);

      final anchorRect = tester.getRect(find.byKey(_anchorKey));
      final popoverRect = tester.getRect(find.byType(ListView));
      expect(popoverRect.bottom, lessThan(anchorRect.top));

      Navigator.of(tester.element(find.byType(ListView))).pop();
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('opens rightward from a left-edge anchor', (tester) async {
      final future = await _openPopover(tester, alignment: Alignment.centerLeft);

      final anchorRect = tester.getRect(find.byKey(_anchorKey));
      final popoverRect = tester.getRect(find.byType(ListView));
      expect(popoverRect.left, greaterThan(anchorRect.right));

      Navigator.of(tester.element(find.byType(ListView))).pop();
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('opens leftward from a right-edge anchor', (tester) async {
      final future = await _openPopover(
        tester,
        alignment: Alignment.centerRight,
      );

      final anchorRect = tester.getRect(find.byKey(_anchorKey));
      final popoverRect = tester.getRect(find.byType(ListView));
      expect(popoverRect.right, lessThan(anchorRect.left));

      Navigator.of(tester.element(find.byType(ListView))).pop();
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('completes with the tapped tile value', (tester) async {
      final future = await _openPopover(tester);

      await tester.tap(find.text('Tile 1'));
      await tester.pumpAndSettle();

      expect(await future, 'tile_1');
      expect(find.text('Tile 1'), findsNothing);
    });

    testWidgets('completes with null when the barrier is tapped', (
      tester,
    ) async {
      final future = await _openPopover(tester);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(await future, isNull);
      expect(find.text('Tile 0'), findsNothing);
    });

    testWidgets('caps the surface at six whole tiles and scrolls beyond', (
      tester,
    ) async {
      final future = await _openPopover(tester, tileCount: 10);

      // Six 48dp tiles plus 8dp list padding top and bottom.
      final popoverRect = tester.getRect(find.byType(ListView));
      expect(popoverRect.height, 6 * 48 + 2 * 8);
      expect(popoverRect.width, 240);

      Navigator.of(tester.element(find.byType(ListView))).pop();
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('opens scrolled to initialScrollIndex', (tester) async {
      final future = await _openPopover(
        tester,
        tileCount: 10,
        initialScrollIndex: 3,
      );

      final controller = tester
          .widget<ListView>(find.byType(ListView))
          .controller!;
      expect(controller.offset, 3 * 48);

      Navigator.of(tester.element(find.byType(ListView))).pop();
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('ticks the scroll haptic once per tile height scrolled', (
      tester,
    ) async {
      final hapticCalls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      final future = await _openPopover(tester, tileCount: 10);

      await tester.drag(find.byType(ListView), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(hapticCalls, isNotEmpty);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('never ticks when scrollHaptic is none', (tester) async {
      final hapticCalls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      final future = await _openPopover(
        tester,
        tileCount: 10,
        scrollHaptic: HapticIntensity.none,
      );

      await tester.drag(find.byType(ListView), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(hapticCalls, isEmpty);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('ignores scroll updates that carry no delta', (tester) async {
      final future = await _openPopover(tester, tileCount: 10);

      final listContext = tester.element(find.byType(ListView));
      ScrollUpdateNotification(
        metrics: FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 200,
          pixels: 0,
          viewportDimension: 300,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 3,
        ),
        context: listContext,
      ).dispatch(listContext);
      await tester.pump();

      expect(find.text('Tile 0'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('relayouts when the safe-area padding changes while open', (
      tester,
    ) async {
      final future = await _openPopover(tester);

      final before = tester.getTopLeft(find.byType(ListView));

      tester.view.padding = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.reset);
      await tester.pumpAndSettle();

      final after = tester.getTopLeft(find.byType(ListView));
      expect(after.dy, lessThan(before.dy));

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });
  });
}

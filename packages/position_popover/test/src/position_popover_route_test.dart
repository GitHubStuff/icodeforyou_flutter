// packages/position_popover/test/src/position_popover_route_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:position_popover/src/popover_layout_delegate.dart'
    show PopoverLayoutDelegate;
import 'package:position_popover/src/position_popover_route.dart'
    show PositionPopoverRoute;

void main() {
  const area = Size(400, 800);
  const anchor = Rect.fromLTWH(100, 200, 120, 40);
  const popoverKey = Key('popover');
  const openButtonKey = Key('open');
  const coverKey = Key('cover');
  const transition = Duration(milliseconds: 150);

  PositionPopoverRoute<String> route({
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
    Duration? timeout,
    Alignment alignment = Alignment.center,
  }) {
    return PositionPopoverRoute<String>(
      popover: const _Popover(key: popoverKey),
      anchor: anchor,
      alignment: alignment,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      timeout: timeout,
    );
  }

  /// Pumps a host app whose button pushes [build]'s route and records
  /// the popped value in [results].
  Future<void> pumpHost(
    WidgetTester tester,
    PositionPopoverRoute<String> Function() build,
    List<String?> results,
  ) async {
    await tester.binding.setSurfaceSize(area);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                key: openButtonKey,
                onPressed: () async {
                  final result = await Navigator.of(context).push(build());
                  results.add(result);
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byKey(openButtonKey));
    await tester.pumpAndSettle();
  }

  group('PositionPopoverRoute', () {
    group('getters', () {
      test('expose constructor values', () {
        final r = route(barrierDismissible: false, barrierColor: Colors.red);

        expect(r.barrierDismissible, isFalse);
        expect(r.barrierColor, Colors.red);
        expect(r.barrierLabel, 'Dismiss popover');
        expect(r.transitionDuration, transition);
      });
    });

    group('popping', () {
      testWidgets('popover pops with a value', (tester) async {
        final results = <String?>[];
        await pumpHost(tester, route, results);
        await open(tester);
        expect(find.byKey(popoverKey), findsOneWidget);

        await tester.tap(find.text('pick'));
        await tester.pumpAndSettle();

        expect(find.byKey(popoverKey), findsNothing);
        expect(results, <String?>['picked']);
      });

      testWidgets('barrier tap pops with null when dismissible', (
        tester,
      ) async {
        final results = <String?>[];
        await pumpHost(tester, route, results);
        await open(tester);

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.byKey(popoverKey), findsNothing);
        expect(results, <String?>[null]);
      });

      testWidgets('barrier tap is ignored when not dismissible', (
        tester,
      ) async {
        final results = <String?>[];
        await pumpHost(
          tester,
          () => route(barrierDismissible: false),
          results,
        );
        await open(tester);

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.byKey(popoverKey), findsOneWidget);
        expect(results, isEmpty);
      });
    });

    group('timeout', () {
      testWidgets('stays open indefinitely when timeout is null', (
        tester,
      ) async {
        final results = <String?>[];
        await pumpHost(tester, route, results);
        await open(tester);

        await tester.pump(const Duration(hours: 1));

        expect(find.byKey(popoverKey), findsOneWidget);
        expect(results, isEmpty);
      });

      testWidgets('pops with null once the timeout elapses', (
        tester,
      ) async {
        final results = <String?>[];
        await pumpHost(
          tester,
          () => route(timeout: const Duration(seconds: 2)),
          results,
        );
        await open(tester);

        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(popoverKey), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.byKey(popoverKey), findsNothing);
        expect(results, <String?>[null]);
      });

      testWidgets('does not pop a route that is no longer current', (
        tester,
      ) async {
        final results = <String?>[];
        await pumpHost(
          tester,
          () => route(timeout: const Duration(seconds: 2)),
          results,
        );
        await open(tester);

        final context = tester.element(find.byKey(popoverKey));

        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const SizedBox(key: coverKey),
          ),
        );
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(find.byKey(coverKey), findsOneWidget);
        expect(results, isEmpty);
      });

      testWidgets('cancels the timer when popped early', (
        tester,
      ) async {
        final results = <String?>[];
        await pumpHost(
          tester,
          () => route(timeout: const Duration(seconds: 2)),
          results,
        );
        await open(tester);

        await tester.tap(find.text('pick'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));

        expect(results, <String?>['picked']);
      });
    });

    group('layout', () {
      testWidgets('positions the popover with PopoverLayoutDelegate', (
        tester,
      ) async {
        await pumpHost(
          tester,
          () => route(alignment: Alignment.topCenter),
          <String?>[],
        );
        await open(tester);

        final layout = tester.widget<CustomSingleChildLayout>(
          find.byType(CustomSingleChildLayout),
        );
        final delegate = layout.delegate as PopoverLayoutDelegate;
        expect(delegate.anchor, anchor);
        expect(delegate.alignment, Alignment.topCenter);

        final expected = delegate.getPositionForChild(
          area,
          tester.getSize(find.byKey(popoverKey)),
        );
        expect(tester.getTopLeft(find.byKey(popoverKey)), expected);
      });

      testWidgets('paints the barrier colour', (tester) async {
        await pumpHost(
          tester,
          () => route(barrierColor: Colors.red),
          <String?>[],
        );
        await open(tester);

        final barrier = tester.widget<ModalBarrier>(
          find.byType(ModalBarrier).last,
        );
        expect(barrier.color, Colors.red);
      });
    });

    group('transitions', () {
      testWidgets('fades the page in', (tester) async {
        await pumpHost(tester, route, <String?>[]);
        await tester.tap(find.byKey(openButtonKey));
        await tester.pump();
        await tester.pump(transition ~/ 2);

        final fade = tester.widget<FadeTransition>(
          find.ancestor(
            of: find.byKey(popoverKey),
            matching: find.byType(FadeTransition),
          ),
        );
        expect(fade.opacity.value, greaterThan(0));
        expect(fade.opacity.value, lessThan(1));

        await tester.pumpAndSettle();
        expect(fade.opacity.value, 1);
      });
    });
  });
}

/// A popover with one tile that pops with `'picked'`.
class _Popover extends StatelessWidget {
  const _Popover({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: 200,
        height: 100,
        child: TextButton(
          onPressed: () => Navigator.pop<String>(context, 'picked'),
          child: const Text('pick'),
        ),
      ),
    );
  }
}

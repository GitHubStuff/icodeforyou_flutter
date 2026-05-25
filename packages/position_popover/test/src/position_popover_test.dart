// packages/position_popover/test/src/position_popover_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:position_popover/position_popover.dart';

/// Pumps a screen of [screenSize] containing a single anchor button placed via
/// [anchorAlignment], wires its [GlobalKey], and exposes [showPopover] so each
/// test can trigger a [PositionPopover] against that anchor.
///
/// Using a fixed surface size + an [Align]ed anchor gives deterministic
/// geometry, which is what lets us force each fallback branch precisely.
Future<_Harness> _pumpHarness(
  WidgetTester tester, {
  required Size screenSize,
  Alignment anchorAlignment = Alignment.center,
  Size anchorSize = const Size(80, 40),
  EdgeInsets viewPadding = EdgeInsets.zero,
}) async {
  tester.view.physicalSize = screenSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final anchorKey = GlobalKey();
  PopoverHandle? lastHandle;

  late BuildContext capturedContext;

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: screenSize,
        padding: viewPadding,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) {
                capturedContext = context;
                return Stack(
                  children: [
                    Align(
                      alignment: anchorAlignment,
                      child: SizedBox(
                        key: anchorKey,
                        width: anchorSize.width,
                        height: anchorSize.height,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

  return _Harness(
    tester: tester,
    anchorKey: anchorKey,
    showPopover:
        ({
          PopoverPosition? position,
          required Widget child,
          Size? childSize,
          Color barrierColor = Colors.black54,
          bool barrierDismissible = true,
        }) {
          lastHandle = PositionPopover(
            position: position,
            child: child,
            childSize: childSize,
            barrierColor: barrierColor,
            barrierDismissible: barrierDismissible,
          ).show(capturedContext);
          return lastHandle!;
        },
  );
}

class _Harness {
  _Harness({
    required this.tester,
    required this.anchorKey,
    required this.showPopover,
  });

  final WidgetTester tester;
  final GlobalKey anchorKey;
  final PopoverHandle Function({
    PopoverPosition? position,
    required Widget child,
    Size? childSize,
    Color barrierColor,
    bool barrierDismissible,
  })
  showPopover;
}

/// A child that paints a key we can locate to read its on-screen rect.
class _MarkerChild extends StatelessWidget {
  const _MarkerChild({required this.size, required this.markerKey});

  final Size size;
  final Key markerKey;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: markerKey,
    width: size.width,
    height: size.height,
    // A painted surface so the box is hit-testable: taps land on the child's
    // GestureDetector instead of passing through to the barrier behind it.
    child: const ColoredBox(color: Color(0xFF00FF00)),
  );
}

void main() {
  group('PopoverHandle', () {
    testWidgets('dismiss removes the popover and is idempotent', (
      tester,
    ) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
      );

      final handle = harness.showPopover(
        position: PopoverPosition.center(),
        child: const Text('content'),
      );
      await tester.pump();
      expect(find.text('content'), findsOneWidget);

      // First dismiss: _dismissed false -> removes.
      handle.dismiss();
      await tester.pump();
      expect(find.text('content'), findsNothing);

      // Second dismiss: _dismissed true -> early return, no throw, still gone.
      handle.dismiss();
      await tester.pump();
      expect(find.text('content'), findsNothing);
    });
  });

  group('PositionPopover.show', () {
    testWidgets('inserts into the overlay and renders the child', (
      tester,
    ) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
      );

      harness.showPopover(
        position: PopoverPosition.center(),
        child: const Text('hello'),
      );
      await tester.pump();

      expect(find.text('hello'), findsOneWidget);
    });
  });

  group('_PositionPopoverLayer', () {
    testWidgets('null position defaults to centered', (tester) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
      );

      const markerKey = ValueKey('marker');
      harness.showPopover(
        child: const _MarkerChild(size: Size(100, 100), markerKey: markerKey),
      );
      await tester.pump();

      final rect = tester.getRect(find.byKey(markerKey));
      // Centered on an 800x600 safe area => topLeft (350, 250).
      expect(rect.left, closeTo(350, 0.5));
      expect(rect.top, closeTo(250, 0.5));
    });

    testWidgets('barrier tap dismisses when barrierDismissible is true', (
      tester,
    ) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
      );

      harness.showPopover(
        position: PopoverPosition.center(),
        child: const Text('dismiss-me'),
      );
      await tester.pump();
      expect(find.text('dismiss-me'), findsOneWidget);

      // Tap a corner well outside the centered child => hits the barrier.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.text('dismiss-me'), findsNothing);
    });

    testWidgets('barrier tap is a no-op when barrierDismissible is false', (
      tester,
    ) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
      );

      harness.showPopover(
        position: PopoverPosition.center(),
        barrierDismissible: false,
        child: const Text('stay'),
      );
      await tester.pump();
      expect(find.text('stay'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      // Still present: onTap was null, so the barrier swallowed nothing.
      expect(find.text('stay'), findsOneWidget);
    });

    testWidgets('tapping the child does not dismiss (swallowed)', (
      tester,
    ) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
      );

      const markerKey = ValueKey('child-tap');
      harness.showPopover(
        position: PopoverPosition.center(),
        child: const _MarkerChild(size: Size(120, 120), markerKey: markerKey),
      );
      await tester.pump();

      await tester.tap(find.byKey(markerKey));
      await tester.pump();
      // The inner GestureDetector swallows the tap; popover remains.
      expect(find.byKey(markerKey), findsOneWidget);
    });

    testWidgets(
      'dismisses when anchor key is not laid out (anchorRect == null)',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // A GlobalKey that is never attached to a render object.
        final orphanKey = GlobalKey();
        late BuildContext context;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (ctx) {
                      context = ctx;
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );

        PositionPopover(
          position: PopoverPosition.left(orphanKey),
          child: const Text('never-shown'),
        ).show(context);

        // First pump builds the layer (anchorRect null -> schedules dismiss).
        await tester.pump();
        // Second pump runs the post-frame callback that dismisses.
        await tester.pump();

        expect(find.text('never-shown'), findsNothing);
      },
    );

    testWidgets('dismisses when anchor is laid out but fully off-screen '
        '(no overlap)', (tester) async {
      // Anchor sits at top-left but we shrink the safe area via padding so
      // huge that the anchor rect no longer overlaps it.
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final anchorKey = GlobalKey();
      late BuildContext context;

      await tester.pumpWidget(
        MediaQuery(
          // Padding larger than the anchor's position pushes the safe area
          // entirely below/right of the top-left anchor => no overlap.
          data: const MediaQueryData(
            size: Size(800, 600),
            padding: EdgeInsets.only(left: 400, top: 400),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (ctx) {
                    context = ctx;
                    return Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        key: anchorKey,
                        width: 20,
                        height: 20,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      PositionPopover(
        position: PopoverPosition.left(anchorKey),
        child: const Text('offscreen-anchor'),
      ).show(context);

      await tester.pump();
      await tester.pump();

      expect(find.text('offscreen-anchor'), findsNothing);
    });
  });

  group('PopoverPosition factories + layout placement', () {
    testWidgets('left: placed to the left of the anchor', (tester) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
        anchorAlignment: Alignment.centerRight,
        anchorSize: const Size(60, 40),
      );

      const markerKey = ValueKey('left');
      harness.showPopover(
        position: PopoverPosition.left(harness.anchorKey),
        child: const _MarkerChild(size: Size(100, 80), markerKey: markerKey),
      );
      await tester.pump();

      final anchorRect = tester.getRect(find.byKey(harness.anchorKey));
      final childRect = tester.getRect(find.byKey(markerKey));
      // Right edge of child should meet the left edge of the anchor.
      expect(childRect.right, closeTo(anchorRect.left, 0.5));
    });

    testWidgets('right: placed to the right of the anchor', (tester) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
        anchorAlignment: Alignment.centerLeft,
        anchorSize: const Size(60, 40),
      );

      const markerKey = ValueKey('right');
      harness.showPopover(
        position: PopoverPosition.right(harness.anchorKey),
        child: const _MarkerChild(size: Size(100, 80), markerKey: markerKey),
      );
      await tester.pump();

      final anchorRect = tester.getRect(find.byKey(harness.anchorKey));
      final childRect = tester.getRect(find.byKey(markerKey));
      expect(childRect.left, closeTo(anchorRect.right, 0.5));
    });

    testWidgets('above: placed above the anchor', (tester) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
        anchorAlignment: Alignment.bottomCenter,
        anchorSize: const Size(60, 40),
      );

      const markerKey = ValueKey('above');
      harness.showPopover(
        position: PopoverPosition.above(harness.anchorKey),
        child: const _MarkerChild(size: Size(100, 80), markerKey: markerKey),
      );
      await tester.pump();

      final anchorRect = tester.getRect(find.byKey(harness.anchorKey));
      final childRect = tester.getRect(find.byKey(markerKey));
      expect(childRect.bottom, closeTo(anchorRect.top, 0.5));
    });

    testWidgets('below: placed below the anchor', (tester) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
        anchorAlignment: Alignment.topCenter,
        anchorSize: const Size(60, 40),
      );

      const markerKey = ValueKey('below');
      harness.showPopover(
        position: PopoverPosition.below(harness.anchorKey),
        child: const _MarkerChild(size: Size(100, 80), markerKey: markerKey),
      );
      await tester.pump();

      final anchorRect = tester.getRect(find.byKey(harness.anchorKey));
      final childRect = tester.getRect(find.byKey(markerKey));
      expect(childRect.top, closeTo(anchorRect.bottom, 0.5));
    });

    testWidgets('center: ignores anchor and centers', (tester) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
        anchorAlignment: Alignment.topLeft,
      );

      const markerKey = ValueKey('center');
      harness.showPopover(
        position: PopoverPosition.center(),
        child: const _MarkerChild(size: Size(200, 100), markerKey: markerKey),
      );
      await tester.pump();

      final rect = tester.getRect(find.byKey(markerKey));
      expect(rect.center.dx, closeTo(400, 0.5));
      expect(rect.center.dy, closeTo(300, 0.5));
    });
  });

  group('Fallback chains', () {
    testWidgets('left falls back to below when there is no room on the left', (
      tester,
    ) async {
      // Anchor hugs the left edge; a wide child cannot fit to its left, so the
      // chain (left -> bottom -> top -> center) lands on below.
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
        anchorAlignment: Alignment.centerLeft,
        anchorSize: const Size(40, 40),
      );

      const markerKey = ValueKey('left-fallback');
      harness.showPopover(
        position: PopoverPosition.left(harness.anchorKey),
        child: const _MarkerChild(size: Size(120, 80), markerKey: markerKey),
      );
      await tester.pump();

      final anchorRect = tester.getRect(find.byKey(harness.anchorKey));
      final childRect = tester.getRect(find.byKey(markerKey));
      // Fell back to below: child top meets anchor bottom.
      expect(childRect.top, closeTo(anchorRect.bottom, 0.5));
    });

    testWidgets('above falls back to below when no room above', (tester) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
        anchorAlignment: Alignment.topCenter,
        anchorSize: const Size(60, 30),
      );

      const markerKey = ValueKey('above-fallback');
      harness.showPopover(
        position: PopoverPosition.above(harness.anchorKey),
        child: const _MarkerChild(size: Size(100, 120), markerKey: markerKey),
      );
      await tester.pump();

      final anchorRect = tester.getRect(find.byKey(harness.anchorKey));
      final childRect = tester.getRect(find.byKey(markerKey));
      expect(childRect.top, closeTo(anchorRect.bottom, 0.5));
    });

    testWidgets('below falls back to above when no room below', (tester) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(800, 600),
        anchorAlignment: Alignment.bottomCenter,
        anchorSize: const Size(60, 30),
      );

      const markerKey = ValueKey('below-fallback');
      harness.showPopover(
        position: PopoverPosition.below(harness.anchorKey),
        child: const _MarkerChild(size: Size(100, 120), markerKey: markerKey),
      );
      await tester.pump();

      final anchorRect = tester.getRect(find.byKey(harness.anchorKey));
      final childRect = tester.getRect(find.byKey(markerKey));
      expect(childRect.bottom, closeTo(anchorRect.top, 0.5));
    });

    testWidgets(
      'every side fails -> getPositionForChild falls through to center',
      (tester) async {
        // Tiny safe area + anchor that overlaps it, but a child explicitly sized
        // larger than the whole bounds on both axes => no side fits AND the
        // center rect itself does not "contain" (but center is the final
        // return, not gated by contains). This drives the loop to exhaust.
        final harness = await _pumpHarness(
          tester,
          screenSize: const Size(200, 200),
          anchorAlignment: Alignment.center,
          anchorSize: const Size(40, 40),
        );

        const markerKey = ValueKey('center-fallthrough');
        harness.showPopover(
          position: PopoverPosition.left(harness.anchorKey),
          // Forced size bigger than bounds; getConstraints clamps to bounds, but
          // we still want a child that cannot fit any side -> use childSize that
          // makes the laid-out size fill bounds so no side has room.
          childSize: const Size(200, 200),
          child: const _MarkerChild(size: Size(200, 200), markerKey: markerKey),
        );
        await tester.pump();

        final childRect = tester.getRect(find.byKey(markerKey));
        // Centered within the 200x200 area.
        expect(childRect.center.dx, closeTo(100, 1.0));
        expect(childRect.center.dy, closeTo(100, 1.0));
      },
    );

    testWidgets(
      'inverted clamp range: child taller than bounds on cross axis',
      (tester) async {
        // Place left with a child taller than the safe area height. _clamp gets
        // max (= bottom - height) < min (= top) -> returns min. Then the left
        // rect still will not fit (too tall) -> fallback proceeds, but the
        // _clamp inverted branch has executed.
        final harness = await _pumpHarness(
          tester,
          screenSize: const Size(800, 200),
          anchorAlignment: Alignment.centerRight,
          anchorSize: const Size(40, 40),
        );

        const markerKey = ValueKey('inverted-clamp');
        harness.showPopover(
          position: PopoverPosition.left(harness.anchorKey),
          childSize: const Size(100, 300),
          child: const _MarkerChild(size: Size(100, 300), markerKey: markerKey),
        );
        await tester.pump();

        // Just assert it rendered; the branch coverage is the point.
        expect(find.byKey(markerKey), findsOneWidget);
      },
    );
  });

  group('childSize defaulting', () {
    testWidgets('null childSize defaults to 80% x 50% of the safe area', (
      tester,
    ) async {
      // A child that wants to be huge gets capped at 80% width / 50% height.
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(1000, 800),
      );

      const markerKey = ValueKey('default-size');
      harness.showPopover(
        position: PopoverPosition.center(),
        child: const _MarkerChild(
          size: Size(5000, 5000),
          markerKey: markerKey,
        ),
      );
      await tester.pump();

      final rect = tester.getRect(find.byKey(markerKey));
      expect(rect.width, closeTo(800, 1.0)); // 80% of 1000
      expect(rect.height, closeTo(400, 1.0)); // 50% of 800
    });

    testWidgets('safe-area padding shrinks the resolved bounds', (
      tester,
    ) async {
      final harness = await _pumpHarness(
        tester,
        screenSize: const Size(1000, 800),
        viewPadding: const EdgeInsets.only(top: 100, bottom: 100),
      );

      const markerKey = ValueKey('padded-default');
      harness.showPopover(
        position: PopoverPosition.center(),
        child: const _MarkerChild(
          size: Size(5000, 5000),
          markerKey: markerKey,
        ),
      );
      await tester.pump();

      final rect = tester.getRect(find.byKey(markerKey));
      // Safe area height = 800 - 200 = 600; 50% => 300.
      expect(rect.height, closeTo(300, 1.0));
      // Width unaffected: 80% of 1000 => 800.
      expect(rect.width, closeTo(800, 1.0));
    });
  });

  group('shouldRelayout (delegate identity vs change)', () {
    // Mounts a single popover layer whose MediaQuery size is driven by a
    // StatefulBuilder. Mutating the size rebuilds the SAME
    // CustomSingleChildLayout element with a NEW delegate, which is the only
    // path that makes the framework call shouldRelayout.
    testWidgets('relayouts when the safe-area bounds change', (tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      late StateSetter setSize;
      var size = const Size(800, 600);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setSize = setState;
            return MediaQuery(
              data: MediaQueryData(size: size),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (ctx) {
                        // Show exactly once, on first build.
                        return _RelayoutHost(overlayContext: ctx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pump(); // run post-frame show()
      await tester.pump(); // build the inserted overlay entry

      const markerKey = _RelayoutHost.markerKey;
      final before = tester.getRect(find.byKey(markerKey));

      // Change the safe-area size -> new bounds -> the layer rebuilds with a
      // new delegate, so the framework calls shouldRelayout. The centered
      // popover recenters within the smaller area, proving the relayout ran.
      setSize(() => size = const Size(600, 400));
      await tester.pump();
      final after = tester.getRect(find.byKey(markerKey));
      expect(after.center, isNot(equals(before.center)));
    });
  });
}

/// Host that inserts a single centered popover into [overlayContext] once and
/// keeps it mounted across rebuilds, so the popover layer rebuilds in place
/// (rather than being torn down and recreated) when the ambient MediaQuery
/// changes — the condition needed to exercise shouldRelayout.
class _RelayoutHost extends StatefulWidget {
  const _RelayoutHost({required this.overlayContext});

  final BuildContext overlayContext;

  static const markerKey = ValueKey('relayout-marker');

  @override
  State<_RelayoutHost> createState() => _RelayoutHostState();
}

class _RelayoutHostState extends State<_RelayoutHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PositionPopover(
        position: PopoverPosition.center(),
        child: const _MarkerChild(
          size: Size(100, 100),
          markerKey: _RelayoutHost.markerKey,
        ),
      ).show(widget.overlayContext);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

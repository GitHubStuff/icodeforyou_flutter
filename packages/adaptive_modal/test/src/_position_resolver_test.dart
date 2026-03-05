// test/src/_position_resolver_test.dart
import 'package:adaptive_modal/src/_platform_detector.dart';
import 'package:adaptive_modal/src/_position_resolver.dart';
import 'package:adaptive_modal/src/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a minimal widget tree with [screenSize] and an anchor [GlobalKey]
/// positioned at [anchorOffset] with [anchorSize], then calls [test] with
/// the BuildContext and the anchor key.
///
/// Screen size is injected via [MediaQuery] so [ScreenSize.of] reads correctly.
/// The anchor is a real [SizedBox] rendered at [anchorOffset] so
/// [RenderBox.localToGlobal] returns a meaningful value.
Future<void> pumpWithAnchor(
  WidgetTester tester, {
  required Size screenSize,
  required Offset anchorOffset,
  required Size anchorSize,
  required Future<void> Function(BuildContext ctx, GlobalKey anchorKey) test,
}) async {
  final anchorKey = GlobalKey();
  late BuildContext captured;

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Positioned(
              left: anchorOffset.dx,
              top: anchorOffset.dy,
              child: SizedBox(
                key: anchorKey,
                width: anchorSize.width,
                height: anchorSize.height,
              ),
            ),
            Builder(builder: (ctx) {
              captured = ctx;
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    ),
  );

  await test(captured, anchorKey);
}

void main() {
  // -------------------------------------------------------------------------
  // ModalPlacement — value object
  // -------------------------------------------------------------------------

  group('ModalPlacement', () {
    test('stores left, top and position', () {
      const p = ModalPlacement(left: 10, top: 20, position: AdaptiveModalPosition.below);
      expect(p.left, 10);
      expect(p.top, 20);
      expect(p.position, AdaptiveModalPosition.below);
    });
  });

  // -------------------------------------------------------------------------
  // PositionResolver — phone (narrow screen)
  // -------------------------------------------------------------------------

  group('PositionResolver.resolve — phone layout', () {
    testWidgets('returns fullScreen placement on narrow screen', (tester) async {
      await pumpWithAnchor(
        tester,
        screenSize: const Size(390, 844),
        anchorOffset: const Offset(100, 400),
        anchorSize: const Size(150, 48),
        test: (ctx, key) async {
          final placement = PositionResolver.resolve(
            anchorKey: key,
            context: ctx,
            modalWidth: 400,
            modalHeight: 700,
          );
          expect(placement, isNotNull);
          expect(placement!.position, AdaptiveModalPosition.fullScreen);
          expect(placement.left, 0);
          expect(placement.top, 0);
        },
      );
    });

    testWidgets('returns fullScreen even when anchor has space below', (tester) async {
      await pumpWithAnchor(
        tester,
        screenSize: const Size(375, 812),
        anchorOffset: const Offset(50, 100),
        anchorSize: const Size(100, 44),
        test: (ctx, key) async {
          final placement = PositionResolver.resolve(
            anchorKey: key,
            context: ctx,
            modalWidth: 300,
            modalHeight: 400,
          );
          expect(placement!.position, AdaptiveModalPosition.fullScreen);
        },
      );
    });
  });

  // -------------------------------------------------------------------------
  // PositionResolver — large screen, placement below
  // -------------------------------------------------------------------------

  group('PositionResolver.resolve — below anchor', () {
    testWidgets('places modal below when space is sufficient', (tester) async {
      // Screen 1024×768, anchor at y=100 height=48 → bottom=148.
      // Space below = 768 - 148 = 620. Modal height = 300. 620 >= 300+8 ✓
      await pumpWithAnchor(
        tester,
        screenSize: const Size(1024, 768),
        anchorOffset: const Offset(400, 100),
        anchorSize: const Size(150, 48),
        test: (ctx, key) async {
          final placement = PositionResolver.resolve(
            anchorKey: key,
            context: ctx,
            modalWidth: 300,
            modalHeight: 300,
          );
          expect(placement!.position, AdaptiveModalPosition.below);
          // top = anchor.bottom + 8 = 148 + 8 = 156
          expect(placement.top, closeTo(156, 2));
        },
      );
    });

    testWidgets('left is clamped to 0 when modal would overflow left edge', (tester) async {
      // Anchor centered at x=10 with modalWidth=300 → left = 10 - 150 = -140 → clamp to 0.
      await pumpWithAnchor(
        tester,
        screenSize: const Size(1024, 768),
        anchorOffset: const Offset(0, 100),
        anchorSize: const Size(20, 48),
        test: (ctx, key) async {
          final placement = PositionResolver.resolve(
            anchorKey: key,
            context: ctx,
            modalWidth: 300,
            modalHeight: 200,
          );
          expect(placement!.left, greaterThanOrEqualTo(0));
        },
      );
    });

    testWidgets('left is clamped when modal would overflow right edge', (tester) async {
      // Anchor at x=950 on a 1024px screen with modalWidth=300 would go to 1100 → clamped.
      await pumpWithAnchor(
        tester,
        screenSize: const Size(1024, 768),
        anchorOffset: const Offset(950, 100),
        anchorSize: const Size(74, 48),
        test: (ctx, key) async {
          final placement = PositionResolver.resolve(
            anchorKey: key,
            context: ctx,
            modalWidth: 300,
            modalHeight: 200,
          );
          expect(placement!.left, lessThanOrEqualTo(1024 - 300));
        },
      );
    });
  });

  // -------------------------------------------------------------------------
  // PositionResolver — large screen, placement above
  // -------------------------------------------------------------------------

  group('PositionResolver.resolve — above anchor', () {
    testWidgets('flips above when insufficient space below but more above', (tester) async {
      // Screen 1024×768. Anchor at y=650 height=48 → bottom=698.
      // Space below = 768 - 698 = 70. Modal height = 300. 70 < 308 (doesn't fit).
      // Space above = 650. 650 > 70 → place above.
      await pumpWithAnchor(
        tester,
        screenSize: const Size(1024, 768),
        anchorOffset: const Offset(400, 650),
        anchorSize: const Size(150, 48),
        test: (ctx, key) async {
          final placement = PositionResolver.resolve(
            anchorKey: key,
            context: ctx,
            modalWidth: 300,
            modalHeight: 300,
          );
          expect(placement!.position, AdaptiveModalPosition.above);
          // top = anchor.top - 8 - modalHeight = 650 - 8 - 300 = 342
          expect(placement.top, closeTo(342, 2));
        },
      );
    });
  });

  // -------------------------------------------------------------------------
  // PositionResolver — clamp edge cases (widgetbook-style small viewports)
  // -------------------------------------------------------------------------

  group('PositionResolver.resolve — clamp safety', () {
    testWidgets('does not crash when modal taller than screen', (tester) async {
      // This is the bug that caused ArgumentError in widgetbook viewports.
      await pumpWithAnchor(
        tester,
        screenSize: const Size(1024, 400),
        anchorOffset: const Offset(400, 150),
        anchorSize: const Size(150, 48),
        test: (ctx, key) async {
          expect(
            () => PositionResolver.resolve(
              anchorKey: key,
              context: ctx,
              modalWidth: 300,
              modalHeight: 700, // taller than screen
            ),
            returnsNormally,
          );
        },
      );
    });

    testWidgets('does not crash when modal wider than screen', (tester) async {
      await pumpWithAnchor(
        tester,
        screenSize: const Size(300, 768),
        anchorOffset: const Offset(100, 100),
        anchorSize: const Size(100, 48),
        test: (ctx, key) async {
          expect(
            () => PositionResolver.resolve(
              anchorKey: key,
              context: ctx,
              modalWidth: 400, // wider than screen
              modalHeight: 300,
            ),
            returnsNormally,
          );
        },
      );
    });

    testWidgets('left is never negative', (tester) async {
      await pumpWithAnchor(
        tester,
        screenSize: const Size(1024, 768),
        anchorOffset: Offset.zero,
        anchorSize: const Size(10, 10),
        test: (ctx, key) async {
          final placement = PositionResolver.resolve(
            anchorKey: key,
            context: ctx,
            modalWidth: 400,
            modalHeight: 300,
          );
          expect(placement!.left, greaterThanOrEqualTo(0));
        },
      );
    });

    testWidgets('top is never less than safeTop (0 in test)', (tester) async {
      await pumpWithAnchor(
        tester,
        screenSize: const Size(1024, 768),
        anchorOffset: const Offset(400, 5),
        anchorSize: const Size(150, 48),
        test: (ctx, key) async {
          final placement = PositionResolver.resolve(
            anchorKey: key,
            context: ctx,
            modalWidth: 300,
            modalHeight: 700,
          );
          expect(placement!.top, greaterThanOrEqualTo(0));
        },
      );
    });
  });

  // -------------------------------------------------------------------------
  // PositionResolver — null anchor (unmounted key)
  // -------------------------------------------------------------------------

  group('PositionResolver.resolve — null anchor', () {
    testWidgets('returns null when anchor key has no context', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1024, 768)),
          child: Builder(builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          }),
        ),
      );

      final orphanKey = GlobalKey(); // never attached to a widget
      final placement = PositionResolver.resolve(
        anchorKey: orphanKey,
        context: ctx,
        modalWidth: 300,
        modalHeight: 300,
      );
      expect(placement, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // PositionResolver — prefers below when tied (spaceBelow == spaceAbove)
  // -------------------------------------------------------------------------

  group('PositionResolver.resolve — tie-breaking', () {
    testWidgets('places below when spaceBelow equals spaceAbove', (tester) async {
      // Screen height 600. Anchor at y=300 height=0 → bottom=300.
      // spaceBelow = 600 - 300 = 300. spaceAbove = 300. Equal → prefer below.
      await pumpWithAnchor(
        tester,
        screenSize: const Size(1024, 600),
        anchorOffset: const Offset(400, 300),
        anchorSize: const Size(150, 1),
        test: (ctx, key) async {
          final placement = PositionResolver.resolve(
            anchorKey: key,
            context: ctx,
            modalWidth: 300,
            modalHeight: 50, // small so it fits below
          );
          expect(placement!.position, AdaptiveModalPosition.below);
        },
      );
    });
  });
}

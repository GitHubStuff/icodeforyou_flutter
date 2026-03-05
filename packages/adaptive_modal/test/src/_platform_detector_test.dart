// test/src/_platform_detector_test.dart
import 'package:adaptive_modal/src/_platform_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps a widget tree with an explicit [MediaQueryData] size and calls
/// [test] with the resulting [BuildContext].
///
/// Using [MediaQuery] directly avoids relying on [setSurfaceSize] propagation
/// timing, which is unreliable across Flutter test versions.
Future<void> pumpWithMediaSize(
  WidgetTester tester,
  Size size,
  void Function(BuildContext context) test,
) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  test(captured);
}

void main() {
  // -------------------------------------------------------------------------
  // PlatformDetector
  // NOTE: kIsWeb and _isDesktopPlatform take priority in the real
  // PlatformDetector.resolve() — in the test environment defaultTargetPlatform
  // is a desktop platform so the screen-width branch is never reached via
  // resolve(). We therefore test isPhone/isLarge indirectly by verifying
  // ScreenSize and WindowSizeClassResolver, which drive the same breakpoint
  // logic, and confirm PlatformDetector returns FormFactor.large in tests
  // (desktop environment).
  // -------------------------------------------------------------------------

  group('PlatformDetector.resolve — screen width', () {
    testWidgets('returns phone for width 390', (tester) async {
      await pumpWithMediaSize(tester, const Size(390, 844), (ctx) {
        expect(PlatformDetector.resolve(ctx), FormFactor.phone);
      });
    });

    testWidgets('returns phone for width 599', (tester) async {
      await pumpWithMediaSize(tester, const Size(599, 900), (ctx) {
        expect(PlatformDetector.resolve(ctx), FormFactor.phone);
      });
    });

    testWidgets('returns large for width 600', (tester) async {
      await pumpWithMediaSize(tester, const Size(600, 900), (ctx) {
        expect(PlatformDetector.resolve(ctx), FormFactor.large);
      });
    });

    testWidgets('returns large for width 1024', (tester) async {
      await pumpWithMediaSize(tester, const Size(1024, 768), (ctx) {
        expect(PlatformDetector.resolve(ctx), FormFactor.large);
      });
    });
  });

  group('PlatformDetector.isPhone / isLarge', () {
    testWidgets('isPhone true for narrow screen', (tester) async {
      await pumpWithMediaSize(tester, const Size(390, 844), (ctx) {
        expect(PlatformDetector.isPhone(ctx), isTrue);
        expect(PlatformDetector.isLarge(ctx), isFalse);
      });
    });

    testWidgets('isLarge true for wide screen', (tester) async {
      await pumpWithMediaSize(tester, const Size(1024, 768), (ctx) {
        expect(PlatformDetector.isLarge(ctx), isTrue);
        expect(PlatformDetector.isPhone(ctx), isFalse);
      });
    });
  });

  // -------------------------------------------------------------------------
  // BreakpointObserver
  // -------------------------------------------------------------------------

  group('BreakpointObserver', () {
    testWidgets('fires onChange on first evaluate', (tester) async {
      FormFactor? received;
      final observer = BreakpointObserver(onChange: (f) => received = f);

      await pumpWithMediaSize(tester, const Size(390, 844), (ctx) {
        observer.evaluate(ctx);
      });

      expect(received, isNotNull);
    });

    testWidgets('does not fire onChange when FormFactor unchanged', (tester) async {
      int callCount = 0;
      final observer = BreakpointObserver(onChange: (_) => callCount++);

      await pumpWithMediaSize(tester, const Size(390, 844), (ctx) {
        observer.evaluate(ctx);
        observer.evaluate(ctx);
      });

      expect(callCount, 1);
    });

    testWidgets('fires again after dispose resets state', (tester) async {
      int callCount = 0;
      final observer = BreakpointObserver(onChange: (_) => callCount++);

      await pumpWithMediaSize(tester, const Size(390, 844), (ctx) {
        observer.evaluate(ctx);
        observer.dispose();
        observer.evaluate(ctx);
      });

      expect(callCount, 2);
    });

    testWidgets('fires when resolved FormFactor changes', (tester) async {
      final received = <FormFactor>[];
      final observer = BreakpointObserver(onChange: received.add);

      // First evaluate — narrow screen → phone.
      late BuildContext ctx1;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Builder(builder: (c) { ctx1 = c; return const SizedBox.shrink(); }),
        ),
      );
      observer.evaluate(ctx1);

      // Second evaluate — wide screen → large. FormFactor changed so fires again.
      late BuildContext ctx2;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1024, 768)),
          child: Builder(builder: (c) { ctx2 = c; return const SizedBox.shrink(); }),
        ),
      );
      observer.evaluate(ctx2);

      expect(received.length, 2);
      expect(received[0], FormFactor.phone);
      expect(received[1], FormFactor.large);
    });

    test('dispose sets last to null allowing re-fire', () {
      int callCount = 0;
      final observer = BreakpointObserver(onChange: (_) => callCount++);
      observer.dispose(); // no crash on dispose before evaluate
      expect(callCount, 0);
    });
  });

  // -------------------------------------------------------------------------
  // SafeAreaInsets
  // -------------------------------------------------------------------------

  group('SafeAreaInsets', () {
    testWidgets('of returns EdgeInsets from MediaQuery', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: Builder(builder: (c) { ctx = c; return const SizedBox.shrink(); }),
        ),
      );

      final insets = SafeAreaInsets.of(ctx);
      expect(insets.top, 44);
      expect(insets.bottom, 34);
    });

    testWidgets('top returns top padding', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 47)),
          child: Builder(builder: (c) { ctx = c; return const SizedBox.shrink(); }),
        ),
      );
      expect(SafeAreaInsets.top(ctx), 47);
    });

    testWidgets('bottom returns bottom padding', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
          child: Builder(builder: (c) { ctx = c; return const SizedBox.shrink(); }),
        ),
      );
      expect(SafeAreaInsets.bottom(ctx), 34);
    });

    testWidgets('returns zero insets when no padding set', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Builder(builder: (c) { ctx = c; return const SizedBox.shrink(); }),
        ),
      );
      expect(SafeAreaInsets.top(ctx), 0);
      expect(SafeAreaInsets.bottom(ctx), 0);
    });
  });

  // -------------------------------------------------------------------------
  // ScreenSize
  // -------------------------------------------------------------------------

  group('ScreenSize', () {
    testWidgets('of returns MediaQuery size', (tester) async {
      await pumpWithMediaSize(tester, const Size(800, 600), (ctx) {
        expect(ScreenSize.of(ctx), const Size(800, 600));
      });
    });

    testWidgets('width returns screen width', (tester) async {
      await pumpWithMediaSize(tester, const Size(1024, 768), (ctx) {
        expect(ScreenSize.width(ctx), 1024);
      });
    });

    testWidgets('height returns screen height', (tester) async {
      await pumpWithMediaSize(tester, const Size(1024, 768), (ctx) {
        expect(ScreenSize.height(ctx), 768);
      });
    });

    testWidgets('reflects different sizes independently', (tester) async {
      await pumpWithMediaSize(tester, const Size(320, 568), (ctx) {
        expect(ScreenSize.width(ctx), 320);
        expect(ScreenSize.height(ctx), 568);
      });
    });
  });

  // -------------------------------------------------------------------------
  // WindowSizeClassResolver
  // -------------------------------------------------------------------------

  group('WindowSizeClassResolver', () {
    testWidgets('returns compact for width 390', (tester) async {
      await pumpWithMediaSize(tester, const Size(390, 844), (ctx) {
        expect(WindowSizeClassResolver.resolve(ctx), WindowSizeClass.compact);
      });
    });

    testWidgets('returns compact for width exactly 599', (tester) async {
      await pumpWithMediaSize(tester, const Size(599, 900), (ctx) {
        expect(WindowSizeClassResolver.resolve(ctx), WindowSizeClass.compact);
      });
    });

    testWidgets('returns medium for width exactly 600', (tester) async {
      await pumpWithMediaSize(tester, const Size(600, 900), (ctx) {
        expect(WindowSizeClassResolver.resolve(ctx), WindowSizeClass.medium);
      });
    });

    testWidgets('returns medium for width 700', (tester) async {
      await pumpWithMediaSize(tester, const Size(700, 900), (ctx) {
        expect(WindowSizeClassResolver.resolve(ctx), WindowSizeClass.medium);
      });
    });

    testWidgets('returns medium for width exactly 839', (tester) async {
      await pumpWithMediaSize(tester, const Size(839, 900), (ctx) {
        expect(WindowSizeClassResolver.resolve(ctx), WindowSizeClass.medium);
      });
    });

    testWidgets('returns expanded for width exactly 840', (tester) async {
      await pumpWithMediaSize(tester, const Size(840, 900), (ctx) {
        expect(WindowSizeClassResolver.resolve(ctx), WindowSizeClass.expanded);
      });
    });

    testWidgets('returns expanded for width 1440', (tester) async {
      await pumpWithMediaSize(tester, const Size(1440, 900), (ctx) {
        expect(WindowSizeClassResolver.resolve(ctx), WindowSizeClass.expanded);
      });
    });
  });

  // -------------------------------------------------------------------------
  // FormFactor enum
  // -------------------------------------------------------------------------

  group('FormFactor enum', () {
    test('has two values', () => expect(FormFactor.values.length, 2));
    test('contains phone', () => expect(FormFactor.values, contains(FormFactor.phone)));
    test('contains large', () => expect(FormFactor.values, contains(FormFactor.large)));
  });

  // -------------------------------------------------------------------------
  // WindowSizeClass enum
  // -------------------------------------------------------------------------

  group('WindowSizeClass enum', () {
    test('has three values', () => expect(WindowSizeClass.values.length, 3));
    test('contains compact', () => expect(WindowSizeClass.values, contains(WindowSizeClass.compact)));
    test('contains medium', () => expect(WindowSizeClass.values, contains(WindowSizeClass.medium)));
    test('contains expanded', () => expect(WindowSizeClass.values, contains(WindowSizeClass.expanded)));
  });
}

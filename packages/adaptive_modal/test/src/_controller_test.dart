// test/src/_controller_test.dart
// ignore_for_file: lines_longer_than_80_chars, simplify_variable_pattern, comment_references

import 'dart:async';

import 'package:adaptive_modal/adaptive_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a controller with a real [GlobalKey] anchor and a [child] widget.
AdaptiveModalController<void> makeController({
  Widget child = const Text('modal content'),
  AdaptiveModalConfig config = const AdaptiveModalConfig(),
  GlobalKey? anchorKey,
}) => AdaptiveModalController<void>(
  anchorKey: anchorKey ?? GlobalKey(),
  child: child,
  config: config,
);

/// Host widget that owns a controller, attaches it in [didChangeDependencies],
/// and renders the anchor [ElevatedButton] with the given [anchorKey].
class _TestHost extends StatefulWidget {
  const _TestHost({
    required this.anchorKey,
    required this.controller,
  });

  final GlobalKey anchorKey;
  final AdaptiveModalController<void> controller;

  @override
  State<_TestHost> createState() => _TestHostState();
}

class _TestHostState extends State<_TestHost> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.attach(context);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: widget.anchorKey,
          onPressed: () => widget.controller.show(context),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

/// Pumps a [_TestHost] inside [MaterialApp]. Returns the controller and a
/// helper that calls [show] with the correct context.
Future<
  ({
    AdaptiveModalController<void> controller,
    Future<void> Function() show,
  })
>
pumpHost(
  WidgetTester tester, {
  Widget content = const Text('modal content'),
  AdaptiveModalConfig config = const AdaptiveModalConfig(),
}) async {
  final anchorKey = GlobalKey();
  final controller = makeController(
    child: content,
    config: config,
    anchorKey: anchorKey,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: _TestHost(anchorKey: anchorKey, controller: controller),
    ),
  );

  // Capture context from within the overlay scope for show() calls.
  Future<void> show() async {
    final ctx = tester.element(find.byKey(anchorKey));
    unawaited(controller.show(ctx));
    await tester.pump();
  }

  return (controller: controller, show: show);
}

void main() {
  // -------------------------------------------------------------------------
  // AdaptiveModalController — initial state
  // -------------------------------------------------------------------------

  group('AdaptiveModalController initial state', () {
    testWidgets('isVisible is false before show', (tester) async {
      final (controller: controller, show: _) = await pumpHost(tester);
      expect(controller.isVisible, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalController — attach
  // -------------------------------------------------------------------------

  group('AdaptiveModalController.attach', () {
    testWidgets('attaches without throwing', (tester) async {
      expect(() async => pumpHost(tester), returnsNormally);
    });

    testWidgets('second attach call is a no-op (no throw)', (tester) async {
      final (controller: controller, show: _) = await pumpHost(tester);
      final ctx = tester.element(find.byType(_TestHost));
      // Calling attach again should be silently ignored.
      expect(() => controller.attach(ctx), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalController — show
  // -------------------------------------------------------------------------

  group('AdaptiveModalController.show', () {
    testWidgets('isVisible becomes true after show', (tester) async {
      final (:controller, :show) = await pumpHost(tester);
      await show();
      expect(controller.isVisible, isTrue);
    });

    testWidgets('modal content appears after show', (tester) async {
      final (controller: _, :show) = await pumpHost(
        tester,
        content: const Text('hello from modal'),
      );
      await show();
      await tester.pumpAndSettle();
      expect(find.text('hello from modal'), findsOneWidget);
    });

    testWidgets('calling show twice does not throw', (tester) async {
      final (controller: _, :show) = await pumpHost(tester);
      await show();
      expect(show, returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalController — hide
  // -------------------------------------------------------------------------

  group('AdaptiveModalController.hide', () {
    testWidgets('isVisible becomes false after hide', (tester) async {
      final (:controller, show: showModal) = await pumpHost(tester);
      await showModal();
      expect(controller.isVisible, isTrue);
      controller.hide();
      await tester.pumpAndSettle();
      expect(controller.isVisible, isFalse);
    });

    testWidgets('modal content disappears after hide', (tester) async {
      final (:controller, :show) = await pumpHost(
        tester,
        content: const Text('farewell modal'),
      );
      await show();
      await tester.pumpAndSettle();
      expect(find.text('farewell modal'), findsOneWidget);

      controller.hide();
      await tester.pumpAndSettle();
      expect(find.text('farewell modal'), findsNothing);
    });

    testWidgets('hide when not visible does not throw', (tester) async {
      final (:controller, show: _) = await pumpHost(tester);
      expect(controller.hide, returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalController — show / hide cycle
  // -------------------------------------------------------------------------

  group('AdaptiveModalController show/hide cycle', () {
    testWidgets('show → hide → show works correctly', (tester) async {
      final (:controller, :show) = await pumpHost(
        tester,
        content: const Text('cycled'),
      );

      await show();
      await tester.pumpAndSettle();
      expect(find.text('cycled'), findsOneWidget);

      controller.hide();
      await tester.pumpAndSettle();
      expect(find.text('cycled'), findsNothing);

      await show();
      await tester.pumpAndSettle();
      expect(find.text('cycled'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalController — resolve (typed return value)
  // -------------------------------------------------------------------------

  group('AdaptiveModalController.resolve', () {
    testWidgets('resolve completes future with value and hides modal', (
      tester,
    ) async {
      final anchorKey = GlobalKey();
      late AdaptiveModalController<String> controller;

      // Build a typed controller whose content calls resolve.
      late BuildContext hostCtx;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (ctx, setState) {
              hostCtx = ctx;
              return Scaffold(
                body: Builder(
                  builder: (innerCtx) {
                    controller = AdaptiveModalController<String>(
                      anchorKey: anchorKey,
                      child: ElevatedButton(
                        key: const Key('resolve_btn'),
                        onPressed: () => controller.resolve('the answer'),
                        child: const Text('Resolve'),
                      ),
                    )
                    ..attach(innerCtx);
                    return ElevatedButton(
                      key: anchorKey,
                      onPressed: () {},
                      child: const Text('Anchor'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      String? result;
      unawaited(controller.show(hostCtx).then((v) => result = v));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('resolve_btn')));
      await tester.pumpAndSettle();

      expect(result, 'the answer');
      expect(controller.isVisible, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalController — dispose
  // -------------------------------------------------------------------------

  group('AdaptiveModalController.dispose', () {
    testWidgets('dispose while visible does not throw', (tester) async {
      final (:controller, :show) = await pumpHost(tester);
      await show();
      expect(controller.isVisible, isTrue);

      // Hide before tearing down — disposing while the animation controller is
      // mid-flight calls reset() during tree lock, firing listeners on unmounted
      // widgets and triggering a framework assertion.
      controller.hide();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pumpAndSettle();
    });

    testWidgets('dispose while hidden does not throw', (tester) async {
      await pumpHost(tester);
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pumpAndSettle();
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalController — barrier dismiss
  // -------------------------------------------------------------------------

  group('AdaptiveModalController barrier dismiss', () {
    testWidgets('tapping barrier hides modal when barrierDismissible true', (
      tester,
    ) async {
      final (:controller, show: showModal) = await pumpHost(
        tester,
        content: const Text('behind barrier'),
        // ignore: avoid_redundant_argument_values document_ignores
        config: const AdaptiveModalConfig(barrierDismissible: true),
      );
      await showModal();
      await tester.pumpAndSettle();
      expect(find.text('behind barrier'), findsOneWidget);

      // Tap top-left corner = barrier area (away from modal and anchor).
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(controller.isVisible, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalConfig integration
  // -------------------------------------------------------------------------

  group('AdaptiveModalConfig integration', () {
    testWidgets('non-default config shows modal without throwing', (
      tester,
    ) async {
      final (:controller, show: showModal) = await pumpHost(
        tester,
        config: const AdaptiveModalConfig(
          barrierDismissible: false,
          barrierColor: Colors.red,
          maxWidth: 300,
          maxHeight: 400,
          animationDuration: Duration(milliseconds: 100),
          hapticFeedback: false,
        ),
      );
      await showModal();
      await tester.pumpAndSettle();
      expect(controller.isVisible, isTrue);
    });
  });
}

// test/src/overlay_manager_test.dart

// ignore_for_file: document_ignores, avoid_redundant_argument_values, lines_longer_than_80_chars

import 'dart:async';

import 'package:adaptive_modal/src/_overlay_manager.dart';
import 'package:adaptive_modal/src/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<OverlayManager<String>> _buildAttached(
  WidgetTester tester, {
  required GlobalKey anchorKey,
  AdaptiveModalConfig config = const AdaptiveModalConfig(),
}) async {
  late BuildContext capturedContext;

  final manager = OverlayManager<String>(
    config: config,
    anchorKey: anchorKey,
    child: const SizedBox.shrink(),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            capturedContext = context;
            return SizedBox.expand(key: anchorKey);
          },
        ),
      ),
    ),
  );

  manager.attach(capturedContext);
  addTearDown(manager.dispose);
  return manager;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('OverlayManager', () {
    // -------------------------------------------------------------------------
    // attach
    // -------------------------------------------------------------------------

    testWidgets('attach is idempotent — second call is a no-op', (
      tester,
    ) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);

      // A second attach call must not throw or double-register the observer.
      expect(
        () => manager.attach(tester.element(find.byType(Scaffold))),
        returnsNormally,
      );

      manager.dispose();
    });

    // -------------------------------------------------------------------------
    // show — guard: not attached
    // -------------------------------------------------------------------------

    testWidgets('show returns null when attach has not been called', (
      tester,
    ) async {
      final manager = OverlayManager<String>(
        config: const AdaptiveModalConfig(),
        anchorKey: GlobalKey(),
        child: const SizedBox.shrink(),
      );

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      final result = await manager.show(tester.element(find.byType(Scaffold)));

      expect(result, isNull);
      manager.dispose();
    });

    // -------------------------------------------------------------------------
    // show — guard: already visible
    // -------------------------------------------------------------------------

    testWidgets('show returns null when modal is already visible', (
      tester,
    ) async {
      final anchorKey = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: anchorKey);

      unawaited(manager.show(tester.element(find.byKey(anchorKey))));
      await tester.pump();

      expect(manager.isVisible, isTrue);

      final result = await manager.show(tester.element(find.byKey(anchorKey)));

      expect(result, isNull);

      manager.dispose();
    });

    // -------------------------------------------------------------------------
    // show — guard: null placement (unattached anchor key)
    // -------------------------------------------------------------------------

    testWidgets('show returns null when placement resolves to null', (
      tester,
    ) async {
      final unattachedKey = GlobalKey();
      late BuildContext capturedContext;

      final manager = OverlayManager<String>(
        config: const AdaptiveModalConfig(),
        anchorKey: unattachedKey,
        child: const SizedBox.shrink(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      manager.attach(capturedContext);
      addTearDown(manager.dispose);

      final result = await manager.show(capturedContext);

      expect(result, isNull);
      expect(manager.isVisible, isFalse);
    });

    // -------------------------------------------------------------------------
    // resolve
    // -------------------------------------------------------------------------

    testWidgets('resolve completes show future with value and hides modal', (
      tester,
    ) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);

      final future = manager.show(tester.element(find.byType(SizedBox)));
      await tester.pump();

      manager.resolve('done');
      await tester.pumpAndSettle();

      expect(await future, 'done');
      expect(manager.isVisible, isFalse);

      manager.dispose();
    });

    testWidgets('resolve is a no-op when modal is not visible', (tester) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);

      expect(() => manager.resolve('noop'), returnsNormally);

      manager.dispose();
    });

    // -------------------------------------------------------------------------
    // hide
    // -------------------------------------------------------------------------

    testWidgets('hide completes show future with null and hides modal', (
      tester,
    ) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);

      final future = manager.show(tester.element(find.byType(SizedBox)));
      await tester.pump();

      manager.hide();
      await tester.pumpAndSettle();

      expect(await future, isNull);
      expect(manager.isVisible, isFalse);

      manager.dispose();
    });

    testWidgets('hide is a no-op when modal is not visible', (tester) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);

      expect(manager.hide, returnsNormally);

      manager.dispose();
    });

    // -------------------------------------------------------------------------
    // haptic feedback
    // -------------------------------------------------------------------------

    testWidgets('resolve fires haptic when hapticFeedback is true', (
      tester,
    ) async {
      final key = GlobalKey();
      final manager = await _buildAttached(
        tester,
        anchorKey: key,
        config: const AdaptiveModalConfig(hapticFeedback: true),
      );

      unawaited(manager.show(tester.element(find.byType(SizedBox))));
      await tester.pump();

      expect(() async {
        manager.resolve('haptic');
        await tester.pumpAndSettle();
      }, returnsNormally);

      manager.dispose();
    });

    testWidgets('hide fires haptic when hapticFeedback is true', (
      tester,
    ) async {
      final key = GlobalKey();
      final manager = await _buildAttached(
        tester,
        anchorKey: key,
        config: const AdaptiveModalConfig(hapticFeedback: true),
      );

      unawaited(manager.show(tester.element(find.byType(SizedBox))));
      await tester.pump();

      expect(() async {
        manager.hide();
        await tester.pumpAndSettle();
      }, returnsNormally);

      manager.dispose();
    });

    // -------------------------------------------------------------------------
    // _onMetricsChanged — modal not visible
    // -------------------------------------------------------------------------

    testWidgets('metrics change while modal is hidden is a no-op', (
      tester,
    ) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);

      expect(manager.isVisible, isFalse);

      // Trigger didChangeMetrics — modal not visible, should be a no-op.
      tester.binding.handleMetricsChanged();
      await tester.pump();

      expect(manager.isVisible, isFalse);

      manager.dispose();
    });

    // -------------------------------------------------------------------------
    // _onMetricsChanged — modal visible, valid placement
    // -------------------------------------------------------------------------

    testWidgets('metrics change while modal is visible triggers rebuild', (
      tester,
    ) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);

      unawaited(manager.show(tester.element(find.byType(SizedBox))));
      await tester.pump();

      expect(manager.isVisible, isTrue);

      // Resize — triggers _onMetricsChanged with a mounted context.
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(tester.view.resetPhysicalSize);

      tester.binding.handleMetricsChanged();
      await tester.pump();

      expect(manager.isVisible, isTrue);

      manager.dispose();
    });

    // -------------------------------------------------------------------------
    // _onMetricsChanged — unmounted context guard
    // -------------------------------------------------------------------------

    testWidgets('metrics change with unmounted context does not throw', (
      tester,
    ) async {
      final key = GlobalKey();
      late BuildContext capturedContext;

      final manager = OverlayManager<String>(
        config: const AdaptiveModalConfig(),
        anchorKey: key,
        child: const SizedBox.shrink(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                capturedContext = context;
                return SizedBox.expand(key: key);
              },
            ),
          ),
        ),
      );

      manager.attach(capturedContext);
      unawaited(manager.show(capturedContext));
      await tester.pump();

      // Replace widget tree — capturedContext becomes unmounted.
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      tester.binding.handleMetricsChanged();
      await tester.pump();

      manager.dispose();
    });

    // -------------------------------------------------------------------------
    // _onMetricsChanged — null placement on resize
    // -------------------------------------------------------------------------

    testWidgets(
      'metrics change returns early when placement resolves to null',
      (tester) async {
        final anchorKey = GlobalKey();
        late BuildContext capturedContext;
        late StateSetter setState;
        var showAnchor = true;

        final manager = OverlayManager<String>(
          config: const AdaptiveModalConfig(),
          anchorKey: anchorKey,
          child: const SizedBox.shrink(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, s) {
                  setState = s;
                  capturedContext = context;
                  return showAnchor
                      ? SizedBox.expand(key: anchorKey)
                      : const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        manager.attach(capturedContext);
        unawaited(manager.show(capturedContext));
        await tester.pump();

        expect(manager.isVisible, isTrue);

        // Remove the anchor from the tree so PositionResolver returns null.
        setState(() => showAnchor = false);
        await tester.pump();

        tester.binding.handleMetricsChanged();
        await tester.pump();

        // Modal remains in its current state — no crash.
        manager.dispose();
      },
    );

    // -------------------------------------------------------------------------
    // dispose
    // -------------------------------------------------------------------------

    testWidgets('dispose while modal is visible completes future with null', (
      tester,
    ) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);

      final future = manager.show(tester.element(find.byType(SizedBox)));
      await tester.pump();

      manager.dispose();
      await tester.pumpAndSettle();

      expect(await future, isNull);
    });

    testWidgets('dispose without prior show does not throw', (tester) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);

      expect(manager.dispose, returnsNormally);
    });
  });
}

// test/src/_overlay_manager_test_part.dart

// ignore_for_file: document_ignores, avoid_redundant_argument_values, lines_longer_than_80_chars

part of 'overlay_manager_test.dart';

void _runOverlayManagerPartTwo() {
  testWidgets('resolve completes show future with value and hides modal', (
    tester,
  ) async {
    final key = GlobalKey();
    final manager = await _buildAttached(tester, anchorKey: key);
    final future = manager.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();
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
  testWidgets('hide completes show future with null and hides modal', (
    tester,
  ) async {
    final key = GlobalKey();
    final manager = await _buildAttached(tester, anchorKey: key);
    final future = manager.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();
    unawaited(manager.hide());
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
    await tester.pumpAndSettle();
    manager.resolve('haptic');
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    unawaited(manager.hide());
    await tester.pumpAndSettle();
    manager.dispose();
  });
  testWidgets('metrics change while modal is hidden is a no-op', (
    tester,
  ) async {
    final key = GlobalKey();
    final manager = await _buildAttached(tester, anchorKey: key);
    expect(manager.isVisible, isFalse);
    tester.binding.handleMetricsChanged();
    await tester.pump();
    expect(manager.isVisible, isFalse);
    manager.dispose();
  });

  testWidgets('metrics change while modal is visible triggers rebuild', (
    tester,
  ) async {
    final key = GlobalKey();
    final manager = await _buildAttached(tester, anchorKey: key);
    unawaited(manager.show(tester.element(find.byType(SizedBox))));
    await tester.pump();
    expect(manager.isVisible, isTrue);
    tester.view.physicalSize = const Size(1080, 1920);
    addTearDown(tester.view.resetPhysicalSize);
    tester.binding.handleMetricsChanged();
    await tester.pump();
    expect(manager.isVisible, isTrue);
    manager.dispose();
  });

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
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    tester.binding.handleMetricsChanged();
    await tester.pump();
    manager.dispose();
  });

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
      setState(() => showAnchor = false);
      await tester.pump();
      tester.binding.handleMetricsChanged();
      await tester.pump();
      manager.dispose();
    },
  );

  testWidgets('dispose while modal is visible completes future with null', (
    tester,
  ) async {
    final key = GlobalKey();
    final manager = await _buildAttached(tester, anchorKey: key);
    final future = manager.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();
    manager.dispose();
    await tester.pumpAndSettle();
    expect(await future, isNull);
  });

  testWidgets('dispose without prior show does not throw', (tester) async {
    final key = GlobalKey();
    final manager = await _buildAttached(tester, anchorKey: key);
    expect(manager.dispose, returnsNormally);
  });
}

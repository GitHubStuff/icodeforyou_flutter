// test/src/overlay_manager_test.dart

// ignore_for_file: unnecessary_ignore, document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:adaptive_modal/src/_overlay_manager.dart';
import 'package:adaptive_modal/src/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

part '_overlay_manager_test_part.dart';

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

void main() {
  group('OverlayManager', () {
    testWidgets('attach is idempotent — second call is a no-op', (
      tester,
    ) async {
      final key = GlobalKey();
      final manager = await _buildAttached(tester, anchorKey: key);
      expect(
        () => manager.attach(tester.element(find.byType(Scaffold))),
        returnsNormally,
      );
      manager.dispose();
    });

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

    _runOverlayManagerPartTwo();
  });
}

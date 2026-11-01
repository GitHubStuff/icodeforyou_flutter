// packages/status_bar_visibility_abstract/test/status_bar_visibility_abstract_test.dart
import 'dart:async';

import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;
import 'package:test/test.dart';

/// Synchronous mock implementation of [StatusBarVisibilityAbstract].
class SyncStatusBarVisibility implements StatusBarVisibilityAbstract {
  bool _initialized = false;
  bool _barHidden = false;

  @override
  bool initialize({required bool withBarHidden}) {
    _initialized = true;
    _barHidden = withBarHidden;
    return true;
  }

  @override
  bool setStatusBarVisibility({required bool isHidden}) {
    if (!_initialized) return false;
    _barHidden = isHidden;
    return true;
  }

  @override
  bool isBarHidden() => _barHidden;

  @override
  bool isInitialized() => _initialized;
}

/// Asynchronous mock implementation of [StatusBarVisibilityAbstract].
class AsyncStatusBarVisibility implements StatusBarVisibilityAbstract {
  bool _initialized = false;
  bool _barHidden = false;

  @override
  Future<bool> initialize({required bool withBarHidden}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    _initialized = true;
    _barHidden = withBarHidden;
    return true;
  }

  @override
  Future<bool> setStatusBarVisibility({required bool isHidden}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!_initialized) return false;
    _barHidden = isHidden;
    return true;
  }

  @override
  bool isBarHidden() => _barHidden;

  @override
  bool isInitialized() => _initialized;
}

void main() {
  group('StatusBarVisibilityAbstract - Synchronous Implementation', () {
    late StatusBarVisibilityAbstract controller;

    setUp(() {
      controller = SyncStatusBarVisibility();
    });

    test('initial state reports not initialized and visible', () {
      expect(controller.isInitialized(), isFalse);
      expect(controller.isBarHidden(), isFalse);
    });

    test('initialize sets state and returns true synchronously', () {
      final result = controller.initialize(withBarHidden: true);

      expect(result, isTrue);
      expect(controller.isInitialized(), isTrue);
      expect(controller.isBarHidden(), isTrue);
    });

    test('initialize can start with bar visible', () {
      final result = controller.initialize(withBarHidden: false);

      expect(result, isTrue);
      expect(controller.isInitialized(), isTrue);
      expect(controller.isBarHidden(), isFalse);
    });

    test('setStatusBarVisibility toggles visibility when initialized', () {
      controller.initialize(withBarHidden: false);
      expect(controller.isBarHidden(), isFalse);

      final hideResult = controller.setStatusBarVisibility(isHidden: true);
      expect(hideResult, isTrue);
      expect(controller.isBarHidden(), isTrue);

      final showResult = controller.setStatusBarVisibility(isHidden: false);
      expect(showResult, isTrue);
      expect(controller.isBarHidden(), isFalse);
    });

    test('setStatusBarVisibility fails if not initialized', () {
      final result = controller.setStatusBarVisibility(isHidden: true);

      expect(result, isFalse);
      expect(controller.isBarHidden(), isFalse);
    });
  });

  group('StatusBarVisibilityAbstract - Asynchronous Implementation', () {
    late StatusBarVisibilityAbstract controller;

    setUp(() {
      controller = AsyncStatusBarVisibility();
    });

    test('initialize resolves Future<bool> and updates state', () async {
      expect(controller.isInitialized(), isFalse);

      final result = await controller.initialize(withBarHidden: true);

      expect(result, isTrue);
      expect(controller.isInitialized(), isTrue);
      expect(controller.isBarHidden(), isTrue);
    });

    test(
      'setStatusBarVisibility resolves Future<bool> and toggles state',
      () async {
        await controller.initialize(withBarHidden: false);

        final hideResult = await controller.setStatusBarVisibility(
          isHidden: true,
        );
        expect(hideResult, isTrue);
        expect(controller.isBarHidden(), isTrue);

        final showResult = await controller.setStatusBarVisibility(
          isHidden: false,
        );
        expect(showResult, isTrue);
        expect(controller.isBarHidden(), isFalse);
      },
    );

    test(
      'setStatusBarVisibility handles uninitialized async failure',
      () async {
        final result = await controller.setStatusBarVisibility(isHidden: true);

        expect(result, isFalse);
        expect(controller.isBarHidden(), isFalse);
        expect(controller.isInitialized(), isFalse);
      },
    );
  });
}

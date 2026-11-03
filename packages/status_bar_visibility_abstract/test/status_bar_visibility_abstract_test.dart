// packages/status_bar_visibility_abstract/test/status_bar_visibility_abstract_test.dart

import 'dart:async' show FutureOr;

import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart';

/// Concrete implementation used to verify the abstract interface contract.
class TestStatusBarVisibility implements StatusBarVisibilityAbstract {
  bool _isInitialized = false;
  bool _isHidden = false;

  @override
  bool isInitialized() => _isInitialized;

  @override
  bool isBarHidden() => _isHidden;

  @override
  FutureOr<bool> setStatusBarVisibility({required bool isHidden}) {
    _isHidden = isHidden;
    _isInitialized = true;
    return true;
  }
}

/// Concrete implementation returning a [Future] to test asynchronous fulfillment.
class AsyncTestStatusBarVisibility implements StatusBarVisibilityAbstract {
  bool _isInitialized = false;
  bool _isHidden = false;

  @override
  bool isInitialized() => _isInitialized;

  @override
  bool isBarHidden() => _isHidden;

  @override
  Future<bool> setStatusBarVisibility({required bool isHidden}) async {
    _isHidden = isHidden;
    _isInitialized = true;
    return true;
  }
}

void main() {
  group('StatusBarVisibilityAbstract contract', () {
    test('can be implemented synchronously', () {
      final StatusBarVisibilityAbstract instance = TestStatusBarVisibility();

      expect(instance.isInitialized(), isFalse);
      expect(instance.isBarHidden(), isFalse);

      final result = instance.setStatusBarVisibility(isHidden: true);

      expect(result, isTrue);
      expect(instance.isInitialized(), isTrue);
      expect(instance.isBarHidden(), isTrue);
    });

    test('can be implemented asynchronously', () async {
      final StatusBarVisibilityAbstract instance =
          AsyncTestStatusBarVisibility();

      expect(instance.isInitialized(), isFalse);
      expect(instance.isBarHidden(), isFalse);

      final result = await instance.setStatusBarVisibility(isHidden: true);

      expect(result, isTrue);
      expect(instance.isInitialized(), isTrue);
      expect(instance.isBarHidden(), isTrue);
    });

    test('updates visibility state across toggles', () {
      final StatusBarVisibilityAbstract instance = TestStatusBarVisibility();

      instance.setStatusBarVisibility(isHidden: true);
      expect(instance.isBarHidden(), isTrue);

      instance.setStatusBarVisibility(isHidden: false);
      expect(instance.isBarHidden(), isFalse);
    });
  });
}

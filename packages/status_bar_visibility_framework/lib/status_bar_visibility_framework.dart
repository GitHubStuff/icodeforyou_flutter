// packages/status_bar_visibility_framework/lib/
// status_bar_visibility_framework.dart

import 'dart:async' show FutureOr, unawaited;

import 'package:custom_errors/custom_errors.dart' show NotInitializedError;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:status_bar_android/status_bar_android.dart'
    as android
    show StatusBar;
import 'package:status_bar_ios/status_bar_ios.dart' as ios show StatusBar;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;

class StatusBarVisibilityFramework implements StatusBarVisibilityAbstract {
  /// Returns the singleton instance of [StatusBarVisibilityFramework].
  factory StatusBarVisibilityFramework() => _instance;

  StatusBarVisibilityFramework._internal();

  static bool _initializedFlag = false;
  static bool? _isHidden;

  /// Internal singleton reference.
  static final StatusBarVisibilityFramework _instance =
      StatusBarVisibilityFramework._internal();

  /// The active singleton instance of [StatusBarVisibilityFramework].
  static StatusBarVisibilityFramework get instance => _instance;

  // --- Static Hooks ---

  static FutureOr<bool> setStatusBar({required bool isHidden}) async {
    _initializedFlag = true;
    final isBarVisibilitySet = await _instance._setStatusBar(
      isHidden: isHidden,
    );
    if (isBarVisibilitySet) _isHidden = isHidden;
    return isBarVisibilitySet;
  }

  static bool isHidden() {
    if (_isHidden == null) throw NotInitializedError('StatusBar');
    return _isHidden!;
  }

  static bool isReady() => _initializedFlag;

  // --- Abstract Contract Implementations ---

  /// Changes status bar visibility via the instance contract.
  ///
  /// Delegates directly to [setStatusBar].
  ///
  /// Throws a [NotInitializedError] if the framework has not yet been
  /// initialized.
  @override
  FutureOr<bool> setStatusBarVisibility({required bool isHidden}) =>
      _setStatusBar(isHidden: isHidden);

  // --- Private Implementations ---

  /// Internal implementation of status bar toggling using [SystemChrome].
  Future<bool> _setStatusBar({required bool isHidden}) async {
    switch (OSPlatform.current) {
      case .android:
        unawaited(android.StatusBar.setVisibility(isHidden: isHidden));
        return true;
      case .iOS:
        unawaited(ios.StatusBar.setVisibility(isHidden: isHidden));
        return true;
      case .fuchsia:
      case .linux:
      case .macOS:
      case .web:
      case .windows:
        return false;
    }
  }

  /// Returns false if it hasn't been initialized or false from a platform fail
  @override
  bool isBarHidden() => _instance.isBarHidden();

  /// Get the status if the init has been called and the platform is supported.
  ///
  /// Returns false if initialize() hasn't been called or the platform doesn't
  /// support mobile;
  @override
  bool isInitialized() => _instance.isInitialized();

  /// Resets the internal initialization state.
  ///
  /// Intended strictly for test environments to simulate fresh startup states
  /// without retaining process-wide static flags.
  @visibleForTesting
  void resetInit(bool? isHidden) {
    _isHidden = isHidden;
    _initializedFlag = _isHidden != null;
  }
}

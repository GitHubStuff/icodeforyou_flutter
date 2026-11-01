// packages/status_bar_visibility_abstract/lib/status_bar_visibility_abstract.dart
/// A platform-agnostic interface for controlling status bar visibility.
///
/// This library defines the abstract contract that platform-specific
/// implementations (e.g., iOS, Android, macOS, Web) must implement.
library;

import 'dart:async' show FutureOr;

/// Abstract contract defining methods to configure and toggle status
/// bar visibility.
abstract class StatusBarVisibilityAbstract {
  /// Toggles the status bar's visibility.
  ///
  /// Pass `isHidden: true` to conceal the status bar, or `isHidden: false`
  /// to make it visible. Returns `true` if the operation was handled
  /// successfully.
  FutureOr<bool> setStatusBarVisibility({required bool isHidden});

  /// Get the state of the status bar.
  bool isBarHidden();

  /// test if the Status Bar visibity has been initialized.
  bool isInitialized();
}

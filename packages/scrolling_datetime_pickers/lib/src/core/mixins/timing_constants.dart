// lib/src/core/mixins/debounce_callback_mixin.dart

import 'dart:async';

import 'package:scrolling_datetime_pickers/src/core/constants/timing_constants.dart';

/// Mixin for handling debounced callbacks
mixin DebounceCallbackMixin {
  Timer? _debounceTimer;

  /// Execute a callback after a debounce period
  void debounceCallback(
    void Function() callback, {
    Duration? duration,
  }) {
    cancelDebounce();

    _debounceTimer = Timer(
      duration ?? TimingConstants.callbackDebounce,
      callback,
    );
  }

  /// Cancel any pending debounced callback
  void cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Check if a debounce timer is active
  bool get isDebouncing => _debounceTimer?.isActive ?? false;

  /// Execute callback immediately and reset debounce
  void executeImmediately(void Function() callback) {
    cancelDebounce();
    callback();
  }

  /// Dispose of resources (call in widget dispose)
  void disposeDebounce() {
    cancelDebounce();
  }
}

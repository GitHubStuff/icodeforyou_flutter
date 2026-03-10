// lib/src/_overlay_manager.dart
// ---------------------------------------------------------------------------
// _overlay_manager.dart — creates, inserts, animates, and removes the
// OverlayEntry instances that make up the modal stack.
//
// Single responsibility: own the two OverlayEntry objects (barrier + modal)
// and the AnimationController that drives both.
//
// show() returns a Future<T?> via a Completer. The future completes with a
// value when resolve(value) is called, or null when hide() is called without
// a value — barrier tap, close button, or programmatic hide().
// ---------------------------------------------------------------------------

// ignore_for_file: document_ignores, public_member_api_docs

import 'dart:async';

import 'package:adaptive_modal/src/_barrier.dart';
import 'package:adaptive_modal/src/_modal_shell.dart';
import 'package:adaptive_modal/src/_platform_detector.dart';
import 'package:adaptive_modal/src/_position_resolver.dart';
import 'package:adaptive_modal/src/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// OverlayManager
// ---------------------------------------------------------------------------

/// Manages the [OverlayEntry] lifecycle for the modal and its barrier.
///
// ignore: comment_references
/// Created once by [AdaptiveModalController] and held for the lifetime of
/// the controller.  [dispose] must be called when the controller is disposed.
class OverlayManager<T> {
  /// Constructor
  OverlayManager({
    required this.config,
    required this.anchorKey,
    required this.child,
  });

  final AdaptiveModalConfig config;
  final GlobalKey anchorKey;
  final Widget child;

  OverlayState? _overlayState;
  AnimationController? _animationController;
  OverlayEntry? _barrierEntry;
  OverlayEntry? _modalEntry;
  _MetricsObserver? _metricsObserver;

  /// Completer for the current show() call. Completes with T? on dismiss.
  Completer<T?>? _completer;

  /// Retained so rotation can re-resolve placement without caller involvement.
  BuildContext? _lastContext;

  /// Current resolved placement — updated on rotation while visible.
  ModalPlacement? _placement;

  /// Current form factor — tracked to detect phone/large transitions on rotate.
  bool _isPhone = false;

  bool get isVisible => _modalEntry != null;

  // ---------------------------------------------------------------------------
  // Attach
  // ---------------------------------------------------------------------------

  /// Attaches this manager to the nearest [Overlay].
  ///
  /// Must be called from [State.didChangeDependencies] before the first call
  /// to [show].  Safe to call multiple times — subsequent calls are ignored.
  void attach(BuildContext context) {
    if (_overlayState != null) return;
    _overlayState = Overlay.of(context);
    _animationController = AnimationController(
      vsync: _overlayState!,
      duration: config.animationDuration,
    );

    _metricsObserver = _MetricsObserver(onChanged: _onMetricsChanged);
    WidgetsBinding.instance.addObserver(_metricsObserver!);
  }

  // ---------------------------------------------------------------------------
  // Show
  // ---------------------------------------------------------------------------

  /// Inserts the barrier (if applicable) and modal into the [Overlay] and
  /// runs the show animation.
  ///
  /// Returns a [Future] that completes with [T] when [resolve] is called, or
  /// null when the modal is dismissed without a value.
  ///
  /// Does nothing and returns a completed null future if the modal is already
  /// visible or [attach] has not been called.
  Future<T?> show(BuildContext context) async {
    if (_overlayState == null || isVisible) {
      return Future.value();
    }

    _completer = Completer<T?>();
    _lastContext = context;
    _isPhone = PlatformDetector.isPhone(context);

    final placement = PositionResolver.resolve(
      anchorKey: anchorKey,
      context: context,
      modalWidth: config.maxWidth,
      modalHeight: config.maxHeight,
    );

    if (placement == null) {
      _completer!.complete(null);
      _completer = null;
      return Future.value();
    }

    _placement = placement;
    _buildEntries();

    _overlayState!.insertAll([
      ?_barrierEntry,
      _modalEntry!,
    ]);

    await _animationController!.forward();
    return _completer!.future;
  }

  // ---------------------------------------------------------------------------
  // Resolve
  // ---------------------------------------------------------------------------

  /// Dismisses the modal and completes the [show] future with [value].
  ///
  /// Use this when the modal content has a meaningful result to return —
  /// for example a confirm button tapped with a selected value.
  ///
  /// Does nothing if the modal is not currently visible.
  void resolve(T value) {
    if (!isVisible) return;

    if (config.hapticFeedback) unawaited(HapticFeedback.lightImpact());
    unawaited(_animationController!.reverse().whenComplete(() {
      _removeEntries();
      _completer?.complete(value);
      _completer = null;
    }));
  }

  // ---------------------------------------------------------------------------
  // Hide
  // ---------------------------------------------------------------------------

  /// Dismisses the modal without a return value.
  ///
  /// The [show] future completes with null.
  ///
  /// Fires a light haptic impulse when [AdaptiveModalConfig.hapticFeedback]
  /// is true.
  ///
  /// Does nothing if the modal is not currently visible.
  Future<void> hide() async {
    if (!isVisible) return;

    if (config.hapticFeedback) unawaited(HapticFeedback.lightImpact());
    await _animationController!.reverse().whenComplete(() {
      _removeEntries();
      _completer?.complete(null);
      _completer = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Rotation handling
  // ---------------------------------------------------------------------------

  /// Called by [_MetricsObserver] when screen metrics change.
  ///
  /// Re-resolves placement and marks entries for rebuild if the modal is
  /// currently visible. Handles both rotation and window resize on desktop.
  void _onMetricsChanged() {
    if (!isVisible || _lastContext == null) return;

    final context = _lastContext!;
    if (context is Element && !context.mounted) return;

    _isPhone = PlatformDetector.isPhone(context);

    final placement = PositionResolver.resolve(
      anchorKey: anchorKey,
      context: context,
      modalWidth: config.maxWidth,
      modalHeight: config.maxHeight,
    );

    if (placement == null) return;
    _placement = placement;

    _modalEntry?.markNeedsBuild();
    _barrierEntry?.markNeedsBuild();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _buildEntries() {
    final animation = CurvedAnimation(
      parent: _animationController!,
      curve: config.animationCurve,
    );

    if (config.barrierDismissible) {
      _barrierEntry = OverlayEntry(
        builder: (_) => BarrierWidget(
          color: config.barrierColor,
          opacity: animation,
          onDismiss: hide,
        ),
      );
    }

    _modalEntry = OverlayEntry(
      builder: (_) => ModalShell(
        placement: _placement!,
        config: config,
        animation: animation,
        onClose: hide,
        isPhone: _isPhone,
        child: child,
      ),
    );
  }

  void _removeEntries() {
    _barrierEntry?.remove();
    _modalEntry?.remove();
    _barrierEntry = null;
    _modalEntry = null;
    _placement = null;
    _animationController?.reset();
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  /// Releases all resources.  Must be called when the owning controller
  /// is disposed.
  void dispose() {
    if (_metricsObserver != null) {
      WidgetsBinding.instance.removeObserver(_metricsObserver!);
      _metricsObserver = null;
    }
    _completer?.complete(null);
    _completer = null;
    _removeEntries();
    _animationController?.dispose();
    _animationController = null;
    _overlayState = null;
    _lastContext = null;
  }
}

// ---------------------------------------------------------------------------
// _MetricsObserver
// ---------------------------------------------------------------------------

/// Minimal [WidgetsBindingObserver] that fires [onChanged] when screen
/// metrics change — rotation, window resize, keyboard appearance.
class _MetricsObserver extends WidgetsBindingObserver {
  _MetricsObserver({required this.onChanged});

  final VoidCallback onChanged;

  @override
  void didChangeMetrics() => onChanged();
}

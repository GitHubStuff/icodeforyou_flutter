// lib/src/_controller.dart
// ---------------------------------------------------------------------------
// _controller.dart — AdaptiveModalController, the sole public API entry point
// for the adaptive_modal package.
//
// Single responsibility: expose show(), hide(), resolve(), attach(), and
// dispose() to the caller while delegating all implementation to
// OverlayManager.
//
// AdaptiveModalController<T> is generic so the caller declares the return type
// once at construction and gets a typed Future<T?> from show().
// ---------------------------------------------------------------------------

// ignore_for_file: document_ignores, comment_references

import 'package:adaptive_modal/src/_overlay_manager.dart';
import 'package:adaptive_modal/src/types.dart';
import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// AdaptiveModalController
// ---------------------------------------------------------------------------

/// Controls the lifecycle of an adaptive modal overlay.
///
/// [T] is the optional return type.  Use [AdaptiveModalController<void>] when
/// no return value is needed, or a concrete type such as
/// [AdaptiveModalController<String>] when the modal resolves with a value.
///
/// Declare one in your [State], attach it in [didChangeDependencies], and
/// dispose it in [dispose].
///
/// Example — with return value:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> {
///   final _anchorKey = GlobalKey();
///   late final AdaptiveModalController<String> _modal;
///
///   @override
///   void initState() {
///     super.initState();
///     _modal = AdaptiveModalController<String>(
///       anchorKey: _anchorKey,
///       child: MyModalContent(
///         onConfirm: (value) => _modal.resolve(value),
///       ),
///     );
///   }
///
///   @override
///   void didChangeDependencies() {
///     super.didChangeDependencies();
///     _modal.attach(context);
///   }
///
///   @override
///   void dispose() {
///     _modal.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return ElevatedButton(
///       key: _anchorKey,
///       onPressed: () async {
///         final result = await _modal.show(context);
///         if (result != null) debugPrint('Modal returned: $result');
///       },
///       child: const Text('Open'),
///     );
///   }
/// }
/// ```
class AdaptiveModalController<T> {
  ///
  AdaptiveModalController({
    required GlobalKey anchorKey,
    required Widget child,
    AdaptiveModalConfig config = const AdaptiveModalConfig(),
  }) : _manager = OverlayManager<T>(
         config: config,
         anchorKey: anchorKey,
         child: child,
       );

  final OverlayManager<T> _manager;

  /// Whether the modal is currently visible.
  bool get isVisible => _manager.isVisible;

  // ---------------------------------------------------------------------------
  // Attach
  // ---------------------------------------------------------------------------

  /// Attaches the controller to the nearest [Overlay].
  ///
  /// Must be called from [State.didChangeDependencies] before the first call
  /// to [show].  Safe to call multiple times — subsequent calls are ignored.
  ///
  /// ```dart
  /// @override
  /// void didChangeDependencies() {
  ///   super.didChangeDependencies();
  ///   _modal.attach(context);
  /// }
  /// ```
  void attach(BuildContext context) => _manager.attach(context);

  // ---------------------------------------------------------------------------
  // Show
  // ---------------------------------------------------------------------------

  /// Shows the modal anchored to the trigger widget.
  ///
  /// Returns a [Future] that completes with [T] when [resolve] is called, or
  /// null when the modal is dismissed without a value — close button, barrier
  /// tap, or [hide].
  ///
  /// Does nothing and returns a completed null future if the modal is already
  /// visible or [attach] has not been called.
  ///
  /// ```dart
  /// final result = await _modal.show(context);
  /// ```
  Future<T?> show(BuildContext context) => _manager.show(context);

  // ---------------------------------------------------------------------------
  // Resolve
  // ---------------------------------------------------------------------------

  /// Dismisses the modal and completes the [show] future with [value].
  ///
  /// Use when the modal content produces a result — for example a confirm
  /// button. Pass [resolve] as a callback to the content widget so it never
  /// needs to import or reference the controller directly.
  ///
  /// ```dart
  /// child: MyModalContent(
  ///   onConfirm: (value) => _modal.resolve(value),
  /// )
  /// ```
  void resolve(T value) => _manager.resolve(value);

  // ---------------------------------------------------------------------------
  // Hide
  // ---------------------------------------------------------------------------

  /// Dismisses the modal without a return value.
  ///
  /// The [show] future completes with null.
  ///
  /// Does nothing if the modal is not currently visible.
  ///
  /// ```dart
  /// _modal.hide();
  /// ```
  void hide() => _manager.hide();

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  /// Releases all resources held by this controller.
  ///
  /// Must be called from [State.dispose].
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _modal.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() => _manager.dispose();
}

// packages/ext_widget/lib/src/extended_stateful_widget.dart

import 'package:flutter/material.dart';

/// A [State] base class that wires up a [WidgetsBindingObserver] for you and
/// exposes the observer callbacks as overridable hooks.
///
/// Extend this instead of [State] when a widget needs to react to
/// framework-level events without each `State` subclass repeating the same
/// `addObserver` / `removeObserver` boilerplate in [initState] and [dispose].
///
/// The following hooks are provided:
///
/// * [afterFirstLayout] — invoked once, after the first frame has been laid
///   out and painted, with a [BuildContext] that is safe to use for
///   `MediaQuery`, `Navigator`, `Scaffold.of`, and similar inherited lookups.
/// * [didChangeAppLifecycleState] — invoked when the app moves between
///   foreground, background, inactive, hidden, and detached.
/// * [didChangeMetrics] — invoked when the window size, orientation, insets,
///   or padding change.
/// * [didChangePlatformBrightness] — invoked when the OS switches between
///   light and dark mode.
/// * [didChangeTextScaleFactor] — invoked when the user changes the system
///   font-scaling setting; forwarded to [reportTextScaleFactor].
/// * [reportTextScaleFactor] — invoked with the current text scale factor on
///   [initState] and on every subsequent change.
///
/// Observer registration is handled in [initState] and removal in [dispose].
/// Subclasses that override either of those **must** call `super`, which is
/// enforced via [mustCallSuper].
///
/// ## Example
///
/// ```dart
/// class HomePage extends StatefulWidget {
///   const HomePage({super.key});
///
///   @override
///   State<HomePage> createState() => _HomePageState();
/// }
///
/// class _HomePageState extends ExtendedStatefulWidget<HomePage> {
///   @override
///   void afterFirstLayout(BuildContext context) {
///     // MediaQuery is reliable here; the first frame has already rendered.
///     final size = MediaQuery.sizeOf(context);
///     debugPrint('First layout: $size');
///   }
///
///   @override
///   void didChangeAppLifecycleState(AppLifecycleState state) {
///     if (state == AppLifecycleState.paused) {
///       // Persist unsaved work, pause timers, etc.
///     }
///   }
///
///   @override
///   void reportTextScaleFactor(double? textScaleFactor) {
///     debugPrint('Text scale factor: $textScaleFactor');
///   }
///
///   @override
///   Widget build(BuildContext context) => const Scaffold();
/// }
/// ```
///
/// See also:
///
/// * [WidgetsBindingObserver], the mixin whose callbacks are surfaced here.
/// * [WidgetsBinding.addPostFrameCallback], which backs [afterFirstLayout].
abstract class ExtendedStatefulWidget<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  /// Registers this state as a [WidgetsBindingObserver] and schedules the
  /// one-time [afterFirstLayout] callback.
  ///
  /// Also seeds [reportTextScaleFactor] with the platform's current text scale
  /// factor so subclasses receive an initial value without waiting for the
  /// user to change the setting.
  ///
  /// Subclasses overriding this method must call `super.initState()` first.
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    final instance = WidgetsBinding.instance;
    reportTextScaleFactor(instance.platformDispatcher.textScaleFactor);
    instance
      ..addPostFrameCallback((_) => afterFirstLayout(context))
      ..addObserver(this);
  }

  /// Called when the application's lifecycle state changes.
  ///
  /// The default implementation does nothing. Override to react to the app
  /// being paused, resumed, hidden, or detached — for example to flush
  /// pending writes when transitioning to [AppLifecycleState.paused].
  ///
  /// There is no need to call `super` from an override.
  ///
  /// See [AppLifecycleState] for the full set of states and their meanings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  /// Called when the application's window metrics change — size, device
  /// pixel ratio, orientation, view insets, or padding.
  ///
  /// At the moment this fires, [MediaQuery] has **not** yet rebuilt with the
  /// new values. This implementation schedules a post-frame callback so that
  /// any work depending on fresh `MediaQuery` data runs after the framework
  /// has propagated the change. The scheduled callback is currently a no-op
  /// placeholder; subclasses that need the updated metrics should override
  /// this method, call `super.didChangeMetrics()`, and schedule their own
  /// post-frame callback.
  ///
  /// Subclasses overriding this method must call `super.didChangeMetrics()`.
  @mustCallSuper
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Add a post-frame callback to ensure MediaQuery has updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Now it's safe to read the updated MediaQuery
      //eg: context.read<MediaQueryCubit>().refresh(context);
    });
  }

  /// Called when the platform's brightness changes, i.e. the OS switches
  /// between light and dark mode.
  ///
  /// The default implementation does nothing. Override to react — for
  /// example, to update a theme controller that is not already driven by
  /// [MediaQuery.platformBrightnessOf].
  ///
  /// There is no need to call `super` from an override.
  @override
  void didChangePlatformBrightness() {}

  /// Called when the platform's text scale factor changes.
  ///
  /// Reads the new value from [PlatformDispatcher.textScaleFactor] and
  /// forwards it to [reportTextScaleFactor]. Subclasses should normally
  /// override [reportTextScaleFactor] rather than this method, since that
  /// hook also receives the initial value during [initState].
  ///
  /// Subclasses overriding this method must call
  /// `super.didChangeTextScaleFactor()`.
  @mustCallSuper
  @override
  void didChangeTextScaleFactor() {
    final textScaleFactor =
        WidgetsBinding.instance.platformDispatcher.textScaleFactor;
    reportTextScaleFactor(textScaleFactor);
  }

  /// Unregisters this state as a [WidgetsBindingObserver].
  ///
  /// Subclasses overriding this method must call `super.dispose()`, and
  /// should do so **last**, after releasing their own resources.
  @mustCallSuper
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called exactly once, after the first frame has been laid out and
  /// painted.
  ///
  /// This is the correct place for work that requires a fully built tree:
  /// reading [MediaQuery] values, showing a dialog or snack bar, triggering
  /// navigation, or kicking off an initial data load that needs the
  /// [BuildContext].
  ///
  /// [context] is this state's [State.context], passed for convenience.
  /// Because the frame has already completed, it is safe to call
  /// `Navigator.of(context)`, `ScaffoldMessenger.of(context)`, and similar.
  ///
  /// Guard against the widget having been unmounted before the callback runs
  /// (for example, if it was pushed and immediately popped) by checking
  /// [State.mounted] before touching the tree.
  ///
  /// The default implementation does nothing; there is no need to call
  /// `super` from an override.
  void afterFirstLayout(BuildContext context) {}

  /// Called with the platform's current text scale factor.
  ///
  /// Invoked once during [initState] with the initial value, and again from
  /// [didChangeTextScaleFactor] whenever the user changes the system
  /// font-scaling setting.
  ///
  /// [textScaleFactor] is the raw value from
  /// [PlatformDispatcher.textScaleFactor] — `1.0` means no scaling. It is
  /// typed nullable to allow subclasses to accept callers that may not have
  /// a value yet; the framework itself always supplies a non-null double.
  ///
  /// The default implementation does nothing; there is no need to call
  /// `super` from an override.
  void reportTextScaleFactor(double? textScaleFactor) {}
}

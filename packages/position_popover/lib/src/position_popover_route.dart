// packages/position_popover/lib/src/position_popover_route.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:position_popover/src/popover_layout_delegate.dart'
    show PopoverLayoutDelegate;

/// A modal [PopupRoute] that lays [popover] out against [anchor] and owns
/// the optional [timeout].
///
/// The route is normally pushed by [PositionPopover], but it is public so
/// it can be pushed directly when the anchor rectangle is already known —
/// from a long-press, a drag, or a render object measured elsewhere.
///
/// `T` is the type the route pops with. Three things pop it:
///
/// * [popover] itself, via `Navigator.pop<T>(context, value)`;
/// * a tap on the barrier, when [barrierDismissible] is `true`, which pops
///   with `null`;
/// * [timeout] elapsing, which pops with `null`.
///
/// The route fades in and out over [transitionDuration]; the barrier is
/// animated by [PopupRoute] on the same curve.
///
/// ## Coordinate space
///
/// [anchor] must be expressed in the coordinate space of the navigator's
/// overlay, because that is the box [buildPage] is laid out in. A rectangle
/// in global coordinates is only equivalent when the navigator fills the
/// window.
///
/// See also:
///
/// * [PopoverLayoutDelegate], which turns [anchor] and [alignment] into a
///   position.
/// * [PositionPopover], the trigger widget that pushes this route.
class PositionPopoverRoute<T> extends PopupRoute<T> {
  /// Creates a popover route.
  ///
  /// [_barrierDismissible] and [_barrierColor] are stored privately and
  /// exposed through the [PopupRoute] getters of the same name.
  PositionPopoverRoute({
    required this.popover,
    required this.anchor,
    required this.alignment,
    required this._barrierDismissible,
    required this._barrierColor,
    this.timeout,
  });

  /// The widget displayed by this route.
  ///
  /// It is laid out with loosened constraints, so it sizes itself, and it
  /// provides its own surface (for example a [Material]). It closes the
  /// route with `Navigator.pop<T>(context, value)`.
  final Widget popover;

  /// The rectangle [popover] is positioned against, in overlay coordinates.
  final Rect anchor;

  /// How [popover] is placed relative to [anchor].
  ///
  /// See [PopoverLayoutDelegate] for the positioning rules and worked
  /// examples.
  final Alignment alignment;

  /// How long the route stays open before popping with `null`.
  ///
  /// The timer is armed in [didPush] and cancelled in [dispose], so a route
  /// popped early never fires it. When it does fire, the route pops only if
  /// it is still the current route; a route covered by another is left
  /// alone. `null` disables the timeout.
  final Duration? timeout;

  final bool _barrierDismissible;
  final Color _barrierColor;

  /// The pending timeout, if [timeout] was set.
  Timer? _timer;

  /// Whether tapping the barrier pops the route with `null`.
  @override
  bool get barrierDismissible => _barrierDismissible;

  /// The colour painted over the page behind [popover].
  @override
  Color get barrierColor => _barrierColor;

  /// The accessibility label announced for the barrier by screen readers.
  ///
  /// Required to be non-null whenever [barrierDismissible] is `true`; the
  /// framework asserts this in debug mode.
  @override
  String get barrierLabel => 'Dismiss popover';

  /// The fade-in and fade-out duration.
  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  /// Arms the timeout, then performs the normal push transition.
  @override
  TickerFuture didPush() {
    _startTimeout();
    return super.didPush();
  }

  /// Cancels any pending timeout before the route is released.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Arms [_timer] when [timeout] is set.
  void _startTimeout() {
    final duration = timeout;
    if (duration == null) {
      return;
    }
    _timer = Timer(duration, _dismissOnTimeout);
  }

  /// Pops this route with `null` if it is still the current route.
  ///
  /// The [isCurrent] guard prevents the timer from popping whatever route
  /// happens to be on top when another route has been pushed over this
  /// one in the meantime.
  void _dismissOnTimeout() {
    if (isCurrent) {
      navigator?.pop<T>();
    }
  }

  /// Lays [popover] out against [anchor] using [PopoverLayoutDelegate].
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return CustomSingleChildLayout(
      delegate: PopoverLayoutDelegate(
        anchor: anchor,
        alignment: alignment,
      ),
      child: popover,
    );
  }

  /// Fades the page in and out; the barrier is animated by [PopupRoute].
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

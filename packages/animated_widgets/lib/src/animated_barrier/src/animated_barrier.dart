// packages/animated_barrier/lib/src/animated_barrier.dart

// ignore_for_file: public_member_api_docs, document_ignores

part of '../animated_barrier.dart';

typedef _DismissFn = void Function(VoidCallback? onComplete);

/// A handle to a shown [AnimatedBarrier]. Call [dismiss] to animate it away.
class PopoverHandle {
  PopoverHandle._();

  _DismissFn? _dismiss;
  bool _dismissed = false;

  // ignore: use_setters_to_change_properties
  void _bind(_DismissFn dismiss) => _dismiss = dismiss;

  /// Animates the popover out using the same [BarrierAnimation] that brought
  /// it in (run in reverse from its current value), then removes the overlay
  /// entry, restores the status bar if it was hidden, and finally invokes
  /// [onComplete].
  ///
  /// Safe to call more than once; subsequent calls are no-ops.
  void dismiss({
    VoidCallback? onComplete,
  }) {
    if (_dismissed) {
      onComplete?.call();
      return;
    }
    _dismissed = true;
    _dismiss?.call(onComplete);
  }

  Future<void> dismissAsync({
    bool hideStatusBar = false,
    VoidCallback? onComplete,
  }) async {
    await StatusBarChameleon.setStatusBarHidden(hidden: hideStatusBar);
    dismiss(onComplete: onComplete);
  }
}

/// A full-screen animated barrier with a positioned child on top.
///
/// The barrier covers the entire screen and animates in on [show] and out on
/// [PopoverHandle.dismiss] using the same [BarrierAnimation] spec, run in
/// reverse on exit. The child rides along with the barrier (same opacity and
/// slide transform), so a tap that dismisses the barrier sees both fade or
/// slide off together.
///
/// Sizing: [childSize] is a maximum constraint, not a forced size. When null
/// it defaults to 80% of the safe-area width and 50% of its height. The child
/// sizes itself within that bound (a [ListView] of 100 items hits the height
/// cap and scrolls; a small menu stays small).
///
/// Positioning: see [PopoverPosition]. The popover resolves against the safe
/// area using the child's *measured* size, walking the position's fallback
/// chain to the first side that fits, else centering.
class AnimatedBarrier {
  const AnimatedBarrier({
    required this.child,
    this.position,
    this.childSize,
    this.barrierColor = Colors.black87,
    this.barrierDismissible = true,
    this.barrierAnimation = const FadeBarrier(),
    this.hapticIntensity = HapticIntensity.light,
  });

  /// HapticIntensity for the barrier
  final HapticIntensity hapticIntensity;

  /// The content to display on top of the barrier.
  final Widget child;

  /// Where to place the popover. When null, the popover is centered.
  final PopoverPosition? position;

  /// Maximum size of the popover. When null, defaults to
  /// 80% width × 50% height of the safe area.
  final Size? childSize;

  /// The full-screen barrier color drawn behind the popover at full opacity.
  /// The animation modulates this color's effective opacity.
  final Color barrierColor;

  /// Whether tapping the barrier dismisses the popover.
  final bool barrierDismissible;

  /// How the barrier and child animate in and out. See [BarrierAnimation].
  final BarrierAnimation barrierAnimation;

  /// Inserts the popover into the root overlay and animates it in.
  ///
  /// Returns a [PopoverHandle] immediately; [onComplete] fires when the
  /// entrance animation finishes.
  PopoverHandle show(
    BuildContext context, {
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final handle = PopoverHandle._();
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AnimatedBarrierLayer(
        spec: this,
        handle: handle,
        overlayEntry: entry,
        onShown: onComplete,
        hapticIntensity: hapticIntensity,
      ),
    );
    overlay.insert(entry);
    return handle;
  }

  Future<PopoverHandle?> showAsync(
    BuildContext context, {
    VoidCallback? onComplete,
    bool hideStatusBar = true,
  }) async {
    await StatusBarChameleon.setStatusBarHidden(hidden: hideStatusBar);
    if (context.mounted) return show(context, onComplete: onComplete);
    return null;
  }
}

/// Owns the [AnimationController] and drives the entrance/exit. Also handles
/// the anchor-missing case by dismissing post-frame.
class _AnimatedBarrierLayer extends StatefulWidget {
  const _AnimatedBarrierLayer({
    required this.spec,
    required this.handle,
    required this.overlayEntry,
    required this.onShown,
    this.hapticIntensity,
  });

  final AnimatedBarrier spec;
  final PopoverHandle handle;
  final OverlayEntry overlayEntry;
  final VoidCallback? onShown;
  final HapticIntensity? hapticIntensity;

  @override
  State<_AnimatedBarrierLayer> createState() => _AnimatedBarrierLayerState();
}

class _AnimatedBarrierLayerState extends State<_AnimatedBarrierLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  VoidCallback? _pendingOnDismissed;

  @override
  void initState() {
    super.initState();
    final anim = widget.spec.barrierAnimation;
    _controller = AnimationController(
      vsync: this,
      duration: anim.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: anim.curve,
      reverseCurve: anim.curve.flipped,
    );

    widget.handle._bind(_handleDismiss);
    _controller.addStatusListener(_handleStatusChange);
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatusChange)
      ..dispose();
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onShown?.call();
    } else if (status == AnimationStatus.dismissed) {
      // Reverse finished → tear down.
      widget.overlayEntry.remove();
      _pendingOnDismissed?.call();
      _pendingOnDismissed = null;
    }
  }

  /// Called by [PopoverHandle.dismiss]. Reverses from whatever value the
  /// controller is currently at, so a tap during the entrance still gives a
  /// smooth exit.
  void _handleDismiss(VoidCallback? onComplete) {
    _pendingOnDismissed = onComplete;
    unawaited(_controller.reverse());
  }

  void _onBarrierTap() {
    if (!widget.spec.barrierDismissible) return;
    widget.hapticIntensity?.trigger();
    widget.handle.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final position = spec.position ?? PopoverPosition.center();

    final mediaQuery = MediaQuery.of(context);
    final safeArea = mediaQuery.padding.deflateRect(
      Offset.zero & mediaQuery.size,
    );

    final maxSize =
        spec.childSize ?? Size(safeArea.width * 0.8, safeArea.height * 0.5);

    Rect? anchorRect;
    if (position._placement != Placement.center) {
      anchorRect = position._anchorRect();

      final anchorVisible = anchorRect != null && anchorRect.overlaps(safeArea);
      if (!anchorVisible) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.handle.dismiss(),
        );
        return const SizedBox.shrink();
      }
    }

    final transition = _BarrierTransition.forSpec(
      spec.barrierAnimation,
      mediaQuery.size,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onBarrierTap,
                child: transition.applyToBarrier(
                  t,
                  ColoredBox(color: spec.barrierColor),
                ),
              ),
            ),
            CustomSingleChildLayout(
              delegate: _PopoverLayoutDelegate(
                chain: position._fallbackChain,
                anchor: anchorRect,
                bounds: safeArea,
                maxSize: maxSize,
              ),
              child: GestureDetector(
                onTap: () {}, // swallow taps so they don't reach the barrier
                child: transition.applyToChild(
                  t,
                  Material(
                    type: MaterialType.transparency,
                    child: spec.child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Strategy that turns a [BarrierAnimation] variant into transforms applied
/// to the barrier and child each frame. Centralizing the exhaustive switch
/// here means adding a new variant only touches this factory.
class _BarrierTransition {
  const _BarrierTransition._({
    required this.barrierOpacity,
    required this.childOpacity,
    required this.translation,
  });

  /// `t` is the eased animation value in `[0, 1]`. `screen` is the full screen
  /// size, used to translate the child fully off-screen for slide variants.
  factory _BarrierTransition.forSpec(BarrierAnimation spec, Size screen) {
    switch (spec) {
      case FadeBarrier():
        return _BarrierTransition._(
          barrierOpacity: (t) => t,
          childOpacity: (t) => t,
          translation: (_) => Offset.zero,
        );
      case SlideFromTopBarrier():
        return _BarrierTransition._(
          barrierOpacity: (t) => t,
          childOpacity: (t) => t,
          translation: (t) => Offset(0, -screen.height * (1 - t)),
        );
      case SlideFromBottomBarrier():
        return _BarrierTransition._(
          barrierOpacity: (t) => t,
          childOpacity: (t) => t,
          translation: (t) => Offset(0, screen.height * (1 - t)),
        );
    }
  }

  final double Function(double t) barrierOpacity;
  final double Function(double t) childOpacity;
  final Offset Function(double t) translation;

  Widget applyToBarrier(double t, Widget barrier) {
    final offset = translation(t);
    final faded = Opacity(
      opacity: barrierOpacity(t).clamp(0.0, 1.0),
      child: barrier,
    );
    return offset == Offset.zero
        ? faded
        : Transform.translate(offset: offset, child: faded);
  }

  Widget applyToChild(double t, Widget child) {
    final offset = translation(t);
    final faded = Opacity(
      opacity: childOpacity(t).clamp(0.0, 1.0),
      child: child,
    );
    return offset == Offset.zero
        ? faded
        : Transform.translate(offset: offset, child: faded);
  }
}

/// Lays out the popover child: bounds its size to [maxSize], then positions it
/// using the child's measured size against the fallback [chain].
class _PopoverLayoutDelegate extends SingleChildLayoutDelegate {
  const _PopoverLayoutDelegate({
    required this.chain,
    required this.anchor,
    required this.bounds,
    required this.maxSize,
  });

  final List<Placement> chain;
  final Rect? anchor;
  final Rect bounds;
  final Size maxSize;

  /// Constrain the child to at most [maxSize] (and never larger than bounds).
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      maxWidth: maxSize.width.clamp(0.0, bounds.width),
      maxHeight: maxSize.height.clamp(0.0, bounds.height),
    );
  }

  /// [childSize] is the child's REAL laid-out size. Walk the chain and return
  /// the top-left of the first side whose rect fits; else center.
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    for (final side in chain) {
      final rect = _rectForSide(side, childSize);
      if (bounds.contains(rect.topLeft) && bounds.contains(rect.bottomRight)) {
        return rect.topLeft;
      }
    }
    // Unreachable: every fallback chain terminates in Placement.center,
    // and a center rect always fits because the child is constrained to
    // <= bounds above. This trailing return only satisfies the analyzer's
    // definite-return check.
    return _centerRect(childSize).topLeft; // coverage:ignore-line
  }

  Rect _rectForSide(Placement placement, Size size) {
    final anchorRect = anchor;
    if (anchorRect == null) return _centerRect(size);

    switch (placement) {
      case .left:
        final top = _clamp(
          anchorRect.center.dy - size.height / 2,
          bounds.top,
          bounds.bottom - size.height,
        );
        return Rect.fromLTWH(
          anchorRect.left - size.width,
          top,
          size.width,
          size.height,
        );
      case .right:
        final top = _clamp(
          anchorRect.center.dy - size.height / 2,
          bounds.top,
          bounds.bottom - size.height,
        );
        return Rect.fromLTWH(anchorRect.right, top, size.width, size.height);
      case .top:
        final left = _clamp(
          anchorRect.center.dx - size.width / 2,
          bounds.left,
          bounds.right - size.width,
        );
        return Rect.fromLTWH(
          left,
          anchorRect.top - size.height,
          size.width,
          size.height,
        );
      case .bottom:
        final left = _clamp(
          anchorRect.center.dx - size.width / 2,
          bounds.left,
          bounds.right - size.width,
        );
        return Rect.fromLTWH(left, anchorRect.bottom, size.width, size.height);
      case .center:
        return _centerRect(size);
    }
  }

  Rect _centerRect(Size size) => Rect.fromLTWH(
    bounds.left + (bounds.width - size.width) / 2,
    bounds.top + (bounds.height - size.height) / 2,
    size.width,
    size.height,
  );

  /// Clamps [value] into `[min, max]`, tolerating an inverted range when the
  /// size exceeds the bounds on that axis.
  double _clamp(double value, double min, double max) =>
      max < min ? min : value.clamp(min, max);

  @override
  bool shouldRelayout(_PopoverLayoutDelegate oldDelegate) {
    return chain != oldDelegate.chain ||
        anchor != oldDelegate.anchor ||
        bounds != oldDelegate.bounds ||
        maxSize != oldDelegate.maxSize;
  }
}

// packages/position_popover/lib/src/position_popover.dart

part of 'package:position_popover/position_popover.dart';

/// A handle to a shown [PositionPopover]. Call [dismiss] to remove it.
class PopoverHandle {
  PopoverHandle._(this._remove);

  final VoidCallback _remove;
  bool _dismissed = false;

  /// Removes the popover from the overlay. Safe to call more than once.
  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _remove();
  }
}

/// An overlay popover that positions [child] relative to an anchor.
///
/// Sizing: [childSize] is a maximum constraint, not a forced size. When null
/// it defaults to 80% of the safe-area width and 50% of its height. The child
/// sizes itself within that bound (a [ListView] of 100 items hits the height
/// cap and scrolls; a small menu stays small).
///
/// Positioning: see [PopoverPosition]. The popover resolves against the safe
/// area using the child's *measured* size, walking the position's fallback
/// chain to the first side that fits, else centering.
class PositionPopover {
  const PositionPopover({
    required this.child,
    this.position,
    this.childSize,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
  });

  /// The content to display.
  final Widget child;

  /// Where to place the popover. When null, the popover is centered.
  final PopoverPosition? position;

  /// Maximum size of the popover. When null, defaults to
  /// 80% width × 50% height of the safe area.
  final Size? childSize;

  /// The full-screen barrier color drawn behind the popover.
  final Color barrierColor;

  /// Whether tapping the barrier dismisses the popover.
  final bool barrierDismissible;

  /// Inserts the popover into the root overlay and returns a [PopoverHandle].
  PopoverHandle show(BuildContext context) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    late final PopoverHandle handle;

    entry = OverlayEntry(
      builder: (context) => _PositionPopoverLayer(
        spec: this,
        onDismiss: () => handle.dismiss(),
      ),
    );

    handle = PopoverHandle._(entry.remove);
    overlay.insert(entry);
    return handle;
  }
}

/// The overlay layer: barrier + positioned child. Dismisses if the anchor is
/// not present and visible.
class _PositionPopoverLayer extends StatelessWidget {
  const _PositionPopoverLayer({
    required this.spec,
    required this.onDismiss,
  });

  final PositionPopover spec;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final position = spec.position ?? PopoverPosition.center();

    final mediaQuery = MediaQuery.of(context);
    final safeArea = mediaQuery.padding.deflateRect(
      Offset.zero & mediaQuery.size,
    );

    final maxSize =
        spec.childSize ?? Size(safeArea.width * 0.8, safeArea.height * 0.5);

    Rect? anchorRect;
    if (position._side != _AnchorSide.center) {
      anchorRect = position._anchorRect();

      final anchorVisible = anchorRect != null && anchorRect.overlaps(safeArea);
      if (!anchorVisible) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onDismiss());
        return const SizedBox.shrink();
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: spec.barrierDismissible ? onDismiss : null,
            child: ColoredBox(color: spec.barrierColor),
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
            child: Material(
              type: MaterialType.transparency,
              child: spec.child,
            ),
          ),
        ),
      ],
    );
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

  final List<_AnchorSide> chain;
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
    return _centerRect(childSize).topLeft;
  }

  Rect _rectForSide(_AnchorSide side, Size size) {
    final anchorRect = anchor;
    if (anchorRect == null) return _centerRect(size);

    switch (side) {
      case _AnchorSide.left:
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
      case _AnchorSide.right:
        final top = _clamp(
          anchorRect.center.dy - size.height / 2,
          bounds.top,
          bounds.bottom - size.height,
        );
        return Rect.fromLTWH(anchorRect.right, top, size.width, size.height);
      case _AnchorSide.top:
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
      case _AnchorSide.bottom:
        final left = _clamp(
          anchorRect.center.dx - size.width / 2,
          bounds.left,
          bounds.right - size.width,
        );
        return Rect.fromLTWH(left, anchorRect.bottom, size.width, size.height);
      case _AnchorSide.center:
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

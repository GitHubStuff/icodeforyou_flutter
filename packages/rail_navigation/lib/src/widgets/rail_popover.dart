// packages/rail_navigation/lib/src/widgets/rail_popover.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';

/// The fixed width of the popover surface.
const double _kPopoverWidth = 240;

/// The fixed height of a tile row, shared by the scroll tick, the
/// height quantum, and `RailPopoverTile`.
const double _kTileExtent = 48;

/// The maximum number of whole tiles visible at once; content beyond
/// this scrolls.
const int _kMaxVisibleTiles = 6;

/// Vertical padding inside the scrolling list, per the Material 3 menu
/// convention.
///
/// Keeps the first and last tiles clear of the surface's rounded-corner
/// clip; the padding scrolls with the list, so mid-list tiles still run
/// edge to edge.
const double _kListVerticalPadding = 8;

/// The maximum height of the popover surface.
///
/// Derived, not arbitrary: exactly [_kMaxVisibleTiles] whole tiles plus
/// the list padding, so the viewport at rest never ends mid-tile.
const double _kPopoverMaxHeight =
    _kMaxVisibleTiles * _kTileExtent + 2 * _kListVerticalPadding;

/// The gap between the anchor button and the popover surface.
const double _kAnchorGap = 8;

/// The minimum margin kept between the popover and the safe-area edge
/// of the screen.
const double _kScreenMargin = 8;

/// The corner radius of the popover surface.
const double _kPopoverRadius = 12;

/// The screen edge the anchor is nearest to, which determines the
/// direction the popover opens.
enum _PopoverEdge {
  /// Anchor sits on a bottom rail; the popover opens upward.
  bottom,

  /// Anchor sits on a left rail; the popover opens to the right.
  left,

  /// Anchor sits on a right rail; the popover opens to the left.
  right,
}

/// Shows a scrolling popover anchored to the widget that owns
/// [anchorContext], and returns the value the user selects.
///
/// The popover opens away from the screen edge the anchor is nearest
/// to — upward from a bottom rail, rightward from a left rail,
/// leftward from a right rail — so no placement parameter is needed;
/// the geometry is derived from the anchor itself.
///
/// [children] are the rows to display, typically `RailPopoverTile`s,
/// and are assumed to be the standard 48dp tile height: the scroll
/// haptic tick, the height quantum, and [initialScrollIndex] are all
/// built on that row extent. A tile completes the returned future by
/// popping with its value. Every dismissal path — barrier tap, back
/// button, escape — completes the future with `null`; `null` is the
/// cancel signal, per the standard `showDialog`/`showMenu` contract.
///
/// When the list scrolls, a scrollbar is shown so the presence,
/// position, and extent of off-screen tiles is visible; lists that fit
/// show no scrollbar.
///
/// [initialScrollIndex] scrolls the list so the tile at that index is
/// visible when the popover opens — pass the currently selected tile's
/// index so its highlight is on screen from the first frame. The
/// offset self-clamps, so an index near the end of a short list is
/// safe. Defaults to opening at the top.
///
/// [scrollHaptic] fires once per tile-height of scrolling, giving a
/// subtle picker-wheel tick. Defaults to [HapticIntensity.light];
/// [HapticIntensity.selection] is the platform-intended scroll tick
/// and the subtlest choice; [HapticIntensity.none] disables ticking.
Future<T?> showRailPopover<T>({
  required BuildContext anchorContext,
  required List<Widget> children,
  int initialScrollIndex = 0,
  HapticIntensity scrollHaptic = HapticIntensity.light,
}) {
  final navigator = Navigator.of(anchorContext);
  final anchorBox = anchorContext.findRenderObject()! as RenderBox;
  final overlayBox =
      navigator.overlay!.context.findRenderObject()! as RenderBox;
  final anchorRect =
      anchorBox.localToGlobal(Offset.zero, ancestor: overlayBox) &
      anchorBox.size;

  return navigator.push(
    _RailPopoverRoute<T>(
      anchorRect: anchorRect,
      initialScrollIndex: initialScrollIndex,
      scrollHaptic: scrollHaptic,
      barrierDismissLabel: MaterialLocalizations.of(
        anchorContext,
      ).modalBarrierDismissLabel,
      children: children,
    ),
  );
}

/// The transparent-barrier popup route hosting the popover surface.
class _RailPopoverRoute<T> extends PopupRoute<T> {
  _RailPopoverRoute({
    required this.anchorRect,
    required this.initialScrollIndex,
    required this.scrollHaptic,
    required this.barrierDismissLabel,
    required this.children,
  });

  /// The anchor button's rect in overlay coordinates.
  final Rect anchorRect;

  /// The tile index scrolled into view when the popover opens.
  final int initialScrollIndex;

  /// The haptic fired as the list scrolls.
  final HapticIntensity scrollHaptic;

  /// The semantic label for the dismiss barrier.
  final String barrierDismissLabel;

  /// The rows displayed in the popover.
  final List<Widget> children;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => barrierDismissLabel;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // Deliberately NOT wrapped in SafeArea: the layout delegate
    // positions in overlay coordinates and clamps against the safe
    // padding itself. Wrapping in SafeArea would shift the layout's
    // coordinate space while the anchor rect stayed in overlay
    // coordinates, rendering the popover offset by the insets.
    return CustomSingleChildLayout(
      delegate: _RailPopoverLayoutDelegate(
        anchorRect: anchorRect,
        safePadding: MediaQuery.paddingOf(context),
      ),
      child: FadeTransition(
        opacity: animation,
        child: _RailPopoverSurface(
          initialScrollIndex: initialScrollIndex,
          scrollHaptic: scrollHaptic,
          children: children,
        ),
      ),
    );
  }
}

/// Positions the popover adjacent to the anchor, opening away from the
/// nearest screen edge and clamped inside the safe, margined bounds.
///
/// All geometry lives in one coordinate space: the overlay's. The
/// delegate's own layout size is the overlay size, the anchor rect was
/// resolved against the overlay, and [safePadding] is clamped against
/// that same space.
class _RailPopoverLayoutDelegate extends SingleChildLayoutDelegate {
  _RailPopoverLayoutDelegate({
    required this.anchorRect,
    required this.safePadding,
  });

  /// The anchor button's rect in overlay coordinates.
  final Rect anchorRect;

  /// The safe-area insets of the screen.
  final EdgeInsets safePadding;

  /// The screen edge the anchor hugs, by shortest distance from its
  /// center within [size].
  _PopoverEdge _edgeFor(Size size) {
    final center = anchorRect.center;
    final toLeft = center.dx;
    final toRight = size.width - center.dx;
    final toBottom = size.height - center.dy;

    if (toBottom <= toLeft && toBottom <= toRight) {
      return _PopoverEdge.bottom;
    }
    return toLeft <= toRight ? _PopoverEdge.left : _PopoverEdge.right;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return const BoxConstraints(
      maxWidth: _kPopoverWidth,
      maxHeight: _kPopoverMaxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final minX = safePadding.left + _kScreenMargin;
    final maxX =
        size.width - safePadding.right - _kScreenMargin - childSize.width;
    final minY = safePadding.top + _kScreenMargin;
    final maxY =
        size.height - safePadding.bottom - _kScreenMargin - childSize.height;

    double x;
    double y;
    switch (_edgeFor(size)) {
      case _PopoverEdge.bottom:
        x = anchorRect.center.dx - childSize.width / 2;
        y = anchorRect.top - _kAnchorGap - childSize.height;
      case _PopoverEdge.left:
        x = anchorRect.right + _kAnchorGap;
        y = anchorRect.center.dy - childSize.height / 2;
      case _PopoverEdge.right:
        x = anchorRect.left - _kAnchorGap - childSize.width;
        y = anchorRect.center.dy - childSize.height / 2;
    }

    return Offset(x.clamp(minX, maxX), y.clamp(minY, maxY));
  }

  @override
  bool shouldRelayout(_RailPopoverLayoutDelegate oldDelegate) {
    return anchorRect != oldDelegate.anchorRect ||
        safePadding != oldDelegate.safePadding;
  }
}

/// The visible popover surface: an elevated, rounded, scrolling list
/// that ticks [scrollHaptic] once per tile height scrolled, opens
/// scrolled to [initialScrollIndex], and shows a scrollbar when the
/// content overflows.
class _RailPopoverSurface extends StatefulWidget {
  const _RailPopoverSurface({
    required this.initialScrollIndex,
    required this.scrollHaptic,
    required this.children,
  });

  /// The tile index scrolled into view when the popover opens.
  final int initialScrollIndex;

  /// The haptic fired as the list scrolls.
  final HapticIntensity scrollHaptic;

  /// The rows displayed in the popover.
  final List<Widget> children;

  @override
  State<_RailPopoverSurface> createState() => _RailPopoverSurfaceState();
}

class _RailPopoverSurfaceState extends State<_RailPopoverSurface> {
  /// Scroll distance accumulated since the last haptic tick.
  double _sinceLastTick = 0;

  /// Controls the list's initial offset; the position self-clamps if
  /// the offset exceeds the content's scroll extent. Shared with the
  /// scrollbar.
  late final ScrollController _controller = ScrollController(
    initialScrollOffset: widget.initialScrollIndex * _kTileExtent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _onScrollUpdate(ScrollUpdateNotification notification) {
    if (widget.scrollHaptic == HapticIntensity.none) return false;

    final delta = notification.scrollDelta;
    if (delta == null) return false;

    _sinceLastTick += delta.abs();
    if (_sinceLastTick >= _kTileExtent) {
      _sinceLastTick %= _kTileExtent;
      widget.scrollHaptic.trigger();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(_kPopoverRadius)),
      ),
      child: SizedBox(
        width: _kPopoverWidth,
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: _onScrollUpdate,
          child: Scrollbar(
            controller: _controller,
            thumbVisibility: true,
            child: ListView(
              controller: _controller,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                vertical: _kListVerticalPadding,
              ),
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}

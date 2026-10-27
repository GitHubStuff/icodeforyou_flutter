// packages/position_popover/lib/src/position_popover.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:position_popover/src/position_popover_route.dart'
    show PositionPopoverRoute;

/// Wraps [parent] in a single tap that opens [popover] positioned at
/// [alignment] relative to [parent], and reports the popover's result
/// through [onResult].
///
/// `T` is the type of value the popover may return. Every outcome is
/// delivered as `T?`, where `null` means "no value": a barrier tap,
/// [timeout] elapsing, or an explicit pop with no value.
///
/// ## Layout
///
/// The widget renders a horizontal strip: [leadingIcon], [parent],
/// [trailingIcon], in that order, with the icons omitted when `null`. Only
/// [parent] is tappable; the icons sit outside the tap area and own their
/// own gesture handling, so a trailing clear button, for example, never
/// opens the popover. The whole strip is drawn inside [decoration], inset
/// by [padding], which lets a border or background visually group all
/// three.
///
/// ## Lifecycle
///
/// 1. The user taps [parent].
/// 2. [parent]'s on-screen rectangle is captured relative to the nearest
///    [Navigator]'s overlay. Icons, [padding] and [decoration] are not
///    part of that rectangle.
/// 3. [hapticIntensity] fires.
/// 4. A [PositionPopoverRoute] is pushed, painting [barrierColor] over the
///    page and laying [popover] out against the captured rectangle.
/// 5. The route pops, and [onResult] receives the popped value.
///
/// ## Closing the popover
///
/// [popover] closes itself with `Navigator.pop<T>(context, value)`.
/// Popping with no value, tapping the barrier (when [barrierDismissible]
/// is `true`), or reaching [timeout] all deliver `null` to [onResult].
///
/// ## Positioning
///
/// [alignment] selects a point on [parent]'s rectangle; the popover is
/// placed so that its mirrored point (`-alignment`) sits there. So
/// [Alignment.center] overlays the parent, [Alignment.topCenter] places the
/// popover directly above it, and [Alignment.bottomRight] hangs it below
/// and to the right. The default, [standard], partially overlaps the
/// parent toward its lower-right. A popover that would leave the overlay
/// is slid back inside along the offending axis; see
/// [PopoverLayoutDelegate] for details.
///
/// ## Example
///
/// ```dart
/// PositionPopover<DateTime>(
///   alignment: Alignment.bottomCenter,
///   decoration: BoxDecoration(border: Border.all()),
///   padding: const EdgeInsets.symmetric(horizontal: 8),
///   leadingIcon: const Icon(Icons.calendar_today),
///   trailingIcon: IconButton(
///     icon: const Icon(Icons.clear),
///     onPressed: clearDate,
///   ),
///   onResult: (DateTime? picked) => setDate(picked),
///   parent: Text(formattedDate),
///   popover: const DatePickerPopover(),
/// )
/// ```
///
/// See also:
///
/// * [PositionPopoverRoute], the route this widget pushes.
/// * [PopoverLayoutDelegate], which computes the popover's position.
/// * [PopupMenuButton], Material's equivalent with a fixed menu model.
class PositionPopover<T> extends StatelessWidget {
  /// Creates a popover trigger.
  ///
  /// [parent] and [popover] are required; everything else has a default
  /// documented on the corresponding field.
  const PositionPopover({
    required this.parent,
    required this.popover,
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.decoration,
    this.padding = EdgeInsets.zero,
    this.onResult,
    this.alignment = standard,
    this.barrierDismissible = true,
    this.barrierColor = Colors.black54,
    this.hapticIntensity = HapticIntensity.light,
    this.timeout,
  });

  /// The default [alignment]: right of centre and in the lower part of
  /// [parent], so the popover overlaps the parent while leaving most of it
  /// visible.
  ///
  /// Exposed so callers can reference the default explicitly, for example
  /// as a dropdown option in a design tool.
  static const Alignment standard = Alignment(0.6, 0.8);

  /// The widget that receives the tap and that the popover is positioned
  /// against.
  ///
  /// It is wrapped in a [GestureDetector] with [HitTestBehavior.opaque],
  /// so taps anywhere inside its bounds open the popover, including on
  /// transparent regions. Its rectangle alone forms the anchor; [padding],
  /// [decoration] and the icons are excluded.
  final Widget parent;

  /// The widget shown over [parent] while the route is open.
  ///
  /// It is laid out with loosened constraints, so it sizes itself. It is
  /// responsible for its own surface (for example a [Material]) and for
  /// popping the route with `Navigator.pop<T>(context, value)`.
  final Widget popover;

  /// Optional widget placed before [parent], outside the tap area.
  ///
  /// Typically a static glyph. It receives no gestures from this widget;
  /// give it its own handler if it needs one. Omitted from the row when
  /// `null`.
  final Widget? leadingIcon;

  /// Optional widget placed after [parent], outside the tap area.
  ///
  /// Typically an action such as a clear button. It receives no gestures
  /// from this widget; give it its own handler. Omitted from the row when
  /// `null`.
  final Widget? trailingIcon;

  /// Border, background, and shape drawn around [leadingIcon], [parent],
  /// and [trailingIcon] together.
  ///
  /// Typed as the abstract [Decoration] so [BoxDecoration],
  /// [ShapeDecoration] or a custom decoration all fit. `null` (the
  /// default) draws nothing.
  final Decoration? decoration;

  /// Space between [decoration] and the row it surrounds.
  ///
  /// Applied even when [decoration] is `null`. Defaults to
  /// [EdgeInsets.zero].
  final EdgeInsetsGeometry padding;

  /// Called once with the value the popover popped with, or `null`.
  ///
  /// Invoked after the route has fully popped. `null` is delivered for a
  /// barrier tap, a [timeout], or a pop with no value, so a `null` result
  /// cannot be distinguished from an explicit `null` returned by
  /// [popover]. When this is `null`, the result is discarded.
  final ValueChanged<T?>? onResult;

  /// Where the popover sits relative to [parent].
  ///
  /// The point `alignment.withinRect(parentRect)` is the anchor; the
  /// popover's `-alignment` point is placed on it. Defaults to [standard].
  ///
  /// [Alignment.center] overlays the parent; [Alignment.topCenter] places
  /// the popover above it; [Alignment.bottomRight] hangs it below-right.
  final Alignment alignment;

  /// Whether tapping outside [popover] dismisses it with `null`.
  ///
  /// When `false`, the barrier absorbs taps and the popover can only be
  /// closed by itself or by [timeout]. Defaults to `true`.
  final bool barrierDismissible;

  /// The colour painted over the page behind [popover].
  ///
  /// Defaults to [Colors.black54], the Material modal-barrier colour, which
  /// dims the page on both light and dark themes without hiding it.
  final Color barrierColor;

  /// The haptic fired when the popover opens.
  ///
  /// Triggered after [parent]'s rectangle is captured and before the route
  /// is pushed; it is not awaited. Defaults to [HapticIntensity.light].
  final HapticIntensity hapticIntensity;

  /// How long the popover stays open before dismissing itself with `null`.
  ///
  /// Owned by the route: the timer starts when the route is pushed and is
  /// cancelled when the route is disposed. `null` (the default) disables
  /// the timeout.
  final Duration? timeout;

  @override
  Widget build(BuildContext context) {
    final leading = leadingIcon;
    final trailing = trailingIcon;
    return Container(
      decoration: decoration,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ?leading,
          _Trigger(onTap: _open, child: parent),
          ?trailing,
        ],
      ),
    );
  }

  /// Captures [parent]'s rectangle, fires the haptic, pushes the route,
  /// and forwards the popped value to [onResult].
  ///
  /// [context] is the [_Trigger]'s context, so it is used synchronously
  /// before the push and never after the `await`.
  Future<void> _open(BuildContext context) async {
    final anchor = _anchorRect(context);
    hapticIntensity.trigger();
    final result = await Navigator.of(context).push<T>(
      PositionPopoverRoute<T>(
        popover: popover,
        anchor: anchor,
        alignment: alignment,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        timeout: timeout,
      ),
    );
    onResult?.call(result);
  }

  /// Returns the trigger's rectangle in the overlay's coordinate space.
  ///
  /// [context] must belong to the [_Trigger], so the anchor covers
  /// [parent] alone and not the icons or the surrounding box. Measuring
  /// against the overlay, rather than the global space, keeps the anchor
  /// correct when the navigator itself is inset.
  Rect _anchorRect(BuildContext context) {
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    return topLeft & box.size;
  }
}

/// The tappable region around [PositionPopover.parent].
///
/// Exists so [PositionPopover] has a [BuildContext] whose render object is
/// exactly the parent's bounds, independent of the surrounding [Row]. The
/// context is handed to [onTap] rather than captured, so the anchor is
/// measured from the trigger, not from the row or the decorated box.
class _Trigger extends StatelessWidget {
  /// Creates the tap region.
  const _Trigger({required this.onTap, required this.child});

  /// Receives this widget's own [BuildContext] when [child] is tapped.
  final ValueChanged<BuildContext> onTap;

  /// The tappable content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(context),
      child: child,
    );
  }
}

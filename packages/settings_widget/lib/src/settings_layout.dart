// packages/settings_widget/lib/src/settings_layout.dart
import 'package:flutter/material.dart';
import 'package:settings_widget/src/settings_direction.dart';

/// Positions and dresses the settings surface within the viewport.
///
/// Composes three layers around [child], outermost first:
///
///  1. **[Align]** — anchors the surface to the edge named by [direction]
///     ([Alignment.bottomCenter], [Alignment.topCenter],
///     [Alignment.centerLeft], or [Alignment.centerRight]).
///  2. **[Padding]** — insets the surface [edgeGap] logical pixels from that
///     same edge only, producing the floating-sheet gap; pass `0` for a
///     flush, edge-hugging surface.
///  3. **[Material]** — the sheet chrome: [ColorScheme.surfaceContainerHigh]
///     fill, elevation 6, [_sheetRadius] rounded corners, and
///     [Clip.antiAlias] so the child's content is clipped to the rounded
///     shape rather than bleeding past the corners.
///
/// ## Sizing
///
/// * [SettingsDirection.left] / [SettingsDirection.right]: the surface is
///   drawer-shaped — full viewport height and 85% of viewport width, read
///   from [MediaQuery.sizeOf] so it re-lays-out on rotation or window
///   resize.
/// * [SettingsDirection.top] / [SettingsDirection.bottom]: no size is
///   imposed; the sheet is intrinsically sized by [child], and the stretch
///   behavior inside `SettingsContent` handles the width.
///
/// Every switch in this widget is exhaustive over [SettingsDirection] with
/// no wildcard arm, preserving the enum's compile-time guarantee: a new
/// direction cannot ship until this widget explicitly handles it.
///
/// Layout and chrome only: entrance animation belongs to
/// `SettingsTransition`, content structure to `SettingsContent`. This
/// widget owns no state.
class SettingsLayout extends StatelessWidget {
  /// Creates the positioned, Material-dressed settings surface.
  const SettingsLayout({
    required this.direction,
    required this.edgeGap,
    required this.child,
    super.key,
  });

  /// The viewport edge the surface anchors to.
  ///
  /// Also selects the sizing strategy: horizontal directions produce a
  /// full-height drawer at 85% width; vertical directions defer to the
  /// [child]'s intrinsic size.
  final SettingsDirection direction;

  /// Inset, in logical pixels, between the surface and its anchor edge.
  ///
  /// Applied to the anchor edge only — the remaining three sides get no
  /// padding. `0` yields a flush sheet; a positive value floats it off the
  /// edge.
  final double edgeGap;

  /// The surface content, typically a `SettingsContent`.
  ///
  /// Clipped to the rounded [Material] shape via [Clip.antiAlias].
  final Widget child;

  /// Corner radius, in logical pixels, of the sheet's [Material].
  static const double _sheetRadius = 16;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _alignment,
      child: Padding(
        padding: _padding,
        child: _sized(
          context,
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            elevation: 6,
            borderRadius: BorderRadius.circular(_sheetRadius),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Applies the direction-dependent sizing strategy to [child].
  ///
  /// Horizontal directions ([SettingsDirection.left],
  /// [SettingsDirection.right]) wrap the child in a [SizedBox] at 85% of
  /// viewport width and full viewport height, via [MediaQuery.sizeOf] so
  /// this widget rebuilds when the viewport changes. Vertical directions
  /// ([SettingsDirection.top], [SettingsDirection.bottom]) return the child
  /// untouched to preserve its intrinsic size.
  ///
  /// Deliberately exhaustive — no wildcard arm — so a future
  /// [SettingsDirection] value is a compile error here rather than a silent
  /// fall-through to unsized layout.
  Widget _sized(BuildContext context, Widget child) {
    final size = MediaQuery.sizeOf(context);
    return switch (direction) {
      SettingsDirection.left || SettingsDirection.right => SizedBox(
        width: size.width * 0.85,
        height: size.height,
        child: child,
      ),
      SettingsDirection.top || SettingsDirection.bottom => child,
    };
  }

  /// The [Align] anchor for the current [direction]: bottom-center,
  /// top-center, center-left, or center-right.
  AlignmentGeometry get _alignment => switch (direction) {
    SettingsDirection.bottom => Alignment.bottomCenter,
    SettingsDirection.top => Alignment.topCenter,
    SettingsDirection.left => Alignment.centerLeft,
    SettingsDirection.right => Alignment.centerRight,
  };

  /// [edgeGap] applied to the anchor edge only, as an [EdgeInsets.only]
  /// matching the current [direction].
  EdgeInsets get _padding => switch (direction) {
    SettingsDirection.bottom => EdgeInsets.only(bottom: edgeGap),
    SettingsDirection.top => EdgeInsets.only(top: edgeGap),
    SettingsDirection.left => EdgeInsets.only(left: edgeGap),
    SettingsDirection.right => EdgeInsets.only(right: edgeGap),
  };
}

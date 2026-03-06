// lib/src/_position_resolver.dart
// ---------------------------------------------------------------------------
// _position_resolver.dart — resolves where the modal should be positioned
// on screen relative to its anchor widget.
//
// Single responsibility: given an anchor GlobalKey and screen constraints,
// return a resolved [ModalPlacement] describing the modal's top-left origin
// and which side of the anchor it was placed on.
//
// No Flutter widget state is held here. All methods are static.
// ---------------------------------------------------------------------------

import 'package:adaptive_modal/src/_platform_detector.dart';
import 'package:adaptive_modal/src/types.dart';
import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// ModalPlacement
// ---------------------------------------------------------------------------

/// The resolved screen-space position for the modal and which side it landed on.
class ModalPlacement {
  /// Constructor
  const ModalPlacement({
    required this.left,
    required this.top,
    required this.position,
  });

  /// Left edge of the modal in logical pixels from the screen origin.
  final double left;

  /// Top edge of the modal in logical pixels from the screen origin.
  final double top;

  /// Which side of the anchor the modal was placed on.
  final AdaptiveModalPosition position;
}

// ---------------------------------------------------------------------------
// PositionResolver
// ---------------------------------------------------------------------------

/// Resolves the on-screen [ModalPlacement] for the modal.
///
// ignore: comment_references
/// On phone the placement is always full-screen — [left] and [top] are zero.
///
/// On large surfaces the resolver attempts to place the modal below the anchor.
/// If it does not fit below, it flips above.  After flipping, the result is
/// clamped to keep the modal within safe screen bounds.
class PositionResolver {
  /// Vertical gap between the anchor edge and the modal edge in logical pixels.
  static const double _anchorGap = 8;

  /// Resolves the [ModalPlacement] for the given [anchorKey] and constraints.
  ///
  /// Returns null if the [anchorKey] has no current [RenderBox] — for example
  /// if the anchor widget is not currently mounted.
  static ModalPlacement? resolve({
    required GlobalKey anchorKey,
    required BuildContext context,
    required double modalWidth,
    required double modalHeight,
  }) {
    if (PlatformDetector.isPhone(context)) {
      return const ModalPlacement(
        left: 0,
        top: 0,
        position: AdaptiveModalPosition.fullScreen,
      );
    }

    final anchor = _anchorRect(anchorKey);
    if (anchor == null) return null;

    final screen = ScreenSize.of(context);
    final safeTop = SafeAreaInsets.top(context);
    final safeBottom = SafeAreaInsets.bottom(context);

    return _resolveLarge(
      anchor: anchor,
      screen: screen,
      safeTop: safeTop,
      safeBottom: safeBottom,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
    );
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Extracts the screen-space [AdaptiveModalAnchorRect] from a [GlobalKey].
  static AdaptiveModalAnchorRect? _anchorRect(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return AdaptiveModalAnchorRect(
      left: offset.dx,
      top: offset.dy,
      width: size.width,
      height: size.height,
    );
  }

  /// Resolves placement on tablet/desktop/web.
  static ModalPlacement _resolveLarge({
    required AdaptiveModalAnchorRect anchor,
    required Size screen,
    required double safeTop,
    required double safeBottom,
    required double modalWidth,
    required double modalHeight,
  }) {
    final spaceBelow = screen.height - anchor.bottom - safeBottom;
    final spaceAbove = anchor.top - safeTop;

    final canFitBelow = spaceBelow >= modalHeight + _anchorGap;
    final placeBelow = canFitBelow || spaceBelow >= spaceAbove;

    final top = placeBelow
        ? anchor.bottom + _anchorGap
        : anchor.top - _anchorGap - modalHeight;

    final left = _resolveLeft(
      anchorCenterX: anchor.centerX,
      modalWidth: modalWidth,
      screenWidth: screen.width,
    );

    // Clamp ranges must have min <= max. If the modal is larger than the
    // available space (common in widgetbook viewports) we clamp to safeTop/0
    // rather than crashing with an invalid range.
    final topMin = safeTop;
    final topMax = (screen.height - safeBottom - modalHeight).clamp(
      safeTop,
      double.infinity,
    );
    final leftMax = (screen.width - modalWidth).clamp(0.0, double.infinity);

    final clampedTop = top.clamp(topMin, topMax);
    final clampedLeft = left.clamp(0.0, leftMax);

    return ModalPlacement(
      left: clampedLeft,
      top: clampedTop,
      position: placeBelow
          ? AdaptiveModalPosition.below
          : AdaptiveModalPosition.above,
    );
  }

  /// Centers the modal horizontally on the anchor, then clamps to screen.
  static double _resolveLeft({
    required double anchorCenterX,
    required double modalWidth,
    required double screenWidth,
  }) {
    return anchorCenterX - modalWidth / 2;
  }
}

// lib/src/types.dart
// ignore_for_file: comment_references, public_member_api_docs
// ---------------------------------------------------------------------------
// types.dart — public and internal value types for the adaptive_modal package.
// ---------------------------------------------------------------------------
import 'package:adaptive_modal/adaptive_modal.dart'
    show AdaptiveModalController;
import 'package:adaptive_modal/src/_controller.dart'
    show AdaptiveModalController;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

// ---------------------------------------------------------------------------
// AdaptiveModalConfig
// ---------------------------------------------------------------------------
// All configurable options for an AdaptiveModal.  This is the only public
// data class the caller needs to know about.  Sane defaults are provided for
// every field so a minimal caller only supplies what it cares about.
// ---------------------------------------------------------------------------

/// Configuration options for [AdaptiveModalController].
///
/// All fields have sensible defaults so callers only need to override what
/// they care about.
///
/// Example — minimal:
/// ```dart
/// AdaptiveModalConfig()
/// ```
///
/// Example — custom close icon and no barrier:
/// ```dart
/// AdaptiveModalConfig(
///   closeIcon: Icon(Icons.arrow_back),
///   barrierDismissible: false,
/// )
/// ```
@immutable
final class AdaptiveModalConfig {
  const AdaptiveModalConfig({
    this.closeIcon,
    this.barrierDismissible = true,
    this.barrierColor = const Color(0x80000000),
    this.maxWidth = 400.0,
    this.maxHeight = 700.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.hapticFeedback = true,
  }) : assert(maxWidth > 0, 'maxWidth must be positive'),
       assert(maxHeight > 0, 'maxHeight must be positive');

  /// Widget rendered as the close button in the top-right corner of the modal.
  ///
  /// Defaults to [Icon(Icons.close)] when null.
  final Widget? closeIcon;

  /// Whether tapping the barrier dismisses the modal.
  ///
  /// When false no barrier is inserted and background widgets remain fully
  /// interactive.  The modal can still be closed via
  /// [AdaptiveModalController.hide] or the built-in close button.
  ///
  /// Defaults to true.
  final bool barrierDismissible;

  /// Color of the full-screen barrier rendered behind the modal.
  ///
  /// Ignored when [barrierDismissible] is false because no barrier is inserted.
  ///
  /// Defaults to [Colors.black54].
  final Color barrierColor;

  /// Maximum width of the modal on tablet, desktop, and web.
  ///
  /// On phone the modal always fills the screen width so this value is ignored.
  ///
  /// Defaults to 400.0 logical pixels.
  final double maxWidth;

  /// Maximum height of the modal on tablet, desktop, and web.
  ///
  /// On phone the modal always fills the screen height so this value is
  /// ignored.
  ///
  /// Defaults to 700.0 logical pixels.
  final double maxHeight;

  /// Duration of the show and hide animation.
  ///
  /// Defaults to 200 milliseconds.
  final Duration animationDuration;

  /// Curve applied to both the show and hide animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  /// Whether to trigger a light haptic impulse when the modal is dismissed.
  ///
  /// Applies to all dismissal paths — close button, barrier tap, and
  /// programmatic [AdaptiveModalController.hide].
  ///
  /// On desktop and web [HapticFeedback] calls are no-ops so this field has
  /// no effect on those platforms.
  ///
  /// Defaults to true.
  final bool hapticFeedback;

  /// Returns a copy of this config with the given fields replaced.
  AdaptiveModalConfig copyWith({
    Widget? closeIcon,
    bool? barrierDismissible,
    Color? barrierColor,
    double? maxWidth,
    double? maxHeight,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? hapticFeedback,
  }) {
    return AdaptiveModalConfig(
      closeIcon: closeIcon ?? this.closeIcon,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      barrierColor: barrierColor ?? this.barrierColor,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdaptiveModalConfig &&
        other.barrierDismissible == barrierDismissible &&
        other.barrierColor == barrierColor &&
        other.maxWidth == maxWidth &&
        other.maxHeight == maxHeight &&
        other.animationDuration == animationDuration &&
        other.animationCurve == animationCurve &&
        other.hapticFeedback == hapticFeedback;
  }

  @override
  int get hashCode => Object.hash(
    barrierDismissible,
    barrierColor,
    maxWidth,
    maxHeight,
    animationDuration,
    animationCurve,
    hapticFeedback,
  );

  @override
  String toString() =>
      'AdaptiveModalConfig('
      'barrierDismissible: $barrierDismissible, '
      'barrierColor: $barrierColor, '
      'maxWidth: $maxWidth, '
      'maxHeight: $maxHeight, '
      'animationDuration: $animationDuration, '
      'animationCurve: $animationCurve, '
      'hapticFeedback: $hapticFeedback'
      ')';
}

// ---------------------------------------------------------------------------
// AdaptiveModalPosition
// ---------------------------------------------------------------------------
// Internal enum describing where the modal was placed relative to its anchor.
// Used by _ModalShell to determine the scale animation origin.
// Not exported — implementation detail only.
// ---------------------------------------------------------------------------

/// Describes which side of the anchor the modal was placed on.
///
/// Used internally to derive the correct [Alignment] for the scale animation
/// origin so the modal always appears to grow from the anchor widget.
enum AdaptiveModalPosition {
  /// Modal is rendered above the anchor widget.
  above,

  /// Modal is rendered below the anchor widget.
  below,

  /// Modal is full screen (phone layout) — scale origin is bottom-center.
  fullScreen,
}

// ---------------------------------------------------------------------------
// AdaptiveModalAnchorRect
// ---------------------------------------------------------------------------
// Internal value object carrying the resolved screen-space geometry of the
// anchor widget.  Produced by _PositionResolver and consumed by
// _OverlayManager.  Not exported.
// ---------------------------------------------------------------------------

/// Screen-space geometry of the anchor widget.
///
/// Produced by [_PositionResolver] and consumed by [_OverlayManager] to
/// position the modal [OverlayEntry] correctly.
class AdaptiveModalAnchorRect {
  const AdaptiveModalAnchorRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
  double get centerX => left + width / 2;

  @override
  String toString() =>
      'AdaptiveModalAnchorRect('
      'left: $left, top: $top, '
      'width: $width, height: $height'
      ')';
}

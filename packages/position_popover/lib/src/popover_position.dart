// packages/position_popover/lib/src/popover_position.dart

part of 'package:position_popover/position_popover.dart';

/// The side of the anchor a [PositionPopover] prefers to occupy.
enum _AnchorSide { left, right, top, bottom, center }

/// Describes where a [PositionPopover] should sit.
///
/// Either anchored to a target widget (via its [GlobalKey]) on a preferred
/// side, or centered on the screen. When the preferred side cannot fit inside
/// the safe area, the popover walks an ordered fallback chain and finally
/// falls back to centering.
class PopoverPosition {
  const PopoverPosition._({
    required this._side,
    this._anchorKey,
  });

  /// Place the popover to the left of [anchorKey].
  ///
  /// Fallback chain: left → below → above → center.
  factory PopoverPosition.left(GlobalKey anchorKey) => PopoverPosition._(
    side: _AnchorSide.left,
    anchorKey: anchorKey,
  );

  /// Place the popover to the right of [anchorKey].
  ///
  /// Fallback chain: right → below → above → center.
  factory PopoverPosition.right(GlobalKey anchorKey) => PopoverPosition._(
    side: _AnchorSide.right,
    anchorKey: anchorKey,
  );

  /// Place the popover above [anchorKey].
  ///
  /// Fallback chain: above → below → center.
  factory PopoverPosition.above(GlobalKey anchorKey) => PopoverPosition._(
    side: _AnchorSide.top,
    anchorKey: anchorKey,
  );

  /// Place the popover below [anchorKey].
  ///
  /// Fallback chain: below → above → center.
  factory PopoverPosition.below(GlobalKey anchorKey) => PopoverPosition._(
    side: _AnchorSide.bottom,
    anchorKey: anchorKey,
  );

  /// Center the popover on the screen, ignoring any anchor.
  factory PopoverPosition.center() => const PopoverPosition._(
    side: _AnchorSide.center,
  );

  final _AnchorSide _side;
  final GlobalKey? _anchorKey;

  /// Ordered sides to try; the first whose rect fits inside the safe area
  /// wins. Always terminates in [_AnchorSide.center].
  List<_AnchorSide> get _fallbackChain {
    switch (_side) {
      case _AnchorSide.left:
        return const [
          _AnchorSide.left,
          _AnchorSide.bottom,
          _AnchorSide.top,
          _AnchorSide.center,
        ];
      case _AnchorSide.right:
        return const [
          _AnchorSide.right,
          _AnchorSide.bottom,
          _AnchorSide.top,
          _AnchorSide.center,
        ];
      case _AnchorSide.top:
        return const [
          _AnchorSide.top,
          _AnchorSide.bottom,
          _AnchorSide.center,
        ];
      case _AnchorSide.bottom:
        return const [
          _AnchorSide.bottom,
          _AnchorSide.top,
          _AnchorSide.center,
        ];
      case _AnchorSide.center:
        return const [_AnchorSide.center];
    }
  }

  /// Resolves the anchor's screen rect, or `null` for a centered popover or
  /// when the anchor is no longer laid out (caller should dismiss).
  Rect? _anchorRect() {
    final key = _anchorKey;
    if (key == null) return null;

    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;

    final topLeft = renderObject.localToGlobal(Offset.zero);
    return topLeft & renderObject.size;
  }
}

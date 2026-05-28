// packages/position_popover/lib/src/popover_position.dart

part of '../position_popover.dart';

/// Describes where a [PositionPopover] should sit.
///
/// Either anchored to a target widget (via its [GlobalKey]) on a preferred
/// side, or centered on the screen. When the preferred side cannot fit inside
/// the safe area, the popover walks an ordered fallback chain and finally
/// falls back to centering.
class PopoverPosition {
  const PopoverPosition._({
    required this._placement,
    this._anchorKey,
  });

  /// Place the popover to the left of [anchorKey].
  ///
  /// Fallback chain: left → below → above → center.
  factory PopoverPosition.left(GlobalKey anchorKey) => PopoverPosition._(
    placement: .left,
    anchorKey: anchorKey,
  );

  /// Place the popover to the right of [anchorKey].
  ///
  /// Fallback chain: right → below → above → center.
  factory PopoverPosition.right(GlobalKey anchorKey) => PopoverPosition._(
    placement: .right,
    anchorKey: anchorKey,
  );

  /// Place the popover above [anchorKey].
  ///
  /// Fallback chain: above → below → center.
  factory PopoverPosition.above(GlobalKey anchorKey) => PopoverPosition._(
    placement: .top,
    anchorKey: anchorKey,
  );

  /// Place the popover below [anchorKey].
  ///
  /// Fallback chain: below → above → center.
  factory PopoverPosition.below(GlobalKey anchorKey) => PopoverPosition._(
    placement: .bottom,
    anchorKey: anchorKey,
  );

  /// Center the popover on the screen, ignoring any anchor.
  factory PopoverPosition.center() => const PopoverPosition._(
    placement: .center,
  );

  final Placement _placement;
  final GlobalKey? _anchorKey;

  /// Ordered sides to try; the first whose rect fits inside the safe area
  /// wins. Always terminates in [Placement.center].
  List<Placement> get _fallbackChain {
    switch (_placement) {
      case .left:
        return const [.left, .bottom, .top, .center];
      case .right:
        return const [.right, .bottom, .top, .center];
      case .top:
        return const [.top, .bottom, .center];
      case .bottom:
        return const [.bottom, .top, .center];
      case .center:
        return const [.center];
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

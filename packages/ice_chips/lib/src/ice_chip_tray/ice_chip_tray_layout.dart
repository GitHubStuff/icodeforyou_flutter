// packages/ice_chips_tray/lib/src/ice_chips_tray_layout.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'package:flutter/widgets.dart';

/// Layout strategy for an [IceChipsTray].
///
/// Sealed hierarchy of layout modes — each subclass encapsulates how
/// the tray arranges its chips. New layouts are added as new sealed
/// cases; the tray itself never needs to change.
///
/// Use the const-constructible variants directly:
///
/// ```dart
/// const IceChipsTrayLayoutWrap(spacing: 8, runSpacing: 8)
/// const IceChipsTrayLayoutList()
/// ```
sealed class IceChipsTrayLayout {
  const IceChipsTrayLayout();

  /// Build the layout widget given the chip count and a builder for
  /// each chip widget by index.
  ///
  /// Implementations decide whether to materialize all chips eagerly
  /// (e.g. [Wrap]) or lazily ([ListView.builder]).
  Widget build(
    BuildContext context,
    int chipCount,
    Widget Function(int index) chipAt,
  );
}

/// Lays out chips in a [Wrap] — chips flow horizontally and wrap to
/// new rows as needed. Eager: all chips are built up front.
final class IceChipsTrayLayoutWrap extends IceChipsTrayLayout {
  const IceChipsTrayLayoutWrap({
    this.spacing = 8,
    this.runSpacing = 8,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final WrapCrossAlignment crossAxisAlignment;

  @override
  Widget build(
    BuildContext context,
    int chipCount,
    Widget Function(int index) chipAt,
  ) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: List.generate(chipCount, chipAt),
    );
  }
}

/// Lays out chips in a [ListView.builder] — chips are built lazily as
/// they scroll into view. Suitable for large or dynamically-sized
/// collections, and required for swipe-to-dismiss edit modes.
final class IceChipsTrayLayoutList extends IceChipsTrayLayout {
  const IceChipsTrayLayoutList({
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.padding,
    this.physics,
    this.itemExtent,
  });

  final Axis scrollDirection;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final double? itemExtent;

  @override
  Widget build(
    BuildContext context,
    int chipCount,
    Widget Function(int index) chipAt,
  ) {
    return ListView.builder(
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      padding: padding,
      physics: physics,
      itemExtent: itemExtent,
      itemCount: chipCount,
      itemBuilder: (context, index) => chipAt(index),
    );
  }
}

/// Lays out chips in a [Row] — single horizontal line, no wrapping.
/// Eager: all chips are built up front.
///
/// For long horizontal lists prefer
/// [IceChipsTrayLayoutList] with `scrollDirection: Axis.horizontal`.
final class IceChipsTrayLayoutRow extends IceChipsTrayLayout {
  const IceChipsTrayLayoutRow({
    this.spacing = 8,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final double spacing;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(
    BuildContext context,
    int chipCount,
    Widget Function(int index) chipAt,
  ) {
    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var i = 0; i < chipCount; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          chipAt(i),
        ],
      ],
    );
  }
}

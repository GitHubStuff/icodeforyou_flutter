// packages/ice_chips/lib/src/ice_chip_tray/ice_chip_tray_layout.dart
// ignore_for_file: comment_references

import 'package:flutter/widgets.dart';

/// {@template ice_chip_tray_layout.dart}
/// Layout strategy for an [IceChipsTray].
///
/// A sealed hierarchy of layout modes — each subclass encapsulates how
/// the tray arranges its chips, in the spirit of the Strategy pattern.
/// The tray delegates arrangement entirely to its layout via [build],
/// so new layouts are added as new sealed cases and the tray itself
/// never needs to change (Open/Closed Principle).
///
/// Because the hierarchy is `sealed`, switching over an
/// [IceChipsTrayLayout] is exhaustive: the analyzer flags any switch
/// that fails to handle a newly added layout case.
///
/// ## Choosing a layout
///
/// | Layout                      | Direction        | Chip building |
/// |-----------------------------|------------------|---------------|
/// | [IceChipsTrayLayoutWrap]    | Flows, wraps     | Eager         |
/// | [IceChipsTrayLayoutList]    | Scrolls one axis | Lazy          |
/// | [IceChipsTrayLayoutRow]     | Single line      | Eager         |
///
/// All variants are const-constructible and can be used directly:
///
/// ```dart
/// const IceChipsTrayLayoutWrap(spacing: 8, runSpacing: 8)
/// const IceChipsTrayLayoutList()
/// const IceChipsTrayLayoutRow(spacing: 4)
/// ```
/// {@endtemplate}
sealed class IceChipsTrayLayout {
  /// Const base constructor, enabling `const` construction of every
  /// sealed case so layouts can be stored in `const` widget trees.
  const IceChipsTrayLayout();

  /// Builds the widget that arranges the tray's chips.
  ///
  /// [context] is the tray's build context. [chipCount] is the total
  /// number of chips to lay out, and [chipAt] returns the fully built
  /// chip widget for a given zero-based index.
  ///
  /// Implementations decide whether to materialize all chips eagerly
  /// (e.g. [Wrap], [Row]) or lazily as they scroll into view
  /// ([ListView.builder]). Callers must not assume [chipAt] is
  /// invoked for every index — lazy layouts only request the chips
  /// they need.
  Widget build(
    BuildContext context,
    int chipCount,
    Widget Function(int index) chipAt,
  );
}

/// {@template IceChipsTrayLayoutWrap}
/// Lays out chips in a [Wrap] — chips flow horizontally and wrap to
/// new rows as needed.
///
/// Eager: all [chipCount] chips are built up front via
/// [List.generate], so this layout is best suited to small,
/// bounded collections (filter bars, tag clouds, selected-item
/// summaries). For large or unbounded collections prefer
/// [IceChipsTrayLayoutList].
///
/// ```dart
/// const IceChipsTrayLayoutWrap(
///   spacing: 4,
///   runSpacing: 12,
///   alignment: WrapAlignment.center,
/// )
/// ```
/// {@endtemplate}
final class IceChipsTrayLayoutWrap extends IceChipsTrayLayout {
  /// {@macro IceChipsTrayLayoutWrap}
  const IceChipsTrayLayoutWrap({
    this.spacing = 8,
    this.runSpacing = 8,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  /// Horizontal gap between adjacent chips within a run, in logical
  /// pixels. Forwarded to [Wrap.spacing]. Defaults to `8`.
  final double spacing;

  /// Vertical gap between runs (rows) of chips, in logical pixels.
  /// Forwarded to [Wrap.runSpacing]. Defaults to `8`.
  final double runSpacing;

  /// How chips are placed along the main axis within each run.
  /// Forwarded to [Wrap.alignment]. Defaults to [WrapAlignment.start].
  final WrapAlignment alignment;

  /// How the runs themselves are placed along the cross axis when
  /// there is extra space. Forwarded to [Wrap.runAlignment].
  /// Defaults to [WrapAlignment.start].
  final WrapAlignment runAlignment;

  /// How chips within a run are aligned relative to each other along
  /// the cross axis. Forwarded to [Wrap.crossAxisAlignment].
  /// Defaults to [WrapCrossAlignment.start].
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

/// {@template IceChipsTrayLayoutList}
/// Lays out chips in a [ListView.builder] — chips are built lazily as
/// they scroll into view.
///
/// Lazy: only visible chips (plus cache extent) are ever built,
/// making this layout suitable for large or dynamically-sized
/// collections. It is also required for swipe-to-dismiss edit modes,
/// which depend on list semantics for dismissal animations.
///
/// The list scrolls along [scrollDirection]; combine
/// `scrollDirection: Axis.horizontal` with a bounded height for a
/// single scrolling chip strip.
///
/// ```dart
/// const IceChipsTrayLayoutList(
///   scrollDirection: Axis.horizontal,
///   itemExtent: 120,
/// )
/// ```
/// {@endtemplate}
final class IceChipsTrayLayoutList extends IceChipsTrayLayout {
  /// {@macro IceChipsTrayLayoutList}
  /// Creates a lazily building list layout.
  const IceChipsTrayLayoutList({
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.padding,
    this.physics,
    this.itemExtent,
  });

  /// The axis along which the list scrolls. Forwarded to
  /// [ListView.scrollDirection]. Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the list sizes itself to its children along the scroll
  /// axis instead of expanding to fill the available space.
  /// Forwarded to [ListView.shrinkWrap]. Defaults to `false`.
  ///
  /// Enable when embedding the tray inside another scrollable or an
  /// unbounded constraint — with the usual shrink-wrap performance
  /// caveats, as it forces full layout of all children.
  final bool shrinkWrap;

  /// Padding around the scrollable content, or `null` for none
  /// (subject to [ListView]'s default `MediaQuery` padding
  /// behavior). Forwarded to [ListView.padding].
  final EdgeInsetsGeometry? padding;

  /// How the list responds to user scrolling — e.g.
  /// [NeverScrollableScrollPhysics] to disable scrolling, or
  /// [BouncingScrollPhysics] for iOS-style overscroll. Forwarded to
  /// [ListView.physics]. `null` uses the platform default.
  final ScrollPhysics? physics;

  /// Fixed extent of each chip along the scroll axis, in logical
  /// pixels, or `null` for intrinsic sizing. Forwarded to
  /// [ListView.itemExtent].
  ///
  /// Supplying a fixed extent lets the list skip per-child layout,
  /// a meaningful optimization for long uniform collections.
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

/// {@template IceChipsTrayLayoutRow}
/// Lays out chips in a [Row] — a single horizontal line, no wrapping.
///
/// Eager: all [chipCount] chips are built up front. Because a [Row]
/// neither wraps nor scrolls, chips that exceed the available width
/// will overflow; this layout is intended for small, fixed
/// collections known to fit on one line (e.g. two or three action
/// chips).
///
/// For long horizontal collections prefer [IceChipsTrayLayoutList]
/// with `scrollDirection: Axis.horizontal`; for content that should
/// flow onto additional lines prefer [IceChipsTrayLayoutWrap].
///
/// ```dart
/// const IceChipsTrayLayoutRow(
///   spacing: 4,
///   mainAxisAlignment: MainAxisAlignment.center,
/// )
/// ```
/// {@endtemplate}
final class IceChipsTrayLayoutRow extends IceChipsTrayLayout {
  /// {@macro IceChipsTrayLayoutRow}
  ///
  /// [mainAxisSize], [mainAxisAlignment], and [crossAxisAlignment]
  /// mirror their [Row] counterparts; [spacing] is realized as
  /// [SizedBox] gaps between adjacent chips.
  const IceChipsTrayLayoutRow({
    this.spacing = 8,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  /// Horizontal gap between adjacent chips, in logical pixels.
  /// Inserted as [SizedBox] spacers between chips — never before the
  /// first chip or after the last. Defaults to `8`.
  final double spacing;

  /// Whether the row occupies the full available width
  /// ([MainAxisSize.max]) or only the width its chips require
  /// ([MainAxisSize.min]). Forwarded to [Row.mainAxisSize].
  /// Defaults to [MainAxisSize.max].
  final MainAxisSize mainAxisSize;

  /// How chips are placed along the horizontal axis when there is
  /// extra space. Forwarded to [Row.mainAxisAlignment]. Defaults to
  /// [MainAxisAlignment.start].
  ///
  /// Note that space-distributing values (e.g.
  /// [MainAxisAlignment.spaceBetween]) interact with [spacing]: the
  /// [SizedBox] gaps are themselves children, so distributed space is
  /// added around chips *and* gaps alike.
  final MainAxisAlignment mainAxisAlignment;

  /// How chips are aligned vertically within the row. Forwarded to
  /// [Row.crossAxisAlignment]. Defaults to
  /// [CrossAxisAlignment.center].
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

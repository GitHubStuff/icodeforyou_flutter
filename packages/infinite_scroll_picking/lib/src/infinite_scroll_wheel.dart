// packages/infinite_scroll_picking/lib/src/infinite_scroll_wheel.dart

part of 'library.dart';

/// Internal wheel widget used by [InfiniteScrollPicker]. Not exported.
///
/// Renders a [ListWheelScrollView] with the magnification effect, the
/// selection band dividers, and the top/bottom fade gradient, all inside
/// a rounded container sized by [wheelConfig].
///
/// The wheel scrolls infinitely: the builder delegate has no child count,
/// and each virtual index is mapped onto [items] with modulo arithmetic,
/// so the list repeats endlessly in both directions.
///
/// Selection state is consumed through [selectedIndexListenable] so that
/// only the items affected by a selection change rebuild, not the entire
/// wheel.
///
/// Layering, bottom to top:
/// 1. [_SelectionDividers] — the lines bounding the centered slot.
/// 2. [_FadeGradient] — the edge fade over the container color.
/// 3. The [ListWheelScrollView] itself.
///
/// {@template infinite_scroll_wheel.type_param}
/// [T] is the type of the values rendered by the wheel.
/// {@endtemplate}
class InfiniteScrollWheel<T> extends StatelessWidget {
  /// Creates an infinite scroll wheel.
  ///
  /// [items] must not be empty. The modulo mapping from virtual index to
  /// real index divides by `items.length`, so an empty list throws on the
  /// first build.
  const InfiniteScrollWheel({
    required this.scrollController,
    required this.items,
    required this.wheelConfig,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    required this.selectedIndexListenable,
    super.key,
  });

  /// Controller driving the wheel's scroll position.
  ///
  /// Owned by the caller ([InfiniteScrollPicker]), which is responsible
  /// for its initial item and disposal. Its selected item is a virtual
  /// index; reduce it modulo `items.length` to get the real index.
  final FixedExtentScrollController scrollController;

  /// The values shown on the wheel, repeated infinitely.
  ///
  /// Must not be empty.
  final List<T> items;

  /// Visual and geometric configuration of the wheel: dimensions, item
  /// extent, perspective, magnification, border, and divider styling.
  final InfiniteScrollWheelConfig wheelConfig;

  /// Builds the widget for a single item.
  ///
  /// Receives the item value and whether it is the currently selected
  /// item. Invoked again for an item only when its selection state may
  /// have changed, not on every wheel rebuild.
  final Widget Function(T item, bool isSelected) itemBuilder;

  /// Called when the centered item changes as the wheel scrolls.
  ///
  /// Receives the virtual index reported by [ListWheelScrollView], which
  /// is unbounded. Callers must reduce it modulo `items.length` to obtain
  /// the real index into [items].
  final ValueChanged<int> onSelectedItemChanged;

  /// Source of truth for the selected real index (`0` to
  /// `items.length - 1`).
  ///
  /// Each [_WheelItem] listens to this so it can rebuild independently
  /// when it gains or loses selection.
  final ValueListenable<int> selectedIndexListenable;

  /// Builds the wheel container, dividers, fade, and scroll view.
  ///
  /// Colors are taken from the ambient [ColorScheme]:
  /// [ColorScheme.surfaceContainerHigh] for the background and fade, and
  /// [ColorScheme.primary] for the border and dividers.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(wheelConfig.wheelBorderRadius),
        border: wheelConfig.showBorder
            ? Border.all(color: colorScheme.primary)
            : null,
      ),
      child: SizedBox(
        width: wheelConfig.wheelWidth,
        height: wheelConfig.wheelHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _SelectionDividers(
              colorScheme: colorScheme,
              wheelHeight: wheelConfig.wheelHeight,
              itemExtent: wheelConfig.itemExtent,
              thickness: wheelConfig.dividerThickness,
              inset: wheelConfig.dividerInset,
            ),
            _FadeGradient(fadeColor: colorScheme.surfaceContainerHigh),
            ListWheelScrollView.useDelegate(
              controller: scrollController,
              itemExtent: wheelConfig.itemExtent,
              diameterRatio: wheelConfig.perspectiveDiameter,
              magnification: wheelConfig.magnification,
              useMagnifier: true,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onSelectedItemChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final realIndex = index % items.length;
                  return _WheelItem<T>(
                    item: items[realIndex],
                    realIndex: realIndex,
                    itemBuilder: itemBuilder,
                    selectedIndexListenable: selectedIndexListenable,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single item slot in the wheel.
///
/// Subscribes to [selectedIndexListenable] via [ValueListenableBuilder] so
/// only the previously-selected and newly-selected items rebuild on
/// change, rather than the entire wheel.
///
/// Because the wheel repeats [item] at every virtual index that maps to
/// the same [realIndex], every visible copy of the selected value is
/// rendered as selected.
class _WheelItem<T> extends StatelessWidget {
  /// Creates a wheel item slot for [item] at [realIndex].
  const _WheelItem({
    required this.item,
    required this.realIndex,
    required this.itemBuilder,
    required this.selectedIndexListenable,
  });

  /// The value rendered in this slot.
  final T item;

  /// Index of [item] within the source list, in the range `0` to
  /// `items.length - 1`. Compared against [selectedIndexListenable] to
  /// determine selection.
  final int realIndex;

  /// Builds the visual for [item]; see [InfiniteScrollWheel.itemBuilder].
  final Widget Function(T item, bool isSelected) itemBuilder;

  /// The selected real index; see
  /// [InfiniteScrollWheel.selectedIndexListenable].
  final ValueListenable<int> selectedIndexListenable;

  /// Centers the built item and rebuilds it when selection changes.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<int>(
        valueListenable: selectedIndexListenable,
        builder: (context, selectedIndex, _) {
          return itemBuilder(item, realIndex == selectedIndex);
        },
      ),
    );
  }
}

/// Two horizontal lines marking the selection band, drawn above and below
/// the centered slot.
///
/// The lines sit just outside the band: the top line ends at the band's
/// upper edge and the bottom line starts at its lower edge, so neither
/// overlaps the selected item's [itemExtent].
class _SelectionDividers extends StatelessWidget {
  /// Creates the selection band dividers.
  const _SelectionDividers({
    required this.colorScheme,
    required this.wheelHeight,
    required this.itemExtent,
    required this.thickness,
    required this.inset,
  });

  /// Scheme supplying the line color ([ColorScheme.primary]).
  final ColorScheme colorScheme;

  /// Total height of the wheel, used to locate its vertical center.
  final double wheelHeight;

  /// Height of one item slot; the band spans this height around center.
  final double itemExtent;

  /// Stroke thickness of each line, in logical pixels.
  final double thickness;

  /// Horizontal inset of each line from the left and right edges, in
  /// logical pixels.
  final double inset;

  /// Positions the two lines around the vertical center of the wheel.
  @override
  Widget build(BuildContext context) {
    final centerY = wheelHeight / 2;
    final halfExtent = itemExtent / 2;
    final lineColor = colorScheme.primary;

    return Stack(
      children: [
        Positioned(
          top: centerY - halfExtent - thickness,
          left: inset,
          right: inset,
          child: Container(height: thickness, color: lineColor),
        ),
        Positioned(
          top: centerY + halfExtent,
          left: inset,
          right: inset,
          child: Container(height: thickness, color: lineColor),
        ),
      ],
    );
  }
}

/// Top and bottom fade applied over the wheel so items at the edges blend
/// into the surrounding container color.
///
/// The gradient is opaque [fadeColor] at the edges, fully transparent
/// across the middle half (25% to 75% of the height), and wrapped in
/// [IgnorePointer] so it never intercepts scroll gestures.
class _FadeGradient extends StatelessWidget {
  /// Creates an edge fade in [fadeColor].
  const _FadeGradient({required this.fadeColor});

  /// Color faded to at the top and bottom edges. Should match the wheel
  /// container's background for a seamless blend.
  final Color fadeColor;

  /// Fills the parent [Stack] with the non-interactive fade gradient.
  @override
  Widget build(BuildContext context) {
    final transparent = fadeColor.withValues(alpha: 0);
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [fadeColor, transparent, transparent, fadeColor],
              stops: const [0.0, 0.25, 0.75, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

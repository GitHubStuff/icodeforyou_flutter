// lib/src/_infinite_scroll_wheel.dart

// ignore: lines_longer_than_80_chars
// ignore_for_file: document_ignores, avoid_positional_boolean_parameters, public_member_api_docs

part of 'library.dart';

/// Internal wheel widget used by [InfiniteScrollPicker]. Not exported.
///
/// Renders the [ListWheelScrollView] with the magnification effect, the
/// selection band dividers, and the top/bottom fade gradient. Consumes a
/// [ValueListenable] for the selected index so only the items affected by
/// a selection change rebuild — not the entire wheel.
class InfiniteScrollWheel<T> extends StatelessWidget {
  const InfiniteScrollWheel({
    required this.scrollController,
    required this.items,
    required this.wheelConfig,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    required this.selectedIndexListenable,
    super.key,
  });

  final FixedExtentScrollController scrollController;
  final List<T> items;
  final InfiniteScrollWheelConfig wheelConfig;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final ValueChanged<int> onSelectedItemChanged;
  final ValueListenable<int> selectedIndexListenable;

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
/// only the previously-selected and newly-selected items rebuild on change,
/// rather than the entire wheel.
class _WheelItem<T> extends StatelessWidget {
  const _WheelItem({
    required this.item,
    required this.realIndex,
    required this.itemBuilder,
    required this.selectedIndexListenable,
  });

  final T item;
  final int realIndex;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final ValueListenable<int> selectedIndexListenable;

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
class _SelectionDividers extends StatelessWidget {
  const _SelectionDividers({
    required this.colorScheme,
    required this.wheelHeight,
    required this.itemExtent,
    required this.thickness,
    required this.inset,
  });

  final ColorScheme colorScheme;
  final double wheelHeight;
  final double itemExtent;
  final double thickness;
  final double inset;

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
class _FadeGradient extends StatelessWidget {
  const _FadeGradient({required this.fadeColor});

  final Color fadeColor;

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

// packages/color_grid/lib/color_grid.dart
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';

/// Signature for taps on a color cell, delivering the tapped [index]
/// (0–14) and its ARGB [colorValue].
typedef ColorGridColorTap = void Function(int index, int colorValue);

const double _kCellSize = 70;
const double _kBorderWidth = 2;
const double _kGapWide = 8;
const double _kGapNarrow = 4;
const int _kGridDimension = 4;
const int _kColorCount = 15;

const Color _kBorderColorLight = Color(0xFF6A1B9A);
const Color _kBorderColorDark = Color(0xFFCE93D8);

/// A 4×4 grid of tappable color cells with a refresh action.
///
/// Renders exactly [_kColorCount] ARGB color values in the first
/// fifteen cells; the sixteenth cell is a refresh button that fires
/// [onRefreshRequested]. Tapping a color cell fires [onColorTapped]
/// with the cell's index and color value.
///
/// The grid is purely presentational: it holds no state and never
/// mutates or fetches colors itself. Cells are fixed at
/// [_kCellSize] logical pixels, spaced evenly — including the inset
/// from the surrounding [_kBorderWidth] border — at [_kGapWide],
/// dropping to [_kGapNarrow] when the parent is too narrow.
class ColorGrid extends StatelessWidget {
  /// Creates a grid picker.
  ///
  /// [colors] must contain exactly fifteen ARGB values.
  const ColorGrid({
    required this.colors,
    required this.onColorTapped,
    required this.onRefreshRequested,
    this.haptics = HapticIntensity.light,
    super.key,
  }) : assert(
         colors.length == _kColorCount,
         'ColorGrid requires exactly $_kColorCount colors, '
         'got ${colors.length}',
       );

  /// The fifteen ARGB color values to display, in grid order.
  final List<int> colors;

  /// Called with the index (0–14) and ARGB value of a tapped color.
  final ColorGridColorTap onColorTapped;

  /// Called when the refresh cell is tapped.
  final VoidCallback onRefreshRequested;

  /// The haptic feedback fired on every cell tap, including refresh.
  final HapticIntensity haptics;

  /// The minimum width at which [_kGapWide] spacing fits: four cells,
  /// three internal gaps, two inset gaps, and the border on both sides.
  static const double _kWideModeMinWidth =
      _kGridDimension * _kCellSize +
      (_kGridDimension + 1) * _kGapWide +
      2 * _kBorderWidth;

  Color _borderColor(BuildContext context) =>
      switch (Theme.of(context).brightness) {
        Brightness.light => _kBorderColorLight,
        Brightness.dark => _kBorderColorDark,
      };

  Widget _colorCell(int index) => GestureDetector(
    onTap: () {
      haptics.trigger();
      onColorTapped(index, colors[index]);
    },
    child: SizedBox(
      width: _kCellSize,
      height: _kCellSize,
      child: ColoredBox(color: Color(colors[index])),
    ),
  );

  Widget _refreshCell(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: haptics.wrap(onRefreshRequested),
    child: SizedBox(
      width: _kCellSize,
      height: _kCellSize,
      child: Icon(
        Icons.refresh,
        size: _kCellSize / 2,
        color: _borderColor(context),
      ),
    ),
  );

  Widget _cell(BuildContext context, int index) =>
      index < _kColorCount ? _colorCell(index) : _refreshCell(context);

  Widget _row(BuildContext context, int rowIndex, double gap) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: gap,
    children: [
      for (var column = 0; column < _kGridDimension; column++)
        _cell(context, rowIndex * _kGridDimension + column),
    ],
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gap = constraints.maxWidth >= _kWideModeMinWidth
          ? _kGapWide
          : _kGapNarrow;

      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: _borderColor(context),
            width: _kBorderWidth,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(gap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: gap,
            children: [
              for (var row = 0; row < _kGridDimension; row++)
                _row(context, row, gap),
            ],
          ),
        ),
      );
    },
  );
}

// packages/datetime_pickers/lib/src/picker_size.dart
import 'package:flutter/widgets.dart';

/// Size presets for the pickers. Each preset fully determines the wheel
/// typography and geometry so callers never have to keep font size, row
/// height and box dimensions in sync by hand.
///
/// Presets form a single ascending scale. Within the scale `itemExtent` is
/// `1.5 × fontSize` (rounded to an even number) and `groupSpacing` is
/// `2 × columnPadding`.
enum PickerSize {
  /// 18 px labels. Dense popovers and menu-bar surfaces.
  extraSmall(
    fontSize: 18,
    itemExtent: 28,
    visibleRows: 4,
    columnPadding: 5,
    groupSpacing: 10,
  ),

  /// 22 px labels. Small popovers.
  small(
    fontSize: 22,
    itemExtent: 34,
    visibleRows: 4,
    columnPadding: 6,
    groupSpacing: 12,
  ),

  /// 24 px labels. The default.
  medium(
    fontSize: 24,
    itemExtent: 36,
    visibleRows: 4,
    columnPadding: 7,
    groupSpacing: 14,
  ),

  /// 28 px labels. Bottom sheets.
  large(
    fontSize: 28,
    itemExtent: 42,
    visibleRows: 4,
    columnPadding: 8,
    groupSpacing: 16,
  ),

  /// 32 px labels. Tablets and large phones.
  extraLarge(
    fontSize: 32,
    itemExtent: 48,
    visibleRows: 4,
    columnPadding: 10,
    groupSpacing: 20,
  ),

  /// 40 px labels. Tablets in landscape, kiosks and TV.
  huge(
    fontSize: 40,
    itemExtent: 60,
    visibleRows: 4,
    columnPadding: 12,
    groupSpacing: 24,
  );

  const PickerSize({
    required this.fontSize,
    required this.itemExtent,
    required this.visibleRows,
    required this.columnPadding,
    required this.groupSpacing,
  });

  /// Font size of every wheel label, in logical pixels.
  final double fontSize;

  /// Height of one wheel row; must comfortably exceed [fontSize].
  final double itemExtent;

  /// Number of rows visible in the wheel; sets the picker height.
  final int visibleRows;

  /// Horizontal padding on each side of a column's widest label.
  final double columnPadding;

  /// Horizontal gap between the date group and the time group.
  final double groupSpacing;

  /// Total picker height.
  double get height => itemExtent * visibleRows;

  /// Column width for a label measured at [labelWidth].
  double columnWidthFor(double labelWidth) => labelWidth + columnPadding * 2;

  /// Label style, merged over the ambient style by the picker.
  TextStyle get textStyle => TextStyle(fontSize: fontSize);
}

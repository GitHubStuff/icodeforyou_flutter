// packages/datetime_popover_pickers/lib/src/picker_size.dart
import 'package:flutter/widgets.dart';

/// Size presets for the pickers. Each preset fully determines the wheel
/// typography and geometry so callers never have to keep font size, row
/// height and box dimensions in sync by hand.
enum PickerSize {
  /// 22 sp labels.
  compact(fontSize: 22, itemExtent: 34, visibleRows: 5, columnWidth: 60),

  /// 24 sp labels.
  regular(fontSize: 24, itemExtent: 36, visibleRows: 5, columnWidth: 66),

  /// 28 sp labels.
  large(fontSize: 28, itemExtent: 42, visibleRows: 5, columnWidth: 76),

  /// 32 sp labels.
  expanded(fontSize: 32, itemExtent: 48, visibleRows: 5, columnWidth: 88);

  const PickerSize({
    required this.fontSize,
    required this.itemExtent,
    required this.visibleRows,
    required this.columnWidth,
  });

  /// Font size of every wheel label, in logical pixels.
  final double fontSize;

  /// Height of one wheel row; must comfortably exceed [fontSize].
  final double itemExtent;

  /// Number of rows visible in the wheel; sets the picker height.
  final int visibleRows;

  /// Width of one wheel column; sized to fit the widest label (`AM`/`59`).
  final double columnWidth;

  /// Total picker height.
  double get height => itemExtent * visibleRows;

  /// Total picker width for [columnCount] wheels.
  double widthFor(int columnCount) => columnWidth * columnCount;

  /// Label style, merged over the ambient style by the picker.
  TextStyle get textStyle => TextStyle(fontSize: fontSize);
}

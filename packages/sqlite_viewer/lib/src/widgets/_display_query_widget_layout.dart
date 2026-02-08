// packages/sqlite_viewer/lib/src/widgets/_display_query_widget_layout.dart
part of 'display_query_widget.dart';

// =============================================================================
// Layout Calculations
// =============================================================================

extension _LayoutCalculations on _DisplayQueryWidgetState {
  void _calculateLayout() {
    _displayColumns = _buildDisplayColumns();
    _columnWidths = _computeColumnWidths();
  }

  List<String> _buildDisplayColumns() {
    if (widget.showRowNumbers) {
      return ['#', ...widget.columns];
    }
    return List.from(widget.columns);
  }

  List<double> _computeColumnWidths() {
    final widths = <double>[];
    final headerTextStyle = _effectiveHeaderStyle;
    final dataTextStyle = widget.evenRowStyle;

    for (var colIndex = 0; colIndex < _displayColumns.length; colIndex++) {
      double maxWidth = _measureTextWidth(
        _displayColumns[colIndex],
        headerTextStyle,
      );

      for (final row in widget.rows) {
        final cellValue = _getCellValue(row, colIndex);
        final cellWidth = _measureTextWidth(cellValue, dataTextStyle);
        if (cellWidth > maxWidth) {
          maxWidth = cellWidth;
        }
      }

      final paddedWidth =
          maxWidth + widget.cellPadding.left + widget.cellPadding.right;

      widths.add(
        paddedWidth.clamp(widget.minColumnWidth, widget.maxColumnWidth),
      );
    }

    return widths;
  }

  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }

  String _getCellValue(Map<String, Object?> row, int colIndex) {
    if (widget.showRowNumbers && colIndex == 0) {
      final rowIndex = widget.rows.indexOf(row);
      return '${rowIndex + 1}';
    }

    final actualColIndex = widget.showRowNumbers ? colIndex - 1 : colIndex;

    if (actualColIndex < 0 || actualColIndex >= widget.columns.length) {
      return '';
    }

    final columnName = widget.columns[actualColIndex];
    final value = row[columnName];

    if (value == null) {
      return widget.nullValueDisplay;
    }

    return value.toString();
  }

  TextStyle get _effectiveHeaderStyle {
    return widget.headerStyle ??
        widget.evenRowStyle.copyWith(fontWeight: FontWeight.bold);
  }

  Color get _effectiveBorderColor {
    return widget.borderColor ?? Colors.grey.shade300;
  }

  double get _totalTableWidth {
    return _columnWidths.fold(0, (double sum, double width) => sum + width);
  }

  bool _isNullValue(Map<String, Object?> row, int colIndex) {
    if (widget.showRowNumbers && colIndex == 0) {
      return false;
    }

    final actualColIndex = widget.showRowNumbers ? colIndex - 1 : colIndex;

    if (actualColIndex < 0 || actualColIndex >= widget.columns.length) {
      return false;
    }

    final columnName = widget.columns[actualColIndex];
    return row[columnName] == null;
  }
}

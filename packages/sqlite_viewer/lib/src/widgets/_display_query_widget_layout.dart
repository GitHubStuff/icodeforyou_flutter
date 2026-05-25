// packages/sqlite_viewer/lib/src/widgets/_display_query_widget_layout.dart
// ignore_for_file: avoid_types_on_closure_parameters

part of 'display_query_widget.dart';

// =============================================================================
// Layout Calculations
// =============================================================================

extension _LayoutCalculations on _DisplayQueryWidgetState {
  /// Recomputes display columns and column widths for the given viewport.
  ///
  /// Column widths are produced in two passes:
  ///
  /// 1. **Content fit** — every cell's rendered glyph width is measured
  ///    (merged style, ambient text scaler, ambient text direction), and
  ///    each column is sized to its widest cell plus horizontal padding,
  ///    clamped to `[minColumnWidth, maxColumnWidth]`.
  ///
  /// 2. **Viewport stretch** — if the summed content-fit widths are
  ///    narrower than [viewportWidth], the slack is distributed across
  ///    columns proportionally to their content-fit widths, capped by
  ///    `maxColumnWidth`. The table fills the pane instead of hugging
  ///    the left. If content-fit widths already exceed the viewport,
  ///    no stretch is applied — horizontal scrolling takes over.
  void _calculateLayout(double viewportWidth) {
    _displayColumns = _buildDisplayColumns();

    final contentWidths = _computeContentFitWidths();
    _columnWidths = _stretchToViewport(contentWidths, viewportWidth);
  }

  List<String> _buildDisplayColumns() {
    if (widget.showRowNumbers) {
      return ['#', ...widget.columns];
    }
    return List.from(widget.columns);
  }

  List<double> _computeContentFitWidths() {
    final widths = <double>[];
    final headerTextStyle = _measurementStyle(_effectiveHeaderStyle);
    final dataTextStyle = _measurementStyle(widget.evenRowStyle);
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);

    for (var colIndex = 0; colIndex < _displayColumns.length; colIndex++) {
      double maxWidth = _measureTextWidth(
        _displayColumns[colIndex],
        headerTextStyle,
        textScaler,
        textDirection,
      );

      for (final row in widget.rows) {
        final cellValue = _getCellValue(row, colIndex);
        final cellWidth = _measureTextWidth(
          cellValue,
          dataTextStyle,
          textScaler,
          textDirection,
        );
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

  /// Distributes any slack between the summed content-fit widths and
  /// [viewportWidth] across columns proportionally to their content
  /// widths, capped per-column by `maxColumnWidth`.
  ///
  /// If [viewportWidth] is non-positive, not finite, or already
  /// exceeded by content, the content-fit widths are returned
  /// unchanged. The stretch runs iteratively because a column hitting
  /// its `maxColumnWidth` cap releases its remaining share back to
  /// the still-stretchable columns; the loop terminates when either
  /// all slack is absorbed or no column can grow further.
  List<double> _stretchToViewport(
    List<double> contentWidths,
    double viewportWidth,
  ) {
    if (contentWidths.isEmpty) return contentWidths;
    if (!viewportWidth.isFinite || viewportWidth <= 0) return contentWidths;

    final widths = List<double>.from(contentWidths);
    var total = widths.fold<double>(0, (sum, w) => sum + w);
    var slack = viewportWidth - total;

    if (slack <= 0) return widths;

    final maxWidth = widget.maxColumnWidth;

    // Track which columns can still grow. A column is "growable"
    // while its current width is strictly less than maxWidth.
    final growable = <int>{
      for (var i = 0; i < widths.length; i++)
        if (widths[i] < maxWidth) i,
    };

    // Loop guard: at most one iteration per column, since each
    // iteration either absorbs all remaining slack or removes at
    // least one column from the growable set.
    for (var iter = 0; iter < widths.length && growable.isNotEmpty; iter++) {
      final basis = growable.fold<double>(0, (sum, i) => sum + widths[i]);
      if (basis <= 0) break;

      var consumed = 0.0;
      final saturated = <int>[];

      for (final i in growable) {
        final share = slack * (widths[i] / basis);
        final headroom = maxWidth - widths[i];
        if (share >= headroom) {
          widths[i] = maxWidth;
          consumed += headroom;
          saturated.add(i);
        } else {
          widths[i] += share;
          consumed += share;
        }
      }

      growable.removeAll(saturated);
      slack -= consumed;

      if (slack <= 0.5) break; // sub-pixel residue; stop
    }

    return widths;
  }

  /// Resolves the style the `Text` widget will actually render with.
  ///
  /// `Text` merges its provided [TextStyle] against the ambient
  /// [DefaultTextStyle], inheriting fontFamily, fontSize and other
  /// properties from the theme. Measuring against the bare provided
  /// style misses that merge — widths come back narrower than the
  /// rendered glyphs, and cells truncate inside their allotted box.
  TextStyle _measurementStyle(TextStyle style) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    return defaultStyle.merge(style);
  }

  /// Measures one line of text using the same parameters `Text` uses to
  /// lay itself out: the merged style, the ambient text scaler, the
  /// ambient text direction. Adds a sub-pixel epsilon to absorb the
  /// rounding `Text` applies before painting.
  double _measureTextWidth(
    String text,
    TextStyle style,
    TextScaler textScaler,
    TextDirection textDirection,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout();

    return textPainter.width.ceilToDouble();
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

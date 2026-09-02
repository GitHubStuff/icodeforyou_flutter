// packages/sqlite_viewer/lib/src/widgets/display_query_widget/display_query_widget_cells.dart

part of 'display_query_widget.dart';

// =============================================================================
// Header and Cell Builders
// =============================================================================

/// Provides widget building methods for the header, body, rows, and
/// cells of the `DisplayQueryWidget`.
extension CellBuilders on DisplayQueryWidgetState {
  /// Builds the scrollable header row of the table.
  ///
  /// The header contains the column names and is synchronized horizontally
  /// with the table body via `_horizontalHeaderController`.
  Widget buildHeader() {
    return Container(
      height: widget.headerHeight,
      decoration: BoxDecoration(
        color: widget.headerBackgroundColor,
        border: Border(
          top: BorderSide(color: effectiveBorderColor),
          bottom: BorderSide(color: effectiveBorderColor, width: 2),
        ),
      ),
      child: SingleChildScrollView(
        controller: _horizontalHeaderController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: List.generate(
            _displayColumns.length,
            buildHeaderCell,
          ),
        ),
      ),
    );
  }

  /// Builds an individual cell for the table header at the given [colIndex].
  ///
  /// Applies border styling and truncates text if it exceeds the calculated
  /// column width.
  Widget buildHeaderCell(int colIndex) {
    final isFirst = colIndex == 0;

    return Container(
      width: _columnWidths[colIndex],
      height: widget.headerHeight,
      padding: widget.cellPadding,
      decoration: BoxDecoration(
        border: Border(
          left: isFirst
              ? BorderSide(color: effectiveBorderColor)
              : BorderSide.none,
          right: BorderSide(color: effectiveBorderColor),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        _displayColumns[colIndex],
        style: effectiveHeaderStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Builds the scrollable body of the table containing the data rows.
  ///
  /// Supports both vertical scrolling via `_verticalController` and
  /// horizontal scrolling via `_horizontalBodyController`.
  Widget buildBody() {
    return SingleChildScrollView(
      controller: _verticalController,
      physics: const ClampingScrollPhysics(),
      child: SingleChildScrollView(
        controller: _horizontalBodyController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: totalTableWidth,
          child: Column(
            children: List.generate(
              widget.rows.length,
              buildRow,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a single data row for the table at the given [rowIndex].
  ///
  /// Applies alternating row colors and styles based on whether the index
  /// is even or odd.
  Widget buildRow(int rowIndex) {
    final isEven = rowIndex.isEven;
    final rowStyle = isEven ? widget.evenRowStyle : widget.oddRowStyle;
    final rowColor = isEven ? widget.evenRowColor : widget.oddRowColor;

    return Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(
          bottom: BorderSide(color: effectiveBorderColor),
        ),
      ),
      child: Row(
        children: List.generate(_displayColumns.length, (colIndex) {
          return buildDataCell(rowIndex, colIndex, rowStyle);
        }),
      ),
    );
  }

  /// Builds an individual data cell located at [rowIndex] and [colIndex].
  ///
  /// The [style] is applied to the text. If the cell contains a null
  /// value, it renders with an italicized, grey appearance. Text wrapping
  /// or truncation is determined by the widget's `textHandling` config.
  Widget buildDataCell(int rowIndex, int colIndex, TextStyle style) {
    final row = widget.rows[rowIndex];
    final cellValue = getCellValue(row, colIndex);
    final isNullValue = isNullValueRowTest(row, colIndex);
    final isFirst = colIndex == 0;

    final effectiveStyle = isNullValue
        ? style.copyWith(fontStyle: FontStyle.italic, color: Colors.grey)
        : style;

    return Container(
      width: _columnWidths[colIndex],
      height: widget.rowHeight,
      padding: widget.cellPadding,
      decoration: BoxDecoration(
        border: Border(
          left: isFirst
              ? BorderSide(color: effectiveBorderColor)
              : BorderSide.none,
          right: BorderSide(color: effectiveBorderColor),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: widget.textHandling == TextHandling.trunc
          ? Text(
              cellValue,
              style: effectiveStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              cellValue,
              style: effectiveStyle,
              softWrap: true,
            ),
    );
  }
}

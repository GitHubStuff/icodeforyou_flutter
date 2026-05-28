// packages/sqlite_viewer/lib/src/widgets/_display_query_widget_cells.dart

part of 'display_query_widget.dart';

// =============================================================================
// Header and Cell Builders
// =============================================================================

extension CellBuilders on DisplayQueryWidgetState {
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

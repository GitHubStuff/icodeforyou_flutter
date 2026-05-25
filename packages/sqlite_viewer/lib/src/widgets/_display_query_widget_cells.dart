// packages/sqlite_viewer/lib/src/widgets/_display_query_widget_cells.dart

part of 'display_query_widget.dart';

// =============================================================================
// Header and Cell Builders
// =============================================================================

extension _CellBuilders on _DisplayQueryWidgetState {
  Widget _buildHeader() {
    return Container(
      height: widget.headerHeight,
      decoration: BoxDecoration(
        color: widget.headerBackgroundColor,
        border: Border(
          top: BorderSide(color: _effectiveBorderColor),
          bottom: BorderSide(color: _effectiveBorderColor, width: 2),
        ),
      ),
      child: SingleChildScrollView(
        controller: _horizontalHeaderController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: List.generate(
            _displayColumns.length,
            _buildHeaderCell,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(int colIndex) {
    final isFirst = colIndex == 0;

    return Container(
      width: _columnWidths[colIndex],
      height: widget.headerHeight,
      padding: widget.cellPadding,
      decoration: BoxDecoration(
        border: Border(
          left: isFirst
              ? BorderSide(color: _effectiveBorderColor)
              : BorderSide.none,
          right: BorderSide(color: _effectiveBorderColor),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        _displayColumns[colIndex],
        style: _effectiveHeaderStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _verticalController,
      physics: const ClampingScrollPhysics(),
      child: SingleChildScrollView(
        controller: _horizontalBodyController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: _totalTableWidth,
          child: Column(
            children: List.generate(
              widget.rows.length,
              _buildRow,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int rowIndex) {
    final isEven = rowIndex.isEven;
    final rowStyle = isEven ? widget.evenRowStyle : widget.oddRowStyle;
    final rowColor = isEven ? widget.evenRowColor : widget.oddRowColor;

    return Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(
          bottom: BorderSide(color: _effectiveBorderColor),
        ),
      ),
      child: Row(
        children: List.generate(_displayColumns.length, (colIndex) {
          return _buildDataCell(rowIndex, colIndex, rowStyle);
        }),
      ),
    );
  }

  Widget _buildDataCell(int rowIndex, int colIndex, TextStyle style) {
    final row = widget.rows[rowIndex];
    final cellValue = _getCellValue(row, colIndex);
    final isNullValue = _isNullValue(row, colIndex);
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
              ? BorderSide(color: _effectiveBorderColor)
              : BorderSide.none,
          right: BorderSide(color: _effectiveBorderColor),
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

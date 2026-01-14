// packages/sqlite_table_viewer/lib/src/widgets/display_query_widget.dart

import 'package:flutter/material.dart';

import '../models/text_handling.dart';

/// A spreadsheet-style widget for displaying SQLite query results.
///
/// Features:
/// - Frozen header row (visible during vertical scroll)
/// - Horizontal scrolling for wide tables
/// - Vertical scrolling for long result sets
/// - Alternating row styles
/// - Auto-sized column widths based on content
class DisplayQueryWidget extends StatefulWidget {
  /// Column names from table metadata.
  final List<String> columns;

  /// Query result rows as list of maps.
  final List<Map<String, Object?>> rows;

  /// Text style applied to even-indexed rows (0, 2, 4...).
  final TextStyle evenRowStyle;

  /// Text style applied to odd-indexed rows (1, 3, 5...).
  final TextStyle oddRowStyle;

  /// Text style for column headers.
  final TextStyle? headerStyle;

  /// Background color for even-indexed rows.
  final Color? evenRowColor;

  /// Background color for odd-indexed rows.
  final Color? oddRowColor;

  /// Background color for the header row.
  final Color? headerBackgroundColor;

  /// Padding inside each cell.
  final EdgeInsets cellPadding;

  /// Display string for null values.
  final String nullValueDisplay;

  /// How to handle text that exceeds column width.
  final TextHandling textHandling;

  /// Whether to show row numbers as first column.
  final bool showRowNumbers;

  /// Widget displayed when [rows] is empty.
  final Widget? emptyWidget;

  /// Minimum width for any column.
  final double minColumnWidth;

  /// Maximum width for any column.
  final double maxColumnWidth;

  /// Border color for cell dividers.
  final Color? borderColor;

  /// Height of the header row.
  final double headerHeight;

  /// Height of each data row.
  final double rowHeight;

  const DisplayQueryWidget({
    super.key,
    required this.columns,
    required this.rows,
    required this.evenRowStyle,
    required this.oddRowStyle,
    this.headerStyle,
    this.evenRowColor,
    this.oddRowColor,
    this.headerBackgroundColor,
    this.cellPadding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 8.0,
    ),
    this.nullValueDisplay = 'NULL',
    this.textHandling = TextHandling.trunc,
    this.showRowNumbers = false,
    this.emptyWidget,
    this.minColumnWidth = 60.0,
    this.maxColumnWidth = 300.0,
    this.borderColor,
    this.headerHeight = 48.0,
    this.rowHeight = 44.0,
  });

  @override
  State<DisplayQueryWidget> createState() => _DisplayQueryWidgetState();
}

class _DisplayQueryWidgetState extends State<DisplayQueryWidget> {
  final ScrollController _horizontalHeaderController = ScrollController();
  final ScrollController _horizontalBodyController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  List<double> _columnWidths = [];
  List<String> _displayColumns = [];

  @override
  void initState() {
    super.initState();
    _syncHorizontalScroll();
    _calculateLayout();
  }

  @override
  void didUpdateWidget(DisplayQueryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final columnsChanged = !_listEquals(oldWidget.columns, widget.columns);
    final rowsChanged = oldWidget.rows.length != widget.rows.length;
    final showRowNumbersChanged =
        oldWidget.showRowNumbers != widget.showRowNumbers;

    if (columnsChanged || rowsChanged || showRowNumbersChanged) {
      _calculateLayout();
    }
  }

  @override
  void dispose() {
    _horizontalHeaderController.dispose();
    _horizontalBodyController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void _syncHorizontalScroll() {
    _horizontalHeaderController.addListener(() {
      if (_horizontalBodyController.hasClients &&
          _horizontalBodyController.offset !=
              _horizontalHeaderController.offset) {
        _horizontalBodyController.jumpTo(_horizontalHeaderController.offset);
      }
    });

    _horizontalBodyController.addListener(() {
      if (_horizontalHeaderController.hasClients &&
          _horizontalHeaderController.offset !=
              _horizontalBodyController.offset) {
        _horizontalHeaderController.jumpTo(_horizontalBodyController.offset);
      }
    });
  }

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
    return _columnWidths.fold(0.0, (sum, width) => sum + width);
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.columns.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    if (widget.rows.isEmpty) {
      return widget.emptyWidget ??
          const Center(child: Text('No data available'));
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: widget.headerHeight,
      decoration: BoxDecoration(
        color: widget.headerBackgroundColor,
        border: Border(
          bottom: BorderSide(color: _effectiveBorderColor, width: 2.0),
        ),
      ),
      child: SingleChildScrollView(
        controller: _horizontalHeaderController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: List.generate(_displayColumns.length, (index) {
            return _buildHeaderCell(index);
          }),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(int colIndex) {
    return Container(
      width: _columnWidths[colIndex],
      height: widget.headerHeight,
      padding: widget.cellPadding,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: _effectiveBorderColor)),
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
            children: List.generate(widget.rows.length, (rowIndex) {
              return _buildRow(rowIndex);
            }),
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
        border: Border(bottom: BorderSide(color: _effectiveBorderColor)),
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

    final effectiveStyle = isNullValue
        ? style.copyWith(fontStyle: FontStyle.italic, color: Colors.grey)
        : style;

    return Container(
      width: _columnWidths[colIndex],
      height: widget.rowHeight,
      padding: widget.cellPadding,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: _effectiveBorderColor)),
      ),
      alignment: Alignment.centerLeft,
      child: widget.textHandling == TextHandling.trunc
          ? Text(
              cellValue,
              style: effectiveStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(cellValue, style: effectiveStyle, softWrap: true),
    );
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

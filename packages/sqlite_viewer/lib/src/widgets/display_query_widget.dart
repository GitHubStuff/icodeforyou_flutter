// packages/sqlite_viewer/lib/src/widgets/display_query_widget.dart

import 'package:flutter/material.dart';

import 'package:sqlite_viewer/src/models/text_handling.dart';

part '_display_query_widget_layout.dart';
part '_display_query_widget_cells.dart';

/// A spreadsheet-style widget for displaying SQLite query results.
///
/// Features:
/// - Frozen header row (visible during vertical scroll)
/// - Horizontal scrolling for wide tables
/// - Vertical scrolling for long result sets
/// - Alternating row styles
/// - Auto-sized column widths based on content
/// - Columns stretch to fill the viewport when content is narrow,
///   so the table never hugs the left with empty space to the right
class DisplayQueryWidget extends StatefulWidget {
  /// Creates a [DisplayQueryWidget] with the given columns and rows.
  const DisplayQueryWidget({
    required this.columns,
    required this.rows,
    required this.evenRowStyle,
    required this.oddRowStyle,
    super.key,
    this.headerStyle,
    this.evenRowColor,
    this.oddRowColor,
    this.headerBackgroundColor,
    this.cellPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
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

  @override
  State<DisplayQueryWidget> createState() => _DisplayQueryWidgetState();
}

class _DisplayQueryWidgetState extends State<DisplayQueryWidget> {
  final ScrollController _horizontalHeaderController = ScrollController();
  final ScrollController _horizontalBodyController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  List<double> _columnWidths = [];
  List<String> _displayColumns = [];

  /// Viewport width used by the most recent layout pass. Tracked so we
  /// only recompute column widths when the available width actually
  /// changes — not on every parent rebuild.
  double _lastViewportWidth = double.nan;

  @override
  void initState() {
    super.initState();
    _syncHorizontalScroll();
  }

  /// Invalidates cached column widths whenever inherited dependencies
  /// change (text scaler, default text style, directionality). The
  /// next `LayoutBuilder` pass will then recompute against the new
  /// inherited state.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastViewportWidth = double.nan;
  }

  @override
  void didUpdateWidget(DisplayQueryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final columnsChanged = !_listEquals(oldWidget.columns, widget.columns);
    final rowsChanged = oldWidget.rows.length != widget.rows.length;
    final showRowNumbersChanged =
        oldWidget.showRowNumbers != widget.showRowNumbers;

    if (columnsChanged || rowsChanged || showRowNumbersChanged) {
      // Force the next build's LayoutBuilder pass to recompute by
      // invalidating the cached viewport width.
      _lastViewportWidth = double.nan;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;

        if (viewportWidth != _lastViewportWidth || _columnWidths.isEmpty) {
          _calculateLayout(viewportWidth);
          _lastViewportWidth = viewportWidth;
        }

        return Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        );
      },
    );
  }
}

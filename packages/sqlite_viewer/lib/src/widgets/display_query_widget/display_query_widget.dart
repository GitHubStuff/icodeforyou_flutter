// packages/sqlite_viewer/lib/src/widgets/display_query_widget/display_query_widget.dart

import 'package:flutter/material.dart';

import 'package:sqlite_viewer/src/models/text_handling.dart';

part 'display_query_widget_layout.dart';
part 'display_query_widget_cells.dart';

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
  State<DisplayQueryWidget> createState() => DisplayQueryWidgetState();
}

/// State for [DisplayQueryWidget].
///
/// Owns the scroll controllers that keep the frozen header and the
/// body horizontally in sync, and caches the computed column layout
/// so it is only recomputed when the viewport width, inherited text
/// state, or the widget's data actually change. Layout math and cell
/// construction live in the `part` files
/// (`display_query_widget_layout.dart`,
/// `display_query_widget_cells.dart`) as extensions on this class.
class DisplayQueryWidgetState extends State<DisplayQueryWidget> {
  /// Drives horizontal scrolling of the frozen header row. Kept in
  /// lock-step with [_horizontalBodyController] by
  /// [_syncHorizontalScroll].
  final ScrollController _horizontalHeaderController = ScrollController();

  /// Drives horizontal scrolling of the table body. Kept in lock-step
  /// with [_horizontalHeaderController] by [_syncHorizontalScroll].
  final ScrollController _horizontalBodyController = ScrollController();

  /// Drives vertical scrolling of the table body. The header sits
  /// outside this scroll view, which is what keeps it frozen.
  final ScrollController _verticalController = ScrollController();

  /// Per-column widths from the most recent layout pass,
  /// index-aligned with [_displayColumns].
  List<double> _columnWidths = [];

  /// Column headers currently displayed, including the leading `#`
  /// column when `showRowNumbers` is enabled.
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

  /// Invalidates cached column widths when the columns, row count, or
  /// row-number visibility change, so the next build's
  /// `LayoutBuilder` pass recomputes the layout against the new data.
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

  /// Mirrors offsets between the header and body horizontal
  /// controllers in both directions, so dragging either surface
  /// scrolls the other. The offset-equality guard breaks the
  /// listener feedback loop that the mutual mirroring would
  /// otherwise create.
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

  /// Shallow element-wise equality for two lists.
  ///
  /// Local stand-in for `package:collection`'s `listEquals` to avoid
  /// pulling in the dependency for one comparison.
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Builds the table: a frozen header above a scrollable body.
  ///
  /// Short-circuits to [DisplayQueryWidget.emptyWidget] (or a
  /// fallback) when there are no columns or no rows. Otherwise a
  /// `LayoutBuilder` supplies the viewport width, and the column
  /// layout is recomputed only when that width differs from the
  /// cached [_lastViewportWidth].
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
          calculateLayout(viewportWidth);
          _lastViewportWidth = viewportWidth;
        }

        return Column(
          children: [
            buildHeader(),
            Expanded(child: buildBody()),
          ],
        );
      },
    );
  }
}

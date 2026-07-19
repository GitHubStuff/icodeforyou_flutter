// packages/data_grid/lib/src/data_grid.dart

import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';

/// Default width, in logical pixels, for a column with no override.
const double _kDefaultColumnWidth = 120;

/// Horizontal padding inside every cell.
const double _kCellHorizontalPadding = 8;

/// Vertical padding above and below the single line of text in a cell.
/// Contributes to the computed row height.
const double _kCellVerticalPadding = 8;

/// Width of the grid lines, per spec: each cell reads as a 1dp box.
const double _kGridLineWidth = 1;

/// Sample glyph used to measure a style's single-line height. For a
/// single line the height comes from font metrics, not content, so any
/// glyph gives the same answer.
const String _kLineHeightSample = 'X';

/// Caption shown in the corner cell above the row buttons. Tapping the
/// corner animates the grid back to its initial scroll position.
const String _kCornerCaption = '#';

/// Duration of the corner-tap scroll-home animation.
const Duration _kResetScrollDuration = Duration(milliseconds: 300);

/// Curve of the corner-tap scroll-home animation.
const Curve _kResetScrollCurve = Curves.easeInOut;

/// The three sort states a column header cycles through on tap.
///
/// Invariant: [_DataGridState._sortColumn] is null if and only if the
/// state is [none]. An active sort column is always [ascending] or
/// [descending].
enum _SortState { none, ascending, descending }

/// A named ladder of symmetric [VisualDensity] values for
/// [DataGrid.density], from [dense] to [airy] in 4dp steps around the
/// 48dp touch-target baseline.
///
/// This enum is a pure helper: [DataGrid] takes a raw [VisualDensity],
/// and these rungs are convenient, documented values to pass —
/// `density: DataDensity.compact.toVisualDensity()`. [compact],
/// [comfortable], and [standard] sit at Material's own values for
/// those names.
enum DataDensity {
  /// −3 · 36dp row floor. Below Material's touch-target guidance;
  /// intended for pointer-driven contexts. Never auto-selected by
  /// [forWindowWidth].
  dense(-3),

  /// −2 · 40dp row floor. Matches [VisualDensity.compact].
  compact(-2),

  /// −1 · 44dp row floor. Matches [VisualDensity.comfortable].
  comfortable(-1),

  /// 0 · 48dp row floor ([kMinInteractiveDimension]). Matches
  /// [VisualDensity.standard], the [DataGrid] default.
  standard(0),

  /// +1 · 52dp row floor.
  relaxed(1),

  /// +2 · 56dp row floor.
  spacious(2),

  /// +3 · 60dp row floor.
  airy(3);

  /// Creates a density rung with its symmetric [VisualDensity] step.
  const DataDensity(this._step);

  final int _step;

  /// Material 3 window-width breakpoints (exclusive upper bounds).
  static const double _kMediumUpperBound = 840;
  static const double _kExpandedUpperBound = 1200;
  static const double _kLargeUpperBound = 1600;

  /// The density rung appropriate for a window of [width] logical
  /// pixels.
  ///
  /// Maps Material 3 window size classes onto rungs conservatively:
  /// width predicts input device imperfectly, so touch-sized windows
  /// always resolve to [standard], and only confidently-desktop widths
  /// reach [dense]. Positive rungs are never auto-selected.
  static DataDensity forWindowWidth(double width) {
    if (width < _kMediumUpperBound) return standard;
    if (width < _kExpandedUpperBound) return comfortable;
    if (width < _kLargeUpperBound) return compact;
    return dense;
  }

  /// The symmetric Material [VisualDensity] for this rung.
  VisualDensity toVisualDensity() {
    final value = _step.toDouble();
    return VisualDensity(horizontal: value, vertical: value);
  }
}

/// Signature for [DataGrid.onRowTap].
///
/// [rowNumber] is the 1-based **display position** of the tapped row —
/// row 1 is whatever row is currently displayed first. It is a display
/// coordinate, not a stable identity: sorting changes which data row a
/// given number refers to. [rowData] is the row currently displayed at
/// that position.
typedef DataGridRowTapCallback =
    void Function(
      int rowNumber,
      Map<String, Object?> rowData,
    );

/// A horizontally scrolling, spreadsheet-style grid for query results.
///
/// [DataGrid] renders a `List<Map<String, Object?>>` — the shape returned
/// by a database query — as a grid with:
///
/// * Tap-able column headers that cycle `unsorted → ascending →
///   descending → unsorted`, showing an up or down arrow icon next to
///   the active column name. Only one column sorts at a time; tapping a
///   new header resets the previous one.
/// * A pinned row-button column along the left edge: numbered 1..N top
///   to bottom, unaffected by sorting, never scrolling horizontally.
///   Tapping a row button always fires haptic feedback and reports the
///   displayed row via [onRowTap] when provided.
/// * A pinned header row: the data scrolls vertically underneath it, and
///   both scroll together horizontally.
/// * A corner cell above the row buttons; tapping it animates the grid
///   back to its initial scroll position on both axes.
/// * Single-line cells that ellipsize instead of wrapping. Tapping a cell
///   opens a barrier-dismissible dialog with the column name and the full
///   cell value.
/// * Alternating row backgrounds and theme-aware 1dp grid lines.
///
/// The header row, row buttons, and corner cell are collectively "the
/// chrome": styled by [headerStyle] and [chromeColor], uniform, and
/// independent from the data area's [dataStyle] and alternating colors.
/// The default chrome uses the theme's secondary-container color pair,
/// deliberately outside the neutral surface family the data rows use,
/// so the frame reads as frame.
///
/// Row height, sort icon size, and minimum column widths are all derived
/// from [headerStyle] and [dataStyle] (and the ambient [TextScaler]), so
/// the grid adapts to the styles and to accessibility text scaling. The
/// row-height floor is [kMinInteractiveDimension] adjusted by [density];
/// at the default [VisualDensity.standard] rows never shrink below 48dp,
/// Material's minimum touch target. Density sets the floor and styles
/// set the content's claim — the taller of the two always wins, so
/// density can never clip text.
///
/// Sorting never mutates [data]; an internal copy is sorted, and the
/// third tap restores the copy's original order. String ordering is
/// case-sensitive by default; see [isCaseSensitive].
///
/// [DataGrid] must be given bounded height (as with any vertically
/// scrolling list).
class DataGrid extends StatefulWidget {
  /// Creates a [DataGrid] for [data].
  const DataGrid({
    required this.data,
    this.columnWidths,
    this.headerStyle,
    this.dataStyle,
    this.isCaseSensitive = true,
    this.onRowTap,
    this.chromeColor,
    this.haptic = HapticIntensity.light,
    this.density = VisualDensity.standard,
    this.horizontalController,
    this.verticalController,
    super.key,
  });

  /// The rows to display. All rows are expected to share the same keys,
  /// and the column order is taken from the first row's key order.
  ///
  /// This list is never mutated.
  final List<Map<String, Object?>> data;

  /// Optional column width overrides, in logical pixels, keyed by column
  /// name.
  ///
  /// An override can widen a column freely but can never shrink it below
  /// the width of its caption plus the sort indicator slot: the effective
  /// width is always at least wide enough to show the full header text
  /// with the sort icon beside it.
  final Map<String, int>? columnWidths;

  /// The text style for the chrome: header captions, row-button
  /// numbers, and the corner caption. Also determines the sort icon
  /// size and participates in the computed row height.
  ///
  /// Merged over the ambient theme's [TextTheme.titleSmall] colored
  /// [ColorScheme.onSecondaryContainer]: properties set here win, and
  /// unset properties (font size, family, spacing) inherit from that
  /// base — so a partial style like `TextStyle(color: Colors.amber)`
  /// recolors the chrome without changing its metrics.
  final TextStyle? headerStyle;

  /// The style for data cell text, including the full value shown in the
  /// cell inspection dialog. Participates in the computed row height.
  ///
  /// Merged over the ambient theme's [TextTheme.bodyMedium]: properties
  /// set here win, and unset properties inherit from that base.
  final TextStyle? dataStyle;

  /// Whether string sorting compares raw case ('Z' orders before 'a')
  /// instead of a case-insensitive comparison.
  ///
  /// Applies to string-vs-string comparisons and to the string fallback
  /// used for mixed-type columns. Has no effect on null placement: nulls
  /// always sort last ascending and first descending, regardless of this
  /// flag. Numeric comparisons are likewise unaffected.
  final bool isCaseSensitive;

  /// Called when a row button is tapped, with the 1-based display
  /// position and the row currently displayed there.
  ///
  /// Row-button taps always fire haptic feedback, whether or not this
  /// callback is provided. [DataGrid] performs no other UI response to
  /// a row tap; any visual reaction is the callback's responsibility.
  final DataGridRowTapCallback? onRowTap;

  /// The background color of the chrome: the header row, the row-button
  /// column, and the corner cell. The chrome background is uniform and
  /// never alternates.
  ///
  /// When null, defaults to the ambient theme's
  /// [ColorScheme.secondaryContainer] — a tinted role outside the
  /// neutral surface family used by the data rows, so the chrome is
  /// visually distinct from the data by default.
  final Color? chromeColor;

  /// The haptic feedback fired by every tap in the grid: headers, data
  /// cells, row buttons, and the corner cell. Use
  /// [HapticIntensity.none] to disable.
  final HapticIntensity haptic;

  /// How tightly rows are packed. The vertical component adjusts the
  /// row-height floor and the horizontal component adjusts the
  /// row-button column's minimum width, both in 4dp steps per density
  /// unit around Material's 48dp default.
  ///
  /// Density sets the floor; [headerStyle] and [dataStyle] set the
  /// content's claim. The taller of the two always wins, so density can
  /// never clip text — a negative density under a large style is a
  /// silent no-op by design.
  ///
  /// Defaults to [VisualDensity.standard] (the 48dp touch-target
  /// floor). [DataDensity] provides a named ladder of curated values;
  /// e.g. `density: DataDensity.compact.toVisualDensity()`.
  final VisualDensity density;

  /// Optional controller for the shared horizontal axis (header and
  /// data pan together).
  ///
  /// Controllers are exclusive to this [DataGrid]. If provided, the
  /// caller owns its lifecycle and must dispose it; if null, the widget
  /// creates and disposes its own.
  final ScrollController? horizontalController;

  /// Optional controller for the data area's vertical axis. The
  /// row-button column follows this axis automatically and cannot be
  /// scrolled independently.
  ///
  /// Controllers are exclusive to this [DataGrid]. If provided, the
  /// caller owns its lifecycle and must dispose it; if null, the widget
  /// creates and disposes its own.
  final ScrollController? verticalController;

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  late List<Map<String, Object?>> _originalRows;
  late List<Map<String, Object?>> _rows;

  String? _sortColumn;
  _SortState _sortState = _SortState.none;

  ScrollController? _ownedHorizontalController;
  ScrollController? _ownedVerticalController;

  /// Follower controller for the row-button list. Its offset is derived
  /// state — a pure mirror of [_verticalController] — so it is never
  /// exposed: a second writable handle to one scroll position would
  /// invite desyncing the chrome from the data.
  late final ScrollController _rowButtonController;

  ScrollController get _horizontalController =>
      widget.horizontalController ?? _ownedHorizontalController!;

  ScrollController get _verticalController =>
      widget.verticalController ?? _ownedVerticalController!;

  @override
  void initState() {
    super.initState();
    _copyData();
    if (widget.horizontalController == null) {
      _ownedHorizontalController = ScrollController();
    }
    if (widget.verticalController == null) {
      _ownedVerticalController = ScrollController();
    }
    _rowButtonController = ScrollController();
    _verticalController.addListener(_syncRowButtons);
  }

  @override
  void didUpdateWidget(DataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dataChanged = !identical(oldWidget.data, widget.data);
    if (dataChanged) {
      _copyData();
    }
    if (dataChanged || oldWidget.isCaseSensitive != widget.isCaseSensitive) {
      _applySort();
    }

    if (!identical(
      oldWidget.verticalController,
      widget.verticalController,
    )) {
      (oldWidget.verticalController ?? _ownedVerticalController!)
          .removeListener(_syncRowButtons);
      if (oldWidget.verticalController == null) {
        _ownedVerticalController!.dispose();
        _ownedVerticalController = null;
      }
      if (widget.verticalController == null) {
        _ownedVerticalController = ScrollController();
      }
      _verticalController.addListener(_syncRowButtons);
    }

    if (!identical(
      oldWidget.horizontalController,
      widget.horizontalController,
    )) {
      if (oldWidget.horizontalController == null) {
        _ownedHorizontalController!.dispose();
        _ownedHorizontalController = null;
      }
      if (widget.horizontalController == null) {
        _ownedHorizontalController = ScrollController();
      }
    }
  }

  @override
  void dispose() {
    _verticalController.removeListener(_syncRowButtons);
    _rowButtonController.dispose();
    _ownedHorizontalController?.dispose();
    _ownedVerticalController?.dispose();
    super.dispose();
  }

  void _copyData() {
    _originalRows = List.of(widget.data);
    _rows = List.of(_originalRows);
  }

  void _syncRowButtons() {
    if (_rowButtonController.hasClients) {
      _rowButtonController.jumpTo(_verticalController.offset);
    }
  }

  void _resetScroll() {
    if (_horizontalController.hasClients) {
      unawaited(
        _horizontalController.animateTo(
          0,
          duration: _kResetScrollDuration,
          curve: _kResetScrollCurve,
        ),
      );
    }
    if (_verticalController.hasClients) {
      unawaited(
        _verticalController.animateTo(
          0,
          duration: _kResetScrollDuration,
          curve: _kResetScrollCurve,
        ),
      );
    }
  }

  /// The fully resolved chrome text style: the caller's [DataGrid.headerStyle]
  /// merged over the theme base, so partial styles inherit the base's
  /// metrics. Measurement and rendering both use this resolved style —
  /// they must never diverge, or columns sized by measurement overflow
  /// at render time.
  TextStyle _effectiveHeaderStyle(ThemeData theme) {
    final base = (theme.textTheme.titleSmall ?? const TextStyle()).copyWith(
      color: theme.colorScheme.onSecondaryContainer,
    );
    return base.merge(widget.headerStyle);
  }

  /// The fully resolved data text style: the caller's [DataGrid.dataStyle]
  /// merged over the theme base. See [_effectiveHeaderStyle] for why
  /// resolution must be complete.
  TextStyle _effectiveDataStyle(ThemeData theme) {
    final base = theme.textTheme.bodyMedium ?? const TextStyle();
    return base.merge(widget.dataStyle);
  }

  void _onHeaderTap(String column) {
    setState(() {
      if (_sortColumn != column) {
        _sortColumn = column;
        _sortState = _SortState.ascending;
      } else if (_sortState == _SortState.ascending) {
        _sortState = _SortState.descending;
      } else {
        _sortState = _SortState.none;
        _sortColumn = null;
      }
      _applySort();
    });
  }

  void _applySort() {
    final column = _sortColumn;
    if (column == null) {
      _rows = List.of(_originalRows);
      return;
    }
    final direction = _sortState == _SortState.ascending ? 1 : -1;
    _rows = List.of(_originalRows)
      ..sort((a, b) => direction * _compareValues(a[column], b[column]));
  }

  /// Orders two cell values: nulls sort last ascending (and therefore
  /// first descending) regardless of [DataGrid.isCaseSensitive], numbers
  /// numerically, strings per [_compareStrings], and mixed types by
  /// their string representation per [_compareStrings].
  int _compareValues(Object? a, Object? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    if (a is num && b is num) return a.compareTo(b);
    if (a is String && b is String) return _compareStrings(a, b);
    return _compareStrings(a.toString(), b.toString());
  }

  /// Compares two strings honoring [DataGrid.isCaseSensitive].
  int _compareStrings(String a, String b) {
    if (widget.isCaseSensitive) return a.compareTo(b);
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  /// The sort indicator icon for [column], or null when the column is
  /// not the active sort column.
  ///
  /// An active sort column is always ascending or descending — never
  /// [_SortState.none] — because cycling back to unsorted also clears
  /// [_sortColumn].
  IconData? _sortIconFor(String column) {
    if (column != _sortColumn) return null;
    return _sortState == _SortState.ascending
        ? Icons.arrow_drop_up
        : Icons.arrow_drop_down;
  }

  Size _measureText(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final size = painter.size;
    painter.dispose();
    return size;
  }

  double _lineHeight(TextStyle style, TextScaler scaler) {
    return _measureText(_kLineHeightSample, style, scaler).height;
  }

  double _effectiveWidth(
    String column,
    TextStyle headerStyle,
    TextScaler scaler,
    double sortIconSize,
  ) {
    final captionMinimum =
        (_measureText(column, headerStyle, scaler).width +
                sortIconSize +
                (2 * _kCellHorizontalPadding))
            .ceilToDouble();
    final requested =
        widget.columnWidths?[column]?.toDouble() ?? _kDefaultColumnWidth;
    return math.max(requested, captionMinimum);
  }

  /// Width of the row-button column: wide enough for the largest row
  /// number and the corner caption, and never narrower than the
  /// density-adjusted minimum touch target [minTapTarget].
  double _rowButtonColumnWidth(
    TextStyle headerStyle,
    TextScaler scaler,
    double minTapTarget,
  ) {
    final widestLabel = math.max(
      _measureText('${_rows.length}', headerStyle, scaler).width,
      _measureText(_kCornerCaption, headerStyle, scaler).width,
    );
    return math.max(
      (widestLabel + (2 * _kCellHorizontalPadding)).ceilToDouble(),
      minTapTarget,
    );
  }

  void _showCellDialog(String column, Object? value) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        final dataStyle = _effectiveDataStyle(theme);
        return AlertDialog(
          title: Text(column, style: _effectiveHeaderStyle(theme)),
          content: value == null
              ? Text('null', style: _nullStyle(theme, dataStyle))
              : SelectableText(value.toString(), style: dataStyle),
        );
      },
    );
  }

  TextStyle _nullStyle(ThemeData theme, TextStyle base) {
    return base.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      fontStyle: FontStyle.italic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final headerStyle = _effectiveHeaderStyle(theme);
    final dataStyle = _effectiveDataStyle(theme);
    final lineColor = theme.colorScheme.outlineVariant;
    final chromeColor =
        widget.chromeColor ?? theme.colorScheme.secondaryContainer;
    final chromeIconColor = headerStyle.color ?? theme.colorScheme.onSurface;

    final densityAdjustment = widget.density.baseSizeAdjustment;
    final minRowHeight = kMinInteractiveDimension + densityAdjustment.dy;
    final minButtonWidth = kMinInteractiveDimension + densityAdjustment.dx;

    final headerLineHeight = _lineHeight(headerStyle, scaler);
    final dataLineHeight = _lineHeight(dataStyle, scaler);
    final sortIconSize = headerLineHeight;
    final rowHeight = math.max(
      math.max(headerLineHeight, dataLineHeight) + (2 * _kCellVerticalPadding),
      minRowHeight,
    );

    final columns = _originalRows.first.keys.toList();
    final widths = <String, double>{
      for (final column in columns)
        column: _effectiveWidth(column, headerStyle, scaler, sortIconSize),
    };
    final totalWidth = widths.values.fold<double>(
      0,
      (sum, width) => sum + width,
    );
    final buttonColumnWidth = _rowButtonColumnWidth(
      headerStyle,
      scaler,
      minButtonWidth,
    );

    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: lineColor, width: _kGridLineWidth),
          left: BorderSide(color: lineColor, width: _kGridLineWidth),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: buttonColumnWidth,
            child: Column(
              children: <Widget>[
                _buildCornerCell(
                  width: buttonColumnWidth,
                  height: rowHeight,
                  style: headerStyle,
                  lineColor: lineColor,
                  background: chromeColor,
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _rowButtonController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemExtent: rowHeight,
                    itemCount: _rows.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildRowButton(
                        rowNumber: index + 1,
                        rowData: _rows[index],
                        width: buttonColumnWidth,
                        height: rowHeight,
                        style: headerStyle,
                        lineColor: lineColor,
                        background: chromeColor,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        for (final column in columns)
                          _buildHeaderCell(
                            column: column,
                            width: widths[column]!,
                            height: rowHeight,
                            style: headerStyle,
                            sortIconSize: sortIconSize,
                            lineColor: lineColor,
                            background: chromeColor,
                            iconColor: chromeIconColor,
                          ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _verticalController,
                        itemExtent: rowHeight,
                        itemCount: _rows.length,
                        itemBuilder: (BuildContext context, int index) {
                          final row = _rows[index];
                          final background = index.isEven
                              ? theme.colorScheme.surfaceContainerHighest
                              : theme.colorScheme.surface;
                          return Row(
                            children: <Widget>[
                              for (final column in columns)
                                _buildDataCell(
                                  column: column,
                                  value: row[column],
                                  width: widths[column]!,
                                  height: rowHeight,
                                  style: dataStyle,
                                  theme: theme,
                                  lineColor: lineColor,
                                  background: background,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerCell({
    required double width,
    required double height,
    required TextStyle style,
    required Color lineColor,
    required Color background,
  }) {
    return _buildCell(
      width: width,
      height: height,
      background: background,
      lineColor: lineColor,
      alignment: Alignment.center,
      onTap: widget.haptic.wrap(_resetScroll),
      child: Text(
        _kCornerCaption,
        style: style,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  Widget _buildRowButton({
    required int rowNumber,
    required Map<String, Object?> rowData,
    required double width,
    required double height,
    required TextStyle style,
    required Color lineColor,
    required Color background,
  }) {
    return _buildCell(
      width: width,
      height: height,
      background: background,
      lineColor: lineColor,
      alignment: Alignment.center,
      onTap: widget.haptic.wrap(
        () => widget.onRowTap?.call(rowNumber, rowData),
      ),
      child: Text(
        '$rowNumber',
        style: style,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  Widget _buildHeaderCell({
    required String column,
    required double width,
    required double height,
    required TextStyle style,
    required double sortIconSize,
    required Color lineColor,
    required Color background,
    required Color iconColor,
  }) {
    final icon = _sortIconFor(column);
    return _buildCell(
      width: width,
      height: height,
      background: background,
      lineColor: lineColor,
      onTap: widget.haptic.wrap(() => _onHeaderTap(column)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(column, style: style, maxLines: 1, softWrap: false),
          SizedBox(
            width: sortIconSize,
            child: icon == null
                ? null
                : Icon(icon, size: sortIconSize, color: iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell({
    required String column,
    required Object? value,
    required double width,
    required double height,
    required TextStyle style,
    required ThemeData theme,
    required Color lineColor,
    required Color background,
  }) {
    final text = value == null
        ? Text(
            'null',
            style: _nullStyle(theme, style),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          )
        : Text(
            value.toString(),
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          );
    return _buildCell(
      width: width,
      height: height,
      background: background,
      lineColor: lineColor,
      onTap: widget.haptic.wrap(() => _showCellDialog(column, value)),
      child: text,
    );
  }

  /// Shared cell chrome: fixed size, tappable Material surface, and a
  /// 1dp right/bottom grid line painted over the content edge. Combined
  /// with the grid's outer top/left border, every cell reads as a fully
  /// enclosed 1dp box.
  Widget _buildCell({
    required double width,
    required double height,
    required Color background,
    required Color lineColor,
    required VoidCallback? onTap,
    required Widget child,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Container(
      width: width,
      height: height,
      foregroundDecoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: lineColor, width: _kGridLineWidth),
          bottom: BorderSide(color: lineColor, width: _kGridLineWidth),
        ),
      ),
      child: Material(
        color: background,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _kCellHorizontalPadding,
            ),
            child: Align(alignment: alignment, child: child),
          ),
        ),
      ),
    );
  }
}

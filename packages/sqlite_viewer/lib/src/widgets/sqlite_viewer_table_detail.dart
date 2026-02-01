// packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_table_detail.dart

import 'package:flutter/material.dart';

import 'package:sqlite_viewer/src/models/text_handling.dart';
import 'package:sqlite_viewer/src/widgets/display_query_widget.dart';

part '_sqlite_viewer_table_detail_schema.dart';
part '_sqlite_viewer_table_detail_items.dart';

/// A widget displaying table structure and data.
///
/// Shows:
/// - Table schema (columns, types, constraints)
/// - Indexes
/// - Foreign keys
/// - Table data in a spreadsheet view
///
/// Used as the main content area in 'SqliteViewerPage' when a table is selected.
///
/// Example:
/// ```dart
/// SqliteViewerTableDetail(
///   tableName: 'users',
///   columns: ['id', 'name', 'email'],
///   tableInfo: pragmaTableInfoResult,
///   indexList: pragmaIndexListResult,
///   foreignKeys: pragmaForeignKeyListResult,
///   rows: tableData,
///   rowCount: 150,
/// )
/// ```
class SqliteViewerTableDetail extends StatefulWidget {
  /// [SqliteViewerTableDetail] constructor
  const SqliteViewerTableDetail({
    required this.tableName,
    required this.columns,
    required this.tableInfo,
    required this.indexList,
    required this.foreignKeys,
    required this.rows,
    required this.rowCount,
    super.key,
    this.onRefresh,
    this.isLoading = false,
    this.showRowNumbers = true,
    this.headerStyle,
    this.evenRowStyle,
    this.oddRowStyle,
    this.evenRowColor,
    this.oddRowColor,
    this.headerBackgroundColor,
    this.nullValueDisplay = 'NULL',
    this.textHandling = TextHandling.trunc,
  });

  /// Name of the table being displayed.
  final String tableName;

  /// Column names in ordinal order.
  final List<String> columns;

  /// PRAGMA table_info result — column definitions.
  final List<Map<String, Object?>> tableInfo;

  /// PRAGMA index_list result — index definitions.
  final List<Map<String, Object?>> indexList;

  /// PRAGMA foreign_key_list result — foreign key relationships.
  final List<Map<String, Object?>> foreignKeys;

  /// Table data rows.
  final List<Map<String, Object?>> rows;

  /// Total row count in table.
  final int rowCount;

  /// Callback when refresh is requested.
  final VoidCallback? onRefresh;

  /// Whether data is currently being refreshed.
  final bool isLoading;

  /// Whether to show row numbers in data grid.
  final bool showRowNumbers;

  /// Style for section headers.
  final TextStyle? headerStyle;

  /// Style for even rows in data grid.
  final TextStyle? evenRowStyle;

  /// Style for odd rows in data grid.
  final TextStyle? oddRowStyle;

  /// Background color for even rows.
  final Color? evenRowColor;

  /// Background color for odd rows.
  final Color? oddRowColor;

  /// Background color for header row.
  final Color? headerBackgroundColor;

  /// Display string for null values.
  final String nullValueDisplay;

  /// How to handle text overflow in cells.
  final TextHandling textHandling;

  @override
  State<SqliteViewerTableDetail> createState() =>
      _SqliteViewerTableDetailState();
}

class _SqliteViewerTableDetailState extends State<SqliteViewerTableDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildHeader(context, theme, colorScheme),

        // Tab bar
        ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.table_rows_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Data (${widget.rowCount})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schema_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Schema (${widget.tableInfo.length})'),
                  ],
                ),
              ),
            ],
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDataTab(context, theme, colorScheme),
              _buildSchemaTab(context, theme, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      color: colorScheme.surface,
      child: Row(
        children: [
          Icon(
            Icons.table_chart,
            size: 24,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tableName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.columns.length} columns • ${widget.rowCount} rows',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onRefresh != null)
            IconButton(
              icon: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      color: colorScheme.primary,
                    ),
              onPressed: widget.isLoading ? null : widget.onRefresh,
              tooltip: 'Refresh table data',
            ),
        ],
      ),
    );
  }

  Widget _buildDataTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (widget.rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No data in table',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final effectiveEvenStyle =
        widget.evenRowStyle ??
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);

    final effectiveOddStyle =
        widget.oddRowStyle ??
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);

    return DisplayQueryWidget(
      columns: widget.columns,
      rows: widget.rows,
      evenRowStyle: effectiveEvenStyle,
      oddRowStyle: effectiveOddStyle,
      headerStyle: widget.headerStyle,
      evenRowColor: widget.evenRowColor ?? colorScheme.surface,
      oddRowColor: widget.oddRowColor ?? colorScheme.surfaceContainerLowest,
      headerBackgroundColor:
          widget.headerBackgroundColor ?? colorScheme.surfaceContainerHighest,
      showRowNumbers: widget.showRowNumbers,
      nullValueDisplay: widget.nullValueDisplay,
      textHandling: widget.textHandling,
    );
  }
}

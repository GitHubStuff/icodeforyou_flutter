// packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_metadata_panel.dart

import 'package:flutter/material.dart';

import 'package:sqlite_viewer/src/models/database_metadata.dart';

part 'sqlite_viewer_metadata_panel_table_list.dart';

/// A panel displaying database metadata and table list.
///
/// Shows:
/// - Database filename and path
/// - SQLite version
/// - Database size
/// - List of tables with row counts
///
/// Used as a sidebar in 'SqliteViewerPage' on tablet/desktop,
/// or as the Tables tab content on phone.
///
/// Example:
/// ```dart
/// SqliteViewerMetadataPanel(
///   metadata: databaseMetadata,
///   selectedTable: 'users',
///   onTableSelected: (tableName) => cubit.selectTable(tableName),
///   onRefresh: () => cubit.refreshMetadata(),
/// )
/// ```
class SqliteViewerMetadataPanel extends StatelessWidget {
  /// Create a [SqliteViewerMetadataPanel]
  const SqliteViewerMetadataPanel({
    required this.metadata,
    super.key,
    this.selectedTable,
    this.onTableSelected,
    this.onRefresh,
    this.isLoading = false,
    this.headerStyle,
    this.labelStyle,
    this.valueStyle,
    this.tableItemStyle,
    this.selectedTableColor,
    this.backgroundColor,
    this.dividerColor,
  });

  /// Database metadata to display.
  final DatabaseMetadata metadata;

  /// Currently selected table name, if any.
  final String? selectedTable;

  /// Callback when a table is tapped.
  final ValueChanged<String>? onTableSelected;

  /// Callback when refresh is requested.
  final VoidCallback? onRefresh;

  /// Whether metadata is currently being refreshed.
  final bool isLoading;

  /// Style for section headers.
  final TextStyle? headerStyle;

  /// Style for metadata labels.
  final TextStyle? labelStyle;

  /// Style for metadata values.
  final TextStyle? valueStyle;

  /// Style for table list items.
  final TextStyle? tableItemStyle;

  /// Background color for selected table.
  final Color? selectedTableColor;

  /// Panel background color.
  final Color? backgroundColor;

  /// Divider color.
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveHeaderStyle =
        headerStyle ??
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        );

    final effectiveLabelStyle =
        labelStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );

    final effectiveValueStyle =
        valueStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );

    final effectiveTableItemStyle =
        tableItemStyle ?? theme.textTheme.bodyMedium;

    final effectiveSelectedColor =
        selectedTableColor ?? colorScheme.primaryContainer;

    final effectiveDividerColor = dividerColor ?? colorScheme.outlineVariant;

    return ColoredBox(
      color: backgroundColor ?? colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with refresh button
          _buildHeader(context, effectiveHeaderStyle, colorScheme),

          Divider(height: 1, color: effectiveDividerColor),

          // Database info section
          _buildDatabaseInfo(
            context,
            effectiveLabelStyle,
            effectiveValueStyle,
          ),

          Divider(height: 1, color: effectiveDividerColor),

          // Tables section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  'Tables',
                  style: effectiveHeaderStyle,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${metadata.tableCount}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table list
          Expanded(
            child: buildTableList(
              context,
              effectiveTableItemStyle,
              effectiveSelectedColor,
              effectiveDividerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TextStyle? headerStyle,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Icon(
            metadata.isInMemory ? Icons.memory : Icons.storage,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              metadata.filename,
              style: headerStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: isLoading
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
                      size: 20,
                      color: colorScheme.primary,
                    ),
              onPressed: isLoading ? null : onRefresh,
              tooltip: 'Refresh metadata',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildDatabaseInfo(
    BuildContext context,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Path',
            metadata.isInMemory ? 'In-memory database' : metadata.fullPath,
            labelStyle,
            valueStyle,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'SQLite',
                  metadata.sqliteVersion,
                  labelStyle,
                  valueStyle,
                ),
              ),
              Expanded(
                child: _buildInfoRow(
                  'Size',
                  metadata.formattedSize,
                  labelStyle,
                  valueStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 2),
        Text(
          value,
          style: valueStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }
}

// packages/sqlite_viewer/lib/src/widgets/_sqlite_viewer_metadata_panel_table_list.dart

part of 'sqlite_viewer_metadata_panel.dart';

// =============================================================================
// Table List Building
// =============================================================================

extension _TableListBuilder on SqliteViewerMetadataPanel {
  Widget _buildTableList(
    BuildContext context,
    TextStyle? tableItemStyle,
    Color selectedColor,
    Color dividerColor,
  ) {
    if (metadata.tables.isEmpty) {
      return Center(
        child: Text(
          'No tables found',
          style: tableItemStyle?.copyWith(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: metadata.tables.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 16,
        color: dividerColor,
      ),
      itemBuilder: (context, index) {
        final tableName = metadata.tables[index];
        final isSelected = tableName == selectedTable;

        return _buildTableItem(
          context,
          tableName,
          isSelected,
          tableItemStyle,
          selectedColor,
        );
      },
    );
  }

  Widget _buildTableItem(
    BuildContext context,
    String tableName,
    bool isSelected,
    TextStyle? tableItemStyle,
    Color selectedColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? selectedColor : Colors.transparent,
      child: InkWell(
        onTap: onTableSelected != null ? () => onTableSelected!(tableName) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.table_chart_outlined,
                size: 18,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tableName,
                  style: tableItemStyle?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

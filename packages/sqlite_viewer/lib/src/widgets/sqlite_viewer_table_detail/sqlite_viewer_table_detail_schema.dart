// packages/sqlite_viewer/lib/src/widgets/_sqlite_viewer_table_detail_schema.dart

part of 'sqlite_viewer_table_detail.dart';

// =============================================================================
// Schema Tab Building
// =============================================================================

extension _SchemaTabBuilder on _SqliteViewerTableDetailState {
  Widget _buildSchemaTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Columns section
        _buildSchemaSection(
          context,
          title: 'Columns',
          icon: Icons.view_column_outlined,
          items: widget.tableInfo,
          itemBuilder: (item) => _buildColumnItem(context, item, colorScheme),
        ),

        const SizedBox(height: 24),

        // Indexes section
        _buildSchemaSection(
          context,
          title: 'Indexes',
          icon: Icons.sort_outlined,
          items: widget.indexList,
          emptyMessage: 'No indexes defined',
          itemBuilder: (item) => _buildIndexItem(context, item, colorScheme),
        ),

        const SizedBox(height: 24),

        // Foreign keys section
        _buildSchemaSection(
          context,
          title: 'Foreign Keys',
          icon: Icons.link_outlined,
          items: widget.foreignKeys,
          emptyMessage: 'No foreign keys defined',
          itemBuilder: (item) =>
              _buildForeignKeyItem(context, item, colorScheme),
        ),
      ],
    );
  }

  Widget _buildSchemaSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, Object?>> items,
    required Widget Function(Map<String, Object?>) itemBuilder,
    String? emptyMessage,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${items.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              emptyMessage ?? 'No items',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  itemBuilder(items[i]),
                  if (i < items.length - 1)
                    Divider(height: 1, color: colorScheme.outlineVariant),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

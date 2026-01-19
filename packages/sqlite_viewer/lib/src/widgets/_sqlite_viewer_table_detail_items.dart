// packages/sqlite_viewer/lib/src/widgets/_sqlite_viewer_table_detail_items.dart

part of 'sqlite_viewer_table_detail.dart';

// =============================================================================
// Schema Item Builders
// =============================================================================

extension _SchemaItemBuilders on _SqliteViewerTableDetailState {
  Widget _buildColumnItem(
    BuildContext context,
    Map<String, Object?> column,
    ColorScheme colorScheme,
  ) {
    final name = column['name']?.toString() ?? '';
    final type = column['type']?.toString() ?? '';
    final notNull = column['notnull'] == 1;
    final pk = column['pk'] == 1;
    final defaultValue = column['dflt_value'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (pk)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.key,
                      size: 16,
                      color: colorScheme.tertiary,
                    ),
                  ),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: pk ? FontWeight.bold : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              type,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (notNull)
                  _buildBadge(
                    context,
                    'NOT NULL',
                    colorScheme.errorContainer,
                    colorScheme.onErrorContainer,
                  ),
                if (defaultValue != null) ...[
                  const SizedBox(width: 4),
                  _buildBadge(
                    context,
                    'DEFAULT',
                    colorScheme.tertiaryContainer,
                    colorScheme.onTertiaryContainer,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexItem(
    BuildContext context,
    Map<String, Object?> index,
    ColorScheme colorScheme,
  ) {
    final name = index['name']?.toString() ?? '';
    final isUnique = index['unique'] == 1;
    final origin = index['origin']?.toString() ?? '';

    String originLabel;
    switch (origin) {
      case 'c':
        originLabel = 'CREATE INDEX';
        break;
      case 'u':
        originLabel = 'UNIQUE';
        break;
      case 'pk':
        originLabel = 'PRIMARY KEY';
        break;
      default:
        originLabel = origin;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isUnique)
            _buildBadge(
              context,
              'UNIQUE',
              colorScheme.primaryContainer,
              colorScheme.onPrimaryContainer,
            ),
          const SizedBox(width: 8),
          Text(
            originLabel,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForeignKeyItem(
    BuildContext context,
    Map<String, Object?> fk,
    ColorScheme colorScheme,
  ) {
    final fromColumn = fk['from']?.toString() ?? '';
    final toTable = fk['table']?.toString() ?? '';
    final toColumn = fk['to']?.toString() ?? '';
    final onDelete = fk['on_delete']?.toString() ?? 'NO ACTION';
    final onUpdate = fk['on_update']?.toString() ?? 'NO ACTION';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                fromColumn,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                '$toTable.$toColumn',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ON DELETE $onDelete • ON UPDATE $onUpdate',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String label,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

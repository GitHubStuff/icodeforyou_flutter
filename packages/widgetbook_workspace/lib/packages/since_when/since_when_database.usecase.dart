// lib/package/since_when/since_when_database.usecase.dart
//
// Companion file to since_when.usecase.dart
// Showcases database internals, pragma data, and sqlite_viewer integration.

import 'package:flutter/material.dart';
import 'package:since_when/since_when.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Mock Database Metadata
// =============================================================================

/// Simple table info holder for mock data.
class _MockTableInfo {
  const _MockTableInfo({required this.name, required this.rowCount});
  final String name;
  final int rowCount;
}

/// Simple database metadata holder for mock data.
class _MockDbMetadata {
  const _MockDbMetadata({
    required this.fullPath,
    required this.sqliteVersion,
    required this.databaseSize,
    required this.tables,
  });
  final String fullPath;
  final String sqliteVersion;
  final int databaseSize;
  final List<_MockTableInfo> tables;
}

/// Mock metadata that simulates what SinceWhenDatabase would return.
class _MockDatabaseMetadata {
  _MockDatabaseMetadata._();

  static _MockDbMetadata get metadata => const _MockDbMetadata(
        fullPath: ':memory:',
        sqliteVersion: '3.39.0',
        databaseSize: 49152,
        tables: [
          _MockTableInfo(name: 'since_when', rowCount: 8),
          _MockTableInfo(name: 'since_when_tags', rowCount: 24),
        ],
      );

  // ---------------------------------------------------------------------------
  // PRAGMA table_info(since_when)
  // ---------------------------------------------------------------------------
  static List<Map<String, Object?>> get sinceWhenTableInfo => [
        {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 0, 'dflt_value': null, 'pk': 1},
        {'cid': 1, 'name': 'createdTimeStamp', 'type': 'TEXT', 'notnull': 1, 'dflt_value': null, 'pk': 0},
        {'cid': 2, 'name': 'parentTimeStamp', 'type': 'TEXT', 'notnull': 0, 'dflt_value': null, 'pk': 0},
        {'cid': 3, 'name': 'reviewedTimeStamp', 'type': 'TEXT', 'notnull': 1, 'dflt_value': null, 'pk': 0},
        {'cid': 4, 'name': 'editedTimeStamp', 'type': 'TEXT', 'notnull': 1, 'dflt_value': null, 'pk': 0},
        {'cid': 5, 'name': 'metaTimeStamp', 'type': 'TEXT', 'notnull': 0, 'dflt_value': null, 'pk': 0},
        {'cid': 6, 'name': 'metaData', 'type': 'TEXT', 'notnull': 1, 'dflt_value': null, 'pk': 0},
        {'cid': 7, 'name': 'sequenceNumber', 'type': 'INTEGER', 'notnull': 1, 'dflt_value': '0', 'pk': 0},
        {'cid': 8, 'name': 'dataString', 'type': 'TEXT', 'notnull': 1, 'dflt_value': null, 'pk': 0},
        {'cid': 9, 'name': 'category', 'type': 'TEXT', 'notnull': 1, 'dflt_value': null, 'pk': 0},
      ];

  // ---------------------------------------------------------------------------
  // PRAGMA table_info(since_when_tags)
  // ---------------------------------------------------------------------------
  static List<Map<String, Object?>> get tagsTableInfo => [
        {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 0, 'dflt_value': null, 'pk': 1},
        {'cid': 1, 'name': 'created_time_stamp', 'type': 'TEXT', 'notnull': 1, 'dflt_value': null, 'pk': 0},
        {'cid': 2, 'name': 'tag', 'type': 'TEXT', 'notnull': 1, 'dflt_value': null, 'pk': 0},
      ];

  // ---------------------------------------------------------------------------
  // PRAGMA index_list(since_when)
  // ---------------------------------------------------------------------------
  static List<Map<String, Object?>> get sinceWhenIndexList => [
        {'seq': 0, 'name': 'idx_since_when_created', 'unique': 0, 'origin': 'c', 'partial': 0},
        {'seq': 1, 'name': 'idx_since_when_parent', 'unique': 0, 'origin': 'c', 'partial': 0},
        {'seq': 2, 'name': 'sqlite_autoindex_since_when_1', 'unique': 1, 'origin': 'u', 'partial': 0},
      ];

  // ---------------------------------------------------------------------------
  // PRAGMA index_list(since_when_tags)
  // ---------------------------------------------------------------------------
  static List<Map<String, Object?>> get tagsIndexList => [
        {'seq': 0, 'name': 'idx_tags_tag', 'unique': 0, 'origin': 'c', 'partial': 0},
        {'seq': 1, 'name': 'idx_tags_created_time_stamp', 'unique': 0, 'origin': 'c', 'partial': 0},
      ];

  // ---------------------------------------------------------------------------
  // PRAGMA foreign_key_list(since_when_tags)
  // ---------------------------------------------------------------------------
  static List<Map<String, Object?>> get tagsForeignKeys => [
        {
          'id': 0,
          'seq': 0,
          'table': 'since_when',
          'from': 'created_time_stamp',
          'to': 'createdTimeStamp',
          'on_update': 'NO ACTION',
          'on_delete': 'CASCADE',
          'match': 'NONE',
        },
      ];

  // ---------------------------------------------------------------------------
  // Mock since_when table rows
  // ---------------------------------------------------------------------------
  static List<Map<String, Object?>> get sinceWhenRows => [
        {
          'id': 1,
          'createdTimeStamp': '2025-01-19T10:00:01.000Z',
          'parentTimeStamp': null,
          'reviewedTimeStamp': '2025-01-19T10:00:01.000Z',
          'editedTimeStamp': '2025-01-19T10:00:01.000Z',
          'metaTimeStamp': null,
          'metaData': 'Project Alpha - Main Entry',
          'sequenceNumber': 0,
          'dataString': 'This is the parent record for Project Alpha.',
          'category': 'project',
        },
        {
          'id': 2,
          'createdTimeStamp': '2025-01-19T10:00:02.000Z',
          'parentTimeStamp': '2025-01-19T10:00:01.000Z',
          'reviewedTimeStamp': '2025-01-19T10:00:02.000Z',
          'editedTimeStamp': '2025-01-19T10:00:02.000Z',
          'metaTimeStamp': null,
          'metaData': 'Decision: Tech Stack',
          'sequenceNumber': 1,
          'dataString': 'Decided to use Flutter for cross-platform.',
          'category': 'decision',
        },
        {
          'id': 3,
          'createdTimeStamp': '2025-01-19T10:00:03.000Z',
          'parentTimeStamp': '2025-01-19T10:00:01.000Z',
          'reviewedTimeStamp': '2025-01-19T10:00:03.000Z',
          'editedTimeStamp': '2025-01-19T10:00:03.000Z',
          'metaTimeStamp': null,
          'metaData': 'Decision: Architecture',
          'sequenceNumber': 2,
          'dataString': 'Using Clean Architecture with BLoC pattern.',
          'category': 'decision',
        },
        {
          'id': 4,
          'createdTimeStamp': '2025-01-19T10:00:04.000Z',
          'parentTimeStamp': null,
          'reviewedTimeStamp': '2025-01-19T10:00:04.000Z',
          'editedTimeStamp': '2025-01-19T10:00:04.000Z',
          'metaTimeStamp': null,
          'metaData': 'Meeting Notes - Sprint Planning',
          'sequenceNumber': 0,
          'dataString': 'Discussed Q1 priorities and resource allocation.',
          'category': 'meetings',
        },
        {
          'id': 5,
          'createdTimeStamp': '2025-01-19T10:00:05.000Z',
          'parentTimeStamp': null,
          'reviewedTimeStamp': '2025-01-19T10:00:05.000Z',
          'editedTimeStamp': '2025-01-19T10:00:05.000Z',
          'metaTimeStamp': null,
          'metaData': 'Code Review Checklist',
          'sequenceNumber': 0,
          'dataString': 'Standard checklist for PR reviews.',
          'category': 'development',
        },
      ];

  // ---------------------------------------------------------------------------
  // Mock since_when_tags table rows (junction table)
  // ---------------------------------------------------------------------------
  static List<Map<String, Object?>> get tagsRows => [
        // Record 1 tags (Project Alpha)
        {'id': 1, 'created_time_stamp': '2025-01-19T10:00:01.000Z', 'tag': 'project-alpha'},
        {'id': 2, 'created_time_stamp': '2025-01-19T10:00:01.000Z', 'tag': 'parent'},
        {'id': 3, 'created_time_stamp': '2025-01-19T10:00:01.000Z', 'tag': 'flutter'},
        // Record 2 tags (Tech Stack)
        {'id': 4, 'created_time_stamp': '2025-01-19T10:00:02.000Z', 'tag': 'tech'},
        {'id': 5, 'created_time_stamp': '2025-01-19T10:00:02.000Z', 'tag': 'flutter'},
        {'id': 6, 'created_time_stamp': '2025-01-19T10:00:02.000Z', 'tag': 'mobile'},
        // Record 3 tags (Architecture)
        {'id': 7, 'created_time_stamp': '2025-01-19T10:00:03.000Z', 'tag': 'architecture'},
        {'id': 8, 'created_time_stamp': '2025-01-19T10:00:03.000Z', 'tag': 'bloc'},
        {'id': 9, 'created_time_stamp': '2025-01-19T10:00:03.000Z', 'tag': 'flutter'},
        // Record 4 tags (Meeting)
        {'id': 10, 'created_time_stamp': '2025-01-19T10:00:04.000Z', 'tag': 'meeting'},
        {'id': 11, 'created_time_stamp': '2025-01-19T10:00:04.000Z', 'tag': 'sprint'},
        {'id': 12, 'created_time_stamp': '2025-01-19T10:00:04.000Z', 'tag': 'planning'},
        // Record 5 tags (Code Review)
        {'id': 13, 'created_time_stamp': '2025-01-19T10:00:05.000Z', 'tag': 'code-review'},
        {'id': 14, 'created_time_stamp': '2025-01-19T10:00:05.000Z', 'tag': 'development'},
        {'id': 15, 'created_time_stamp': '2025-01-19T10:00:05.000Z', 'tag': 'checklist'},
      ];

  // ---------------------------------------------------------------------------
  // Tag usage statistics (for analytics demo)
  // ---------------------------------------------------------------------------
  static List<Map<String, Object?>> get tagUsageStats => [
        {'tag': 'flutter', 'count': 3},
        {'tag': 'project-alpha', 'count': 1},
        {'tag': 'parent', 'count': 1},
        {'tag': 'tech', 'count': 1},
        {'tag': 'mobile', 'count': 1},
        {'tag': 'architecture', 'count': 1},
        {'tag': 'bloc', 'count': 1},
        {'tag': 'meeting', 'count': 1},
        {'tag': 'sprint', 'count': 1},
        {'tag': 'planning', 'count': 1},
        {'tag': 'code-review', 'count': 1},
        {'tag': 'development', 'count': 1},
        {'tag': 'checklist', 'count': 1},
      ];
}

// =============================================================================
// Use Cases
// =============================================================================

/// Shows the since_when_tags junction table structure and data.
@widgetbook.UseCase(name: 'Tags Table View', type: SinceWhenDatabase)
Widget tagsTableView(BuildContext context) {
  return const _TagsTableDemo();
}

/// Shows PRAGMA data for since_when tables.
@widgetbook.UseCase(name: 'Pragma Data', type: SinceWhenDatabase)
Widget pragmaDataView(BuildContext context) {
  return const _PragmaDataDemo();
}

/// Full SqliteViewerPage integration with since_when mock data.
@widgetbook.UseCase(name: 'SqliteViewer Integration', type: SinceWhenDatabase)
Widget sqliteViewerIntegration(BuildContext context) {
  final showRowNumbers = context.knobs.boolean(
    label: 'Show Row Numbers',
    initialValue: true,
  );

  final sidebarWidth = context.knobs.double.slider(
    label: 'Sidebar Width',
    initialValue: 280,
    min: 200,
    max: 400,
  );

  return _SqliteViewerDemo(
    showRowNumbers: showRowNumbers,
    sidebarWidth: sidebarWidth,
  );
}

/// Shows the since_when main table with SqliteViewerTableDetail.
@widgetbook.UseCase(name: 'Main Table Detail', type: SinceWhenDatabase)
Widget mainTableDetail(BuildContext context) {
  final showRowNumbers = context.knobs.boolean(
    label: 'Show Row Numbers',
    initialValue: true,
  );

  final textHandling = context.knobs.list<TextHandling>(
    label: 'Text Handling',
    options: TextHandling.values,
    initialOption: TextHandling.trunc,
    labelBuilder: (value) => value.name,
  );

  return _MainTableDetailDemo(
    showRowNumbers: showRowNumbers,
    textHandling: textHandling,
  );
}

/// Shows tag usage analytics.
@widgetbook.UseCase(name: 'Tag Analytics', type: SinceWhenDatabase)
Widget tagAnalytics(BuildContext context) {
  return const _TagAnalyticsDemo();
}

// =============================================================================
// Demo Widgets
// =============================================================================

class _TagsTableDemo extends StatelessWidget {
  const _TagsTableDemo();

  @override
  Widget build(BuildContext context) {
    final columns = ['id', 'created_time_stamp', 'tag'];
    final rows = _MockDatabaseMetadata.tagsRows;

    return Scaffold(
      appBar: AppBar(
        title: const Text('since_when_tags Table'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTableInfoDialog(context),
            tooltip: 'Table Info',
          ),
        ],
      ),
      body: Column(
        children: [
          // Schema info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Junction Table: Many-to-Many Tag Relationships',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Each row links a record (via created_time_stamp) to a tag. '
                  'Tags shared by multiple records appear multiple times.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          // Foreign key indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Row(
              children: [
                const Icon(Icons.link, size: 16),
                const SizedBox(width: 8),
                Text(
                  'FK: created_time_stamp → since_when.createdTimeStamp (ON DELETE CASCADE)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          // Row count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              '${rows.length} rows',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          // Data table
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: columns
                      .map((col) => DataColumn(
                            label: Text(
                              col,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  rows: rows.map((row) {
                    return DataRow(
                      cells: columns.map((col) {
                        final value = row[col];
                        return DataCell(
                          Text(
                            value?.toString() ?? 'NULL',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: value == null ? Colors.grey : null,
                              fontStyle:
                                  value == null ? FontStyle.italic : null,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTableInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PRAGMA table_info(since_when_tags)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _MockDatabaseMetadata.tagsTableInfo.map((col) {
              return ListTile(
                dense: true,
                title: Text(
                  col['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${col['type']} ${col['notnull'] == 1 ? 'NOT NULL' : ''} '
                  '${col['pk'] == 1 ? 'PRIMARY KEY' : ''}',
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _PragmaDataDemo extends StatefulWidget {
  const _PragmaDataDemo();

  @override
  State<_PragmaDataDemo> createState() => _PragmaDataDemoState();
}

class _PragmaDataDemoState extends State<_PragmaDataDemo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTable = 'since_when';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRAGMA Data'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'table_info'),
            Tab(text: 'index_list'),
            Tab(text: 'foreign_key_list'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Table selector
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Table: '),
                const SizedBox(width: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'since_when', label: Text('since_when')),
                    ButtonSegment(value: 'since_when_tags', label: Text('since_when_tags')),
                  ],
                  selected: {_selectedTable},
                  onSelectionChanged: (selection) {
                    setState(() => _selectedTable = selection.first);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTableInfoTab(),
                _buildIndexListTab(),
                _buildForeignKeyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableInfoTab() {
    final info = _selectedTable == 'since_when'
        ? _MockDatabaseMetadata.sinceWhenTableInfo
        : _MockDatabaseMetadata.tagsTableInfo;

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _PragmaCard(
          title: 'PRAGMA table_info($_selectedTable)',
          child: _buildPragmaTable(
            columns: ['cid', 'name', 'type', 'notnull', 'dflt_value', 'pk'],
            rows: info,
          ),
        ),
      ],
    );
  }

  Widget _buildIndexListTab() {
    final indexes = _selectedTable == 'since_when'
        ? _MockDatabaseMetadata.sinceWhenIndexList
        : _MockDatabaseMetadata.tagsIndexList;

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _PragmaCard(
          title: 'PRAGMA index_list($_selectedTable)',
          child: _buildPragmaTable(
            columns: ['seq', 'name', 'unique', 'origin', 'partial'],
            rows: indexes,
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Index Origin Codes',
          children: const [
            _InfoRow('c', 'CREATE INDEX statement'),
            _InfoRow('u', 'UNIQUE constraint'),
            _InfoRow('pk', 'PRIMARY KEY constraint'),
          ],
        ),
      ],
    );
  }

  Widget _buildForeignKeyTab() {
    final fks = _selectedTable == 'since_when'
        ? <Map<String, Object?>>[]
        : _MockDatabaseMetadata.tagsForeignKeys;

    if (fks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No foreign keys on $_selectedTable',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _PragmaCard(
          title: 'PRAGMA foreign_key_list($_selectedTable)',
          child: _buildPragmaTable(
            columns: ['id', 'table', 'from', 'to', 'on_delete'],
            rows: fks,
          ),
        ),
      ],
    );
  }

  Widget _buildPragmaTable({
    required List<String> columns,
    required List<Map<String, Object?>> rows,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: columns
            .map((col) => DataColumn(
                  label: Text(
                    col,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ))
            .toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: columns.map((col) {
              final value = row[col];
              return DataCell(
                Text(
                  value?.toString() ?? 'NULL',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: value == null ? Colors.grey : null,
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _SqliteViewerDemo extends StatelessWidget {
  const _SqliteViewerDemo({
    required this.showRowNumbers,
    required this.sidebarWidth,
  });

  final bool showRowNumbers;
  final double sidebarWidth;

  @override
  Widget build(BuildContext context) {
    // Note: On web, we can't use real SqliteViewerPage since sqflite doesn't work.
    // This demonstrates the layout and components with mock data.

    return Scaffold(
      appBar: AppBar(
        title: const Text('SqliteViewer + SinceWhen'),
      ),
      body: Row(
        children: [
          // Sidebar - Metadata Panel
          SizedBox(
            width: sidebarWidth,
            child: _MockMetadataPanel(
              onTableSelected: (tableName) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: $tableName')),
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          // Main content - Table Detail
          Expanded(
            child: SqliteViewerTableDetail(
              tableName: 'since_when',
              columns: const [
                'id',
                'createdTimeStamp',
                'parentTimeStamp',
                'metaData',
                'category',
                'sequenceNumber',
              ],
              tableInfo: _MockDatabaseMetadata.sinceWhenTableInfo,
              indexList: _MockDatabaseMetadata.sinceWhenIndexList,
              foreignKeys: const [],
              rows: _MockDatabaseMetadata.sinceWhenRows,
              rowCount: _MockDatabaseMetadata.sinceWhenRows.length,
              showRowNumbers: showRowNumbers,
              nullValueDisplay: 'NULL',
              textHandling: TextHandling.trunc,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockMetadataPanel extends StatefulWidget {
  const _MockMetadataPanel({required this.onTableSelected});

  final ValueChanged<String> onTableSelected;

  @override
  State<_MockMetadataPanel> createState() => _MockMetadataPanelState();
}

class _MockMetadataPanelState extends State<_MockMetadataPanel> {
  String? _selectedTable = 'since_when';

  @override
  Widget build(BuildContext context) {
    final metadata = _MockDatabaseMetadata.metadata;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(Icons.memory, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'In-Memory Database',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: colorScheme.onPrimaryContainer),
                  onPressed: () {},
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          // Database info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetadataRow('SQLite', metadata.sqliteVersion),
                _MetadataRow('Size', '${(metadata.databaseSize / 1024).toStringAsFixed(1)} KB'),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tables header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Text(
              'TABLES (${metadata.tables.length})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          // Table list
          Expanded(
            child: ListView.builder(
              itemCount: metadata.tables.length,
              itemBuilder: (context, index) {
                final table = metadata.tables[index];
                final isSelected = table.name == _selectedTable;

                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: colorScheme.primaryContainer,
                  leading: Icon(
                    Icons.table_chart,
                    size: 20,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    table.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    '${table.rowCount} rows',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedTable = table.name);
                    widget.onTableSelected(table.name);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainTableDetailDemo extends StatelessWidget {
  const _MainTableDetailDemo({
    required this.showRowNumbers,
    required this.textHandling,
  });

  final bool showRowNumbers;
  final TextHandling textHandling;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('since_when Table Detail')),
      body: SqliteViewerTableDetail(
        tableName: 'since_when',
        columns: const [
          'id',
          'createdTimeStamp',
          'parentTimeStamp',
          'reviewedTimeStamp',
          'editedTimeStamp',
          'metaTimeStamp',
          'metaData',
          'sequenceNumber',
          'dataString',
          'category',
        ],
        tableInfo: _MockDatabaseMetadata.sinceWhenTableInfo,
        indexList: _MockDatabaseMetadata.sinceWhenIndexList,
        foreignKeys: const [],
        rows: _MockDatabaseMetadata.sinceWhenRows,
        rowCount: _MockDatabaseMetadata.sinceWhenRows.length,
        showRowNumbers: showRowNumbers,
        nullValueDisplay: 'NULL',
        textHandling: textHandling,
      ),
    );
  }
}

class _TagAnalyticsDemo extends StatelessWidget {
  const _TagAnalyticsDemo();

  @override
  Widget build(BuildContext context) {
    final stats = _MockDatabaseMetadata.tagUsageStats;
    final maxCount = stats
        .map((s) => s['count'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Tag Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            title: 'Tag Usage Statistics',
            children: [
              Text(
                'Query: SELECT tag, COUNT(*) as count FROM since_when_tags '
                'GROUP BY tag ORDER BY count DESC',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...stats.map((stat) {
            final tag = stat['tag'] as String;
            final count = stat['count'] as int;
            final percentage = count / maxCount;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$count',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          _InfoCard(
            title: 'Total',
            children: [
              _InfoRow(
                'Unique tags',
                '${stats.length}',
              ),
              _InfoRow(
                'Total tag assignments',
                '${stats.fold(0, (sum, s) => sum + (s['count'] as int))}',
              ),
              _InfoRow(
                'Records',
                '${_MockDatabaseMetadata.sinceWhenRows.length}',
              ),
              _InfoRow(
                'Avg tags per record',
                (stats.fold(0, (sum, s) => sum + (s['count'] as int)) /
                        _MockDatabaseMetadata.sinceWhenRows.length)
                    .toStringAsFixed(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _PragmaCard extends StatelessWidget {
  const _PragmaCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

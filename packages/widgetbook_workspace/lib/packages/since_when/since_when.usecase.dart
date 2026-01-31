// lib/package/since_when/since_when.usecase.dart

import 'package:flutter/material.dart';
import 'package:since_when/since_when.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Mock Data Generator - Creates sample records for Widgetbook demos
// =============================================================================

class _MockDataGenerator {
  _MockDataGenerator._();

  static int _idCounter = 1;
  static int _timestampCounter = 0;

  static String _generateTimestamp() {
    _timestampCounter++;
    final now = DateTime.utc(2025, 1, 19, 10, 0, 0).add(
      Duration(seconds: _timestampCounter),
    );
    return now.toIso8601String();
  }

  static SinceWhenRecord createRecord({
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tags,
    String? parentTimeStamp,
    int sequenceNumber = 0,
  }) {
    final timestamp = _generateTimestamp();
    return SinceWhenRecord(
      id: _idCounter++,
      createdTimeStamp: timestamp,
      reviewedTimeStamp: timestamp,
      editedTimeStamp: timestamp,
      metaData: metaData,
      dataString: dataString,
      category: category,
      tags: tags,
      parentTimeStamp: parentTimeStamp,
      sequenceNumber: sequenceNumber,
    );
  }

  static void reset() {
    _idCounter = 1;
    _timestampCounter = 0;
  }
}

// =============================================================================
// Use Cases
// =============================================================================

/// Demonstrates creating and displaying SinceWhenRecord entries.
@widgetbook.UseCase(name: 'Record Creation Demo', type: SinceWhenRecord)
Widget sinceWhenRecordCreation(BuildContext context) {
  return const _RecordCreationDemo();
}

/// Demonstrates hierarchical parent-child record relationships.
@widgetbook.UseCase(name: 'Hierarchical Records', type: SinceWhenRecord)
Widget sinceWhenHierarchical(BuildContext context) {
  return const _HierarchicalRecordsDemo();
}

/// Demonstrates tag filtering with TagMatchMode (Any/All).
@widgetbook.UseCase(name: 'Tags Demo', type: SinceWhenRecord)
Widget sinceWhenTags(BuildContext context) {
  return const _TagsDemo();
}

/// Displays database table information.
@widgetbook.UseCase(name: 'Table Info', type: TableInfo)
Widget sinceWhenTableInfo(BuildContext context) {
  return const _TableInfoDemo();
}

/// Interactive playground for creating custom records.
@widgetbook.UseCase(name: 'Interactive Playground', type: SinceWhenRecord)
Widget sinceWhenPlayground(BuildContext context) {
  final metaData = context.knobs.string(
    label: 'MetaData',
    initialValue: 'My custom record',
  );

  final dataString = context.knobs.string(
    label: 'Data String',
    initialValue: 'This is the content of the record...',
  );

  final category = context.knobs.list<String>(
    label: 'Category',
    options: ['notes', 'ideas', 'tasks', 'decisions', 'questions'],
    initialOption: 'notes',
  );

  final tagOptions = context.knobs.list<String>(
    label: 'Tags Preset',
    options: [
      'personal',
      'work',
      'urgent',
      'personal, ideas',
      'work, urgent',
      'none',
    ],
    initialOption: 'personal',
  );

  return _PlaygroundDemo(
    metaData: metaData,
    dataString: dataString,
    category: category,
    tagsPreset: tagOptions,
  );
}

/// Demonstrates SinceWhenFailure types.
@widgetbook.UseCase(name: 'Failure Types', type: SinceWhenFailure)
Widget sinceWhenFailures(BuildContext context) {
  return const _FailureTypesDemo();
}

/// Demonstrates TagMatchMode enum.
@widgetbook.UseCase(name: 'TagMatchMode', type: TagMatchMode)
Widget tagMatchModeDemo(BuildContext context) {
  return const _TagMatchModeDemo();
}

// =============================================================================
// Demo Widgets
// =============================================================================

class _RecordCreationDemo extends StatefulWidget {
  const _RecordCreationDemo();

  @override
  State<_RecordCreationDemo> createState() => _RecordCreationDemoState();
}

class _RecordCreationDemoState extends State<_RecordCreationDemo> {
  List<SinceWhenRecord> _records = [];
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeRecords();
  }

  void _initializeRecords() {
    _MockDataGenerator.reset();

    _records = [
      _MockDataGenerator.createRecord(
        metaData: 'First meeting notes',
        dataString: 'Discussed project timeline and milestones.\n'
            'Key decisions made:\n'
            '- Launch date: Q2 2025\n'
            '- Budget approved',
        category: 'meetings',
        tags: ['work', 'project-alpha'],
      ),
      _MockDataGenerator.createRecord(
        metaData: 'Code review feedback',
        dataString: 'Review of PR #423:\n'
            '- Clean architecture implementation looks good\n'
            '- Consider adding more unit tests\n'
            '- Documentation needs update',
        category: 'development',
        tags: ['code-review', 'pr-feedback'],
      ),
      _MockDataGenerator.createRecord(
        metaData: 'Personal reminder',
        dataString: 'Remember to schedule dentist appointment.',
        category: 'personal',
        tags: ['health', 'todo'],
      ),
    ];

    setState(() {
      _status = 'Created ${_records.length} records (mock data)';
    });
  }

  void _addNewRecord() {
    final newRecord = _MockDataGenerator.createRecord(
      metaData: 'New record #${_records.length + 1}',
      dataString: 'Dynamically created record content.',
      category: 'dynamic',
      tags: ['auto-generated'],
    );

    setState(() {
      _records.add(newRecord);
      _status = 'Added record #${_records.length}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Creation Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewRecord,
            tooltip: 'Add Record',
          ),
        ],
      ),
      body: Column(
        children: [
          _StatusBar(status: _status),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                return _RecordCard(record: _records[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HierarchicalRecordsDemo extends StatefulWidget {
  const _HierarchicalRecordsDemo();

  @override
  State<_HierarchicalRecordsDemo> createState() =>
      _HierarchicalRecordsDemoState();
}

class _HierarchicalRecordsDemoState extends State<_HierarchicalRecordsDemo> {
  SinceWhenRecord? _parentRecord;
  List<SinceWhenRecord> _childRecords = [];
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeHierarchy();
  }

  void _initializeHierarchy() {
    _MockDataGenerator.reset();

    // Create parent record
    _parentRecord = _MockDataGenerator.createRecord(
      metaData: 'Project Alpha - Main Entry',
      dataString: 'This is the parent record for Project Alpha.\n'
          'All related decisions and notes are linked as children.',
      category: 'project',
      tags: ['project-alpha', 'parent'],
    );

    // Create child records linked to parent
    _childRecords = [
      _MockDataGenerator.createRecord(
        metaData: 'Decision: Tech Stack',
        dataString: 'Decided to use Flutter for cross-platform development.',
        category: 'decision',
        tags: ['tech', 'flutter'],
        parentTimeStamp: _parentRecord!.createdTimeStamp,
        sequenceNumber: 1,
      ),
      _MockDataGenerator.createRecord(
        metaData: 'Decision: Architecture',
        dataString: 'Using Clean Architecture with BLoC pattern.',
        category: 'decision',
        tags: ['architecture', 'bloc'],
        parentTimeStamp: _parentRecord!.createdTimeStamp,
        sequenceNumber: 2,
      ),
      _MockDataGenerator.createRecord(
        metaData: 'Note: Timeline',
        dataString: 'MVP targeted for end of Q1.',
        category: 'note',
        tags: ['timeline', 'mvp'],
        parentTimeStamp: _parentRecord!.createdTimeStamp,
        sequenceNumber: 3,
      ),
    ];

    setState(() {
      _status = 'Parent + ${_childRecords.length} children (mock data)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hierarchical Records')),
      body: Column(
        children: [
          _StatusBar(status: _status),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                if (_parentRecord != null) ...[
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'PARENT RECORD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  _RecordCard(
                    record: _parentRecord!,
                    highlight: true,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'CHILD RECORDS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  ..._childRecords.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: _RecordCard(record: r),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagsDemo extends StatefulWidget {
  const _TagsDemo();

  @override
  State<_TagsDemo> createState() => _TagsDemoState();
}

class _TagsDemoState extends State<_TagsDemo> {
  List<SinceWhenRecord> _records = [];
  final Set<String> _selectedTags = {};
  TagMatchMode _matchMode = TagMatchMode.any;
  final _allTags = <String>{};

  @override
  void initState() {
    super.initState();
    _initializeWithTags();
  }

  void _initializeWithTags() {
    _MockDataGenerator.reset();

    final tagSets = [
      ['flutter', 'mobile', 'ui'],
      ['flutter', 'state-management', 'bloc'],
      ['dart', 'backend', 'server'],
      ['testing', 'unit-tests', 'flutter'],
      ['design', 'ui', 'ux'],
      ['database', 'sqlite', 'dart'],
      ['flutter', 'dart', 'ui'],
      ['mobile', 'ios', 'swift'],
    ];

    _records = [];
    for (var i = 0; i < tagSets.length; i++) {
      final record = _MockDataGenerator.createRecord(
        metaData: 'Record ${i + 1} - ${tagSets[i].first}',
        dataString: 'Content tagged with: ${tagSets[i].join(", ")}',
        category: 'demo',
        tags: tagSets[i],
      );
      _records.add(record);
      _allTags.addAll(tagSets[i]);
    }

    setState(() {});
  }

  /// Mimics the real SinceWhenDatabase.getByTags() behavior
  List<SinceWhenRecord> _getFilteredRecords() {
    if (_selectedTags.isEmpty) return _records;

    return _records.where((record) {
      if (_matchMode == TagMatchMode.any) {
        // ANY: record has at least one of the selected tags
        return _selectedTags.any((tag) => record.tags.contains(tag));
      } else {
        // ALL: record has all of the selected tags
        return _selectedTags.every((tag) => record.tags.contains(tag));
      }
    }).toList();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _clearTags() {
    setState(() {
      _selectedTags.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();
    final sortedTags = _allTags.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags Demo'),
        actions: [
          if (_selectedTags.isNotEmpty)
            TextButton.icon(
              onPressed: _clearTags,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          // API Reference Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              'db.getByTags([${_selectedTags.map((t) => "'$t'").join(", ")}], '
              'mode: TagMatchMode.${_matchMode.name})',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          // Match Mode Radio Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Match Mode:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Radio<TagMatchMode>(
                  value: TagMatchMode.any,
                  groupValue: _matchMode,
                  onChanged: (value) => setState(() => _matchMode = value!),
                ),
                GestureDetector(
                  onTap: () => setState(() => _matchMode = TagMatchMode.any),
                  child: const Text('Any'),
                ),
                const SizedBox(width: 24),
                Radio<TagMatchMode>(
                  value: TagMatchMode.all,
                  groupValue: _matchMode,
                  onChanged: (value) => setState(() => _matchMode = value!),
                ),
                GestureDetector(
                  onTap: () => setState(() => _matchMode = TagMatchMode.all),
                  child: const Text('All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tag Selection Chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: sortedTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (_) => _toggleTag(tag),
                  showCheckmark: true,
                );
              }).toList(),
            ),
          ),
          // Selected Tags Display
          if (_selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Selected: ${_selectedTags.join(", ")}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Results Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              _selectedTags.isEmpty
                  ? 'Showing all ${_records.length} records'
                  : 'Found ${filteredRecords.length} of ${_records.length} records '
                      'matching ${_matchMode == TagMatchMode.any ? "ANY" : "ALL"} '
                      'of ${_selectedTags.length} selected tag(s)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          // Results
          Expanded(
            child: filteredRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No records match '
                          '${_matchMode == TagMatchMode.all ? "ALL" : "ANY"} '
                          'of the selected tags',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try selecting fewer tags or switch to "Any" mode',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      return _RecordCard(
                        record: filteredRecords[index],
                        highlightTags: _selectedTags,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TableInfoDemo extends StatelessWidget {
  const _TableInfoDemo();

  @override
  Widget build(BuildContext context) {
    // Mock table info data
    final tables = [
      const TableInfo(tableName: 'since_when', rowCount: 42),
      const TableInfo(tableName: 'since_when_tags', rowCount: 128),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Database Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            title: 'Database Metadata (Mock)',
            children: [
              _InfoRow('Path', ':memory: (in-memory)'),
              _InfoRow('SQLite Version', '3.39.0'),
              _InfoRow('Size', '48 KB'),
              _InfoRow('Is In-Memory', 'true'),
              _InfoRow('Is Open', 'true'),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Tables (${tables.length})',
            children: tables
                .map((t) => _InfoRow(t.tableName, '${t.rowCount} rows'))
                .toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: This is mock data for Widgetbook demo. '
                    'Real database operations require native platform.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo({
    required this.metaData,
    required this.dataString,
    required this.category,
    required this.tagsPreset,
  });

  final String metaData;
  final String dataString;
  final String category;
  final String tagsPreset;

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  SinceWhenRecord? _createdRecord;
  String _status = 'Configure and tap Create';

  List<String> get _tags {
    if (widget.tagsPreset == 'none') return [];
    return widget.tagsPreset.split(', ').map((t) => t.trim()).toList();
  }

  void _createRecord() {
    final record = _MockDataGenerator.createRecord(
      metaData: widget.metaData,
      dataString: widget.dataString,
      category: widget.category,
      tags: _tags,
    );

    setState(() {
      _createdRecord = record;
      _status = 'Record created successfully! (mock data)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playground')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            title: 'Input Preview',
            children: [
              _InfoRow('MetaData', widget.metaData),
              _InfoRow('Category', widget.category),
              _InfoRow('Tags', _tags.isEmpty ? '(none)' : _tags.join(', ')),
              _InfoRow('Data Length', '${widget.dataString.length} chars'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _createRecord,
            icon: const Icon(Icons.add),
            label: const Text('Create Record'),
          ),
          const SizedBox(height: 16),
          _StatusBar(status: _status),
          const SizedBox(height: 16),
          if (_createdRecord != null) ...[
            const Text(
              'CREATED RECORD:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _RecordCard(record: _createdRecord!, highlight: true),
          ],
        ],
      ),
    );
  }
}

class _FailureTypesDemo extends StatelessWidget {
  const _FailureTypesDemo();

  @override
  Widget build(BuildContext context) {
    final failures = <SinceWhenFailure>[
      const DatabaseNotInitialized(),
      const RecordNotFound('2025-01-19T10:30:00.000Z'),
      const ParentNotFound('2025-01-19T09:00:00.000Z'),
      const TimestampCollisionRetryExhausted(),
      const ReservedDatabaseName(),
      const FileNotFound('/path/to/missing/file.json'),
      const InvalidJsonFormat('Unexpected token at position 42'),
      const ExportFailed('Permission denied', 'IOException'),
      const ImportFailed('File corrupted', 'FormatException'),
      const UnexpectedDatabaseError('Connection lost', 'SocketException'),
      const InvalidDatabaseName('Name contains invalid characters'),
      const DatabaseAlreadyInitialized('Instance already exists'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Failure Types')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: failures.length,
        itemBuilder: (context, index) {
          final failure = failures[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: Text(
                failure.runtimeType.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                failure.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TagMatchModeDemo extends StatelessWidget {
  const _TagMatchModeDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TagMatchMode Enum')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            title: 'TagMatchMode.any',
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Returns records that have at least one of the specified tags.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "db.getByTags(['flutter', 'dart'], mode: TagMatchMode.any)\n"
                  '// Returns records with flutter OR dart (or both)',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'TagMatchMode.all',
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Returns records that have all of the specified tags.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "db.getByTags(['flutter', 'dart'], mode: TagMatchMode.all)\n"
                  '// Returns records with BOTH flutter AND dart',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'SQL Implementation',
            children: [
              const Text(
                'ANY mode uses:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'WHERE tag IN (?, ?, ...)',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const Text(
                'ALL mode uses:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'WHERE (SELECT COUNT(DISTINCT tag) ... ) = ?',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
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

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    this.highlight = false,
    this.highlightTags = const {},
  });

  final SinceWhenRecord record;
  final bool highlight;
  final Set<String> highlightTags;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: highlight
          ? Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.metaData,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              record.dataString,
              style: const TextStyle(fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (record.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: record.tags.map((tag) {
                  final isHighlighted = highlightTags.contains(tag);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isHighlighted ? FontWeight.bold : FontWeight.normal,
                        color: isHighlighted
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            Text(
              'Created: ${record.createdTimeStamp}',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            if (record.parentTimeStamp != null)
              Text(
                'Parent: ${record.parentTimeStamp}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            Text(
              'Seq: ${record.sequenceNumber} | ID: ${record.id}',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
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
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

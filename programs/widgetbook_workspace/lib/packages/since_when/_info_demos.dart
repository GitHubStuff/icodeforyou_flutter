// lib/package/since_when/_info_demos.dart

import 'package:flutter/material.dart';
import 'package:since_when/since_when.dart';

import '_mock_data.dart';
import '_shared_widgets.dart';

/// Table info demo widget.
class TableInfoDemo extends StatelessWidget {
  const TableInfoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tables = [
      const TableInfo(tableName: 'since_when', rowCount: 42),
      const TableInfo(tableName: 'since_when_tag_glossary', rowCount: 15),
      const TableInfo(tableName: 'since_when_tags', rowCount: 128),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Database Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            title: 'Database Metadata (Mock)',
            children: [
              InfoRow('Path', ':memory:'),
              InfoRow('SQLite Version', '3.39.0'),
              InfoRow('Size', '48 KB'),
            ],
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Tables (${tables.length})',
            children: tables.map((t) => InfoRow(t.tableName, '${t.rowCount} rows')).toList(),
          ),
        ],
      ),
    );
  }
}

/// Playground demo widget.
class PlaygroundDemo extends StatefulWidget {
  const PlaygroundDemo({
    super.key,
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
  State<PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<PlaygroundDemo> {
  SinceWhenRecord? _createdRecord;
  String _status = 'Configure and tap Create';

  List<String> get _tagNames {
    if (widget.tagsPreset == 'none') return [];
    return widget.tagsPreset.split(', ').map((t) => t.trim()).toList();
  }

  void _createRecord() {
    final record = MockDataGenerator.createRecord(
      metaData: widget.metaData,
      dataString: widget.dataString,
      category: widget.category,
      tagNames: _tagNames,
    );
    setState(() {
      _createdRecord = record;
      _status = 'Record created successfully!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playground')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            title: 'Input Preview',
            children: [
              InfoRow('MetaData', widget.metaData),
              InfoRow('Category', widget.category),
              InfoRow('Tags', _tagNames.isEmpty ? '(none)' : _tagNames.join(', ')),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _createRecord,
            icon: const Icon(Icons.add),
            label: const Text('Create Record'),
          ),
          const SizedBox(height: 16),
          StatusBar(status: _status),
          if (_createdRecord != null) ...[
            const SizedBox(height: 16),
            RecordCard(record: _createdRecord!, highlight: true),
          ],
        ],
      ),
    );
  }
}

/// Failure types demo widget.
class FailureTypesDemo extends StatelessWidget {
  const FailureTypesDemo({super.key});

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
      const ExportFailed('Permission denied'),
      const ImportFailed('File corrupted'),
      const UnexpectedDatabaseError('Connection lost'),
      const InvalidDatabaseName('Invalid characters'),
      const DatabaseAlreadyInitialized('Instance exists'),
      const TagNotFound('non-existent-tag'),
      const TagNameAlreadyExists('flutter'),
      const InvalidTagName('Tag name cannot be empty'),
      const TagInUse('flutter', 5),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Failure Types')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: failures.length,
        itemBuilder: (_, i) {
          final f = failures[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: Text(f.runtimeType.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(f.toString(), style: const TextStyle(fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}

/// TagMatchMode demo widget.
class TagMatchModeDemo extends StatelessWidget {
  const TagMatchModeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TagMatchMode Enum')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            title: 'TagMatchMode.any',
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Returns records that have at least one of the specified tags.'),
              ),
              CodeBlock(
                "db.getByTagNames(['flutter', 'dart'], mode: TagMatchMode.any)\n"
                '// Returns records with flutter OR dart (or both)',
              ),
            ],
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'TagMatchMode.all',
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Returns records that have all of the specified tags.'),
              ),
              CodeBlock(
                "db.getByTagNames(['flutter', 'dart'], mode: TagMatchMode.all)\n"
                '// Returns records with BOTH flutter AND dart',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// lib/package/since_when/_record_demos.dart

import 'package:flutter/material.dart';
import 'package:since_when/since_when.dart';

import '_mock_data.dart';
import '_shared_widgets.dart';

/// Record creation demo widget.
class RecordCreationDemo extends StatefulWidget {
  const RecordCreationDemo({super.key});

  @override
  State<RecordCreationDemo> createState() => _RecordCreationDemoState();
}

class _RecordCreationDemoState extends State<RecordCreationDemo> {
  List<SinceWhenRecord> _records = [];
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeRecords();
  }

  void _initializeRecords() {
    MockDataGenerator.reset();
    _records = [
      MockDataGenerator.createRecord(
        metaData: 'First meeting notes',
        dataString: 'Discussed project timeline and milestones.\n'
            'Key decisions made:\n- Launch date: Q2 2025\n- Budget approved',
        category: 'meetings',
        tagNames: ['work', 'project-alpha'],
      ),
      MockDataGenerator.createRecord(
        metaData: 'Code review feedback',
        dataString: 'Review of PR #423:\n- Clean architecture looks good\n'
            '- Consider adding more unit tests',
        category: 'development',
        tagNames: ['code-review', 'pr-feedback'],
      ),
      MockDataGenerator.createRecord(
        metaData: 'Personal reminder',
        dataString: 'Remember to schedule dentist appointment.',
        category: 'personal',
        tagNames: ['health', 'todo'],
      ),
    ];
    setState(() => _status = 'Created ${_records.length} records (mock data)');
  }

  void _addNewRecord() {
    final newRecord = MockDataGenerator.createRecord(
      metaData: 'New record #${_records.length + 1}',
      dataString: 'Dynamically created record content.',
      category: 'dynamic',
      tagNames: ['auto-generated'],
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
          IconButton(icon: const Icon(Icons.add), onPressed: _addNewRecord),
        ],
      ),
      body: Column(
        children: [
          StatusBar(status: _status),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _records.length,
              itemBuilder: (_, i) => RecordCard(record: _records[i]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hierarchical records demo widget.
class HierarchicalRecordsDemo extends StatefulWidget {
  const HierarchicalRecordsDemo({super.key});

  @override
  State<HierarchicalRecordsDemo> createState() => _HierarchicalRecordsDemoState();
}

class _HierarchicalRecordsDemoState extends State<HierarchicalRecordsDemo> {
  SinceWhenRecord? _parentRecord;
  List<SinceWhenRecord> _childRecords = [];
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeHierarchy();
  }

  void _initializeHierarchy() {
    MockDataGenerator.reset();
    _parentRecord = MockDataGenerator.createRecord(
      metaData: 'Project Alpha - Main Entry',
      dataString: 'This is the parent record for Project Alpha.\n'
          'All related decisions and notes are linked as children.',
      category: 'project',
      tagNames: ['project-alpha', 'parent'],
    );
    _childRecords = [
      MockDataGenerator.createRecord(
        metaData: 'Decision: Tech Stack',
        dataString: 'Decided to use Flutter for cross-platform development.',
        category: 'decision',
        tagNames: ['tech', 'flutter'],
        parentTimeStamp: _parentRecord!.createdTimeStamp,
        sequenceNumber: 1,
      ),
      MockDataGenerator.createRecord(
        metaData: 'Decision: Architecture',
        dataString: 'Using Clean Architecture with BLoC pattern.',
        category: 'decision',
        tagNames: ['architecture', 'bloc'],
        parentTimeStamp: _parentRecord!.createdTimeStamp,
        sequenceNumber: 2,
      ),
      MockDataGenerator.createRecord(
        metaData: 'Note: Timeline',
        dataString: 'MVP targeted for end of Q1.',
        category: 'note',
        tagNames: ['timeline', 'mvp'],
        parentTimeStamp: _parentRecord!.createdTimeStamp,
        sequenceNumber: 3,
      ),
    ];
    setState(() => _status = 'Parent + ${_childRecords.length} children');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hierarchical Records')),
      body: Column(
        children: [
          StatusBar(status: _status),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                if (_parentRecord != null) ...[
                  const _SectionLabel('PARENT RECORD', Colors.blue),
                  RecordCard(record: _parentRecord!, highlight: true),
                  const _SectionLabel('CHILD RECORDS', Colors.green),
                  ..._childRecords.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: RecordCard(record: r),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    );
  }
}

// lib/package/since_when/_tag_demos.dart

import 'package:flutter/material.dart';
import 'package:since_when/since_when.dart';

import 'package:widgetbook_workspace/packages/since_when/_mock_data.dart';
import 'package:widgetbook_workspace/packages/since_when/_shared_widgets.dart';

/// Tags filtering demo widget.
class TagsDemo extends StatefulWidget {
  const TagsDemo({super.key});

  @override
  State<TagsDemo> createState() => _TagsDemoState();
}

class _TagsDemoState extends State<TagsDemo> {
  List<SinceWhenRecord> _records = [];
  final Set<String> _selectedTagNames = {};
  TagMatchMode _matchMode = TagMatchMode.any;
  final _allTagNames = <String>{};

  @override
  void initState() {
    super.initState();
    _initializeWithTags();
  }

  void _initializeWithTags() {
    MockDataGenerator.reset();
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
      final record = MockDataGenerator.createRecord(
        metaData: 'Record ${i + 1} - ${tagSets[i].first}',
        dataString: 'Content tagged with: ${tagSets[i].join(", ")}',
        category: 'demo',
        tagNames: tagSets[i],
      );
      _records.add(record);
      _allTagNames.addAll(tagSets[i]);
    }
    setState(() {});
  }

  List<SinceWhenRecord> _getFilteredRecords() {
    if (_selectedTagNames.isEmpty) return _records;
    return _records.where((record) {
      final recordTagNames = record.tags.map((t) => t.tagName).toSet();
      if (_matchMode == TagMatchMode.any) {
        return _selectedTagNames.any(recordTagNames.contains);
      } else {
        return _selectedTagNames.every(recordTagNames.contains);
      }
    }).toList();
  }

  void _toggleTag(String tagName) {
    setState(() {
      if (_selectedTagNames.contains(tagName)) {
        _selectedTagNames.remove(tagName);
      } else {
        _selectedTagNames.add(tagName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();
    final sortedTags = _allTagNames.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags Demo'),
        actions: [
          if (_selectedTagNames.isNotEmpty)
            TextButton.icon(
              onPressed: () => setState(_selectedTagNames.clear),
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          _ApiCallBanner(tagNames: _selectedTagNames, mode: _matchMode),
          _MatchModeSelector(
            mode: _matchMode,
            onChanged: (m) => setState(() => _matchMode = m),
          ),
          const Divider(height: 1),
          _TagSelector(
            tags: sortedTags,
            selected: _selectedTagNames,
            onToggle: _toggleTag,
          ),
          _ResultsHeader(
            total: _records.length,
            filtered: filteredRecords.length,
            mode: _matchMode,
            selectedCount: _selectedTagNames.length,
          ),
          Expanded(
            child: filteredRecords.isEmpty
                ? _EmptyState(mode: _matchMode)
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredRecords.length,
                    itemBuilder: (_, i) => RecordCard(
                      record: filteredRecords[i],
                      highlightTagNames: _selectedTagNames,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ApiCallBanner extends StatelessWidget {
  const _ApiCallBanner({required this.tagNames, required this.mode});
  final Set<String> tagNames;
  final TagMatchMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        'db.getByTagNames([${tagNames.map((t) => "'$t'").join(", ")}], '
        'mode: TagMatchMode.${mode.name})',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _MatchModeSelector extends StatelessWidget {
  const _MatchModeSelector({required this.mode, required this.onChanged});
  final TagMatchMode mode;
  final ValueChanged<TagMatchMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Match Mode:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          SegmentedButton<TagMatchMode>(
            segments: const [
              ButtonSegment(value: TagMatchMode.any, label: Text('Any')),
              ButtonSegment(value: TagMatchMode.all, label: Text('All')),
            ],
            selected: {mode},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ],
      ),
    );
  }
}

class _TagSelector extends StatelessWidget {
  const _TagSelector({
    required this.tags,
    required this.selected,
    required this.onToggle,
  });
  final List<String> tags;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: tags.map((tag) {
          return FilterChip(
            label: Text(tag),
            selected: selected.contains(tag),
            onSelected: (_) => onToggle(tag),
            showCheckmark: true,
          );
        }).toList(),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.total,
    required this.filtered,
    required this.mode,
    required this.selectedCount,
  });
  final int total;
  final int filtered;
  final TagMatchMode mode;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final tagOrTags = 'of $selectedCount tag${selectedCount == 1} ? "" : "s"';
    final text = selectedCount == 0
        ? 'Showing all $total records'
        : 'Found $filtered of $total matching '
              '${mode == TagMatchMode.any ? "ANY" : "ALL"} $tagOrTags';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.mode});
  final TagMatchMode mode;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            'No records match ${mode == TagMatchMode.all ? "ALL" : "ANY"}'
            ' of the selected tags',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

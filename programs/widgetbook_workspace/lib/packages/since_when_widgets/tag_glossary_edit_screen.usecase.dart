// lib/packages/since_when_widgets/lib/src/tag_glossary_edit/tag_glossary_edit_screen.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gap/gap.dart';
import 'package:ice_chips/ice_chips.dart';
import 'package:since_when_widgets/since_when_widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: TagGlossaryEditScreen)
Widget tagGlossaryEditScreenUseCase(BuildContext context) {
  final mode = context.knobs.object.dropdown<_Mode>(
    label: 'mode',
    options: _Mode.values,
    initialOption: _Mode.create,
    labelBuilder: (m) => m.label,
  );

  return _EditShowcase(mode: mode);
}

enum _Mode {
  create('Create'),
  update('Update');

  const _Mode(this.label);

  final String label;
}

class _EditShowcase extends StatefulWidget {
  const _EditShowcase({required this.mode});

  final _Mode mode;

  @override
  State<_EditShowcase> createState() => _EditShowcaseState();
}

class _EditShowcaseState extends State<_EditShowcase> {
  final _store = _InMemoryGlossary._withSeed();
  String _lastEvent = '—';

  static const _seedExisting = RecordTagDefinition(
    id: 3,
    createdTimeStamp: 1700000000000,
    tagName: 'urgent',
    color: 0xFFF5A623,
  );

  @override
  Widget build(BuildContext context) {
    final screen = switch (widget.mode) {
      _Mode.create => TagGlossaryEditScreen.create(
        key: const ValueKey('create'),
        repository: _store,
        reader: _store,
        onSaved: (record) =>
            setState(() => _lastEvent = 'saved ${record.tagName}'),
        onDismiss: () => setState(() => _lastEvent = 'dismissed'),
      ),
      _Mode.update => TagGlossaryEditScreen.update(
        key: const ValueKey('update'),
        reader: _store,
        writer: _store,
        deleter: _store,
        existing: _seedExisting,
        onSaved: (record) =>
            setState(() => _lastEvent = 'saved ${record.tagName}'),
        onDeleted: (record) =>
            setState(() => _lastEvent = 'deleted ${record.tagName}'),
        onDismiss: () => setState(() => _lastEvent = 'dismissed'),
      ),
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'last event: $_lastEvent',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          const Gap(12),
          Expanded(child: screen),
        ],
      ),
    );
  }
}

/// In-memory fake implementing all four glossary roles.
class _InMemoryGlossary
    implements GlossaryReader, GlossaryRepository, GlossaryWriter, GlossaryDeleter {
  _InMemoryGlossary._withSeed() {
    _records.addAll([
      const RecordTagDefinition(
        id: 1,
        createdTimeStamp: 1700000000000,
        tagName: 'work',
        color: 0xFF4A90E2,
      ),
      const RecordTagDefinition(
        id: 2,
        createdTimeStamp: 1700000001000,
        tagName: 'home',
        color: 0xFFE94B3C,
      ),
      const RecordTagDefinition(
        id: 3,
        createdTimeStamp: 1700000002000,
        tagName: 'urgent',
        color: 0xFFF5A623,
      ),
    ]);
  }

  final List<RecordTagDefinition> _records = [];
  int _nextId = 4;

  @override
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
  fetchAllTagDefinitions() async => Right(List.unmodifiable(_records));

  @override
  Future<Either<SinceWhenFailure, RecordTagDefinition>> insertTagDefinition({
    required String tagName,
    required int color,
  }) async {
    final record = RecordTagDefinition(
      id: _nextId++,
      createdTimeStamp: DateTime.now().millisecondsSinceEpoch,
      tagName: tagName,
      color: color,
    );
    _records.add(record);
    return Right(record);
  }

  @override
  Future<Either<SinceWhenFailure, Unit>> updateTagDefinition(
    RecordTagDefinition record,
  ) async {
    final idx = _records.indexWhere((r) => r.id == record.id);
    if (idx >= 0) _records[idx] = record;
    return const Right(unit);
  }

  @override
  Future<Either<SinceWhenFailure, Unit>> deleteTagDefinition(int id) async {
    _records.removeWhere((r) => r.id == id);
    return const Right(unit);
  }
}

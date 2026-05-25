// widgetbook/lib/since_when_widgets/tag_glossary_edit/tag_glossary_edit_screen_update.usecase.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:ice_chips/ice_chips.dart'
    show
        GlossaryDeleter,
        GlossaryReader,
        GlossaryWriter,
        RecordTagDefinition,
        SinceWhenFailure;
import 'package:since_when_framework/database.dart'
    show DatabaseOpenFailure, DatabaseSetupFailure;
import 'package:since_when_widgets/since_when_widgets.dart'
    show TagGlossaryEditScreen;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Update', type: TagGlossaryEditScreen)
Widget tagGlossaryEditScreenUpdateUseCase(BuildContext context) {
  final preloadedColors = context.knobs.int.slider(
    label: 'Preloaded glossary entries',
    initialValue: 12,
    min: 1,
    max: 50,
  );

  final editIndex = context.knobs.int.slider(
    label: 'Edit which entry (0-based)',
    initialValue: 0,
    min: 0,
    max: 49,
  );

  final simulateDuplicateName = context.knobs.boolean(
    label: 'Simulate duplicate name on save',
  );

  final simulateInitFailure = context.knobs.boolean(
    label: 'Simulate fetch failure on init',
  );

  final simulateDeleteFailure = context.knobs.boolean(
    label: 'Simulate delete failure',
  );

  return _UpdateHost(
    preloadedColors: preloadedColors,
    editIndex: editIndex,
    simulateDuplicateName: simulateDuplicateName,
    simulateInitFailure: simulateInitFailure,
    simulateDeleteFailure: simulateDeleteFailure,
  );
}

class _UpdateHost extends StatefulWidget {
  const _UpdateHost({
    required this.preloadedColors,
    required this.editIndex,
    required this.simulateDuplicateName,
    required this.simulateInitFailure,
    required this.simulateDeleteFailure,
  });

  final int preloadedColors;
  final int editIndex;
  final bool simulateDuplicateName;
  final bool simulateInitFailure;
  final bool simulateDeleteFailure;

  @override
  State<_UpdateHost> createState() => _UpdateHostState();
}

class _UpdateHostState extends State<_UpdateHost> {
  RecordTagDefinition? _lastSaved;
  RecordTagDefinition? _lastDeleted;
  int _dismissCount = 0;
  Key _resetKey = UniqueKey();

  void _resetScreen() => setState(() {
    _lastSaved = null;
    _lastDeleted = null;
    _resetKey = UniqueKey();
  });

  @override
  Widget build(BuildContext context) {
    final fake = _FakeBackend(
      preloadedColors: widget.preloadedColors,
      simulateDuplicateName: widget.simulateDuplicateName,
      simulateInitFailure: widget.simulateInitFailure,
      simulateDeleteFailure: widget.simulateDeleteFailure,
    );

    // Clamp the edit index against the actual seeded list.
    final seeded = fake.seededRecords;
    final clampedIndex = widget.editIndex.clamp(0, seeded.length - 1);
    final existing = seeded[clampedIndex];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TagGlossaryEditScreen.update(
              key: _resetKey,
              reader: fake,
              writer: fake,
              deleter: fake,
              existing: existing,
              onSaved: (record) => setState(() => _lastSaved = record),
              onDeleted: (record) => setState(() => _lastDeleted = record),
              onDismiss: () => setState(() => _dismissCount++),
            ),
          ),
          const Divider(height: 1),
          _StatusPanel(
            existing: existing,
            lastSaved: _lastSaved,
            lastDeleted: _lastDeleted,
            dismissCount: _dismissCount,
            onReset: _resetScreen,
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.existing,
    required this.lastSaved,
    required this.lastDeleted,
    required this.dismissCount,
    required this.onReset,
  });

  final RecordTagDefinition existing;
  final RecordTagDefinition? lastSaved;
  final RecordTagDefinition? lastDeleted;
  final int dismissCount;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final saved = lastSaved;
    final deleted = lastDeleted;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Editing: "${existing.tagName}" (id=${existing.id})',
                  style: DefaultTextStyle.of(context).style,
                ),
                const SizedBox(height: 4),
                Text(
                  saved == null
                      ? 'No save yet'
                      : 'Saved: "${saved.tagName}" (id=${saved.id})',
                  style: DefaultTextStyle.of(context).style,
                ),
                const SizedBox(height: 4),
                Text(
                  deleted == null
                      ? 'No delete yet'
                      : 'Deleted: "${deleted.tagName}" (id=${deleted.id})',
                  style: DefaultTextStyle.of(context).style,
                ),
                const SizedBox(height: 4),
                Text(
                  'Dismiss taps: $dismissCount',
                  style: DefaultTextStyle.of(context).style,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// In-memory fake implementing the read + write + delete surfaces the
/// editor uses in Update mode.
class _FakeBackend implements GlossaryReader, GlossaryWriter, GlossaryDeleter {
  _FakeBackend({
    required this.preloadedColors,
    required this.simulateDuplicateName,
    required this.simulateInitFailure,
    required this.simulateDeleteFailure,
  });

  final int preloadedColors;
  final bool simulateDuplicateName;
  final bool simulateInitFailure;
  final bool simulateDeleteFailure;

  late final List<RecordTagDefinition> seededRecords = _buildSeed();

  @override
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
  fetchAllTagDefinitions() async {
    if (simulateInitFailure) {
      return Left(
        SinceWhenFailure(
          DatabaseOpenFailure(Exception('simulated fetch failure')),
        ),
      );
    }
    return Right(seededRecords);
  }

  @override
  Future<Either<SinceWhenFailure, Unit>> updateTagDefinition(
    RecordTagDefinition tag,
  ) async {
    if (simulateDuplicateName) {
      return Left(
        SinceWhenFailure(
          DatabaseSetupFailure(
            setupName: 'glossary',
            cause: Exception('duplicate tag name: ${tag.tagName}'),
          ),
        ),
      );
    }
    return const Right(unit);
  }

  @override
  Future<Either<SinceWhenFailure, Unit>> deleteTagDefinition(int id) async {
    if (simulateDeleteFailure) {
      return Left(
        SinceWhenFailure(
          DatabaseSetupFailure(
            setupName: 'glossary',
            cause: Exception('simulated delete failure on id=$id'),
          ),
        ),
      );
    }
    return const Right(unit);
  }

  List<RecordTagDefinition> _buildSeed() {
    // Deterministic spread of fully-opaque ARGB values across the hue wheel.
    final records = <RecordTagDefinition>[];
    for (var i = 0; i < preloadedColors; i++) {
      final r = (i * 37) & 0xFF;
      final g = (i * 67) & 0xFF;
      final b = (i * 97) & 0xFF;
      final color = 0xFF000000 | (r << 16) | (g << 8) | b;
      records.add(
        RecordTagDefinition(
          id: i + 1,
          createdTimeStamp: i * 1000,
          tagName: 'TAG${i + 1}',
          color: color,
        ),
      );
    }
    return records;
  }
}

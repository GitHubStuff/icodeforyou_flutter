// widgetbook/lib/since_when_widgets/tag_glossary_edit/tag_glossary_edit_screen_create.usecase.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:ice_chips/ice_chips.dart'
    show
        GlossaryDeleter,
        GlossaryReader,
        GlossaryRepository,
        GlossaryWriter,
        RecordTagDefinition,
        SinceWhenFailure;
import 'package:since_when_framework/database.dart'
    show DatabaseOpenFailure, DatabaseSetupFailure;
import 'package:since_when_widgets/since_when_widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Create', type: TagGlossaryEditScreen)
Widget tagGlossaryEditScreenCreateUseCase(BuildContext context) {
  final preloadedColors = context.knobs.int.slider(
    label: 'Pre-loaded glossary colors',
    initialValue: 3,
    min: 0,
    max: 50,
  );

  final simulateDuplicateName = context.knobs.boolean(
    label: 'Simulate duplicate-name failure on save',
  );

  final simulateInitFailure = context.knobs.boolean(
    label: 'Simulate fetch failure on init',
  );

  return _CreateHost(
    preloadedColors: preloadedColors,
    simulateDuplicateName: simulateDuplicateName,
    simulateInitFailure: simulateInitFailure,
  );
}

class _CreateHost extends StatefulWidget {
  const _CreateHost({
    required this.preloadedColors,
    required this.simulateDuplicateName,
    required this.simulateInitFailure,
  });

  final int preloadedColors;
  final bool simulateDuplicateName;
  final bool simulateInitFailure;

  @override
  State<_CreateHost> createState() => _CreateHostState();
}

class _CreateHostState extends State<_CreateHost> {
  RecordTagDefinition? _lastSaved;
  int _dismissCount = 0;
  Key _resetKey = UniqueKey();

  void _resetScreen() => setState(() {
    _lastSaved = null;
    _resetKey = UniqueKey();
  });

  @override
  Widget build(BuildContext context) {
    final fake = _FakeBackend(
      preloadedColors: widget.preloadedColors,
      simulateDuplicateName: widget.simulateDuplicateName,
      simulateInitFailure: widget.simulateInitFailure,
    );

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TagGlossaryEditScreen.create(
              key: _resetKey,
              repository: fake,
              reader: fake,
              onSaved: (record) => setState(() => _lastSaved = record),
              onDismiss: () => setState(() => _dismissCount++),
            ),
          ),
          const Divider(height: 1),
          _StatusPanel(
            lastSaved: _lastSaved,
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
    required this.lastSaved,
    required this.dismissCount,
    required this.onReset,
  });

  final RecordTagDefinition? lastSaved;
  final int dismissCount;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final saved = lastSaved;
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
                  saved == null
                      ? 'No save yet'
                      : 'Saved: "${saved.tagName}" (id=${saved.id})',
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

/// In-memory fake implementing every glossary interface the editor needs.
///
/// Implements all four role-segregated interfaces so the same fake can
/// back the Create usecase (uses `reader` + `repository`) and any future
/// Update usecase (which would also need `writer` + `deleter`).
class _FakeBackend
    implements
        GlossaryReader,
        GlossaryRepository,
        GlossaryWriter,
        GlossaryDeleter {
  _FakeBackend({
    required this.preloadedColors,
    required this.simulateDuplicateName,
    required this.simulateInitFailure,
  });

  final int preloadedColors;
  final bool simulateDuplicateName;
  final bool simulateInitFailure;

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
    return Right(_seededRecords());
  }

  @override
  Future<Either<SinceWhenFailure, RecordTagDefinition>> insertTagDefinition({
    required String tagName,
    required int color,
  }) async {
    if (simulateDuplicateName) {
      return Left(
        SinceWhenFailure(
          DatabaseSetupFailure(
            setupName: 'glossary',
            cause: Exception('duplicate tag name: $tagName'),
          ),
        ),
      );
    }
    return Right(
      RecordTagDefinition(
        id: preloadedColors + 1,
        createdTimeStamp: DateTime.now().millisecondsSinceEpoch,
        tagName: tagName,
        color: color,
      ),
    );
  }

  @override
  Future<Either<SinceWhenFailure, Unit>> updateTagDefinition(
    RecordTagDefinition tag,
  ) async {
    return const Right(unit);
  }

  @override
  Future<Either<SinceWhenFailure, Unit>> deleteTagDefinition(int id) async {
    return const Right(unit);
  }

  List<RecordTagDefinition> _seededRecords() {
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

// widgetbook/lib/since_when_widgets/tag_glossary_read/tag_glossary_read_view.usecase.dart

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:ice_chips/ice_chips.dart'
    show GlossaryReader, RecordTagDefinition, SinceWhenFailure;
import 'package:since_when_framework/database.dart' show DatabaseOpenFailure;
import 'package:since_when_widgets/since_when_widgets.dart'
    show TagGlossaryReadView;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ─── Default (interactive) ───────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Default', type: TagGlossaryReadView)
Widget tagGlossaryReadViewDefaultUseCase(BuildContext context) {
  final preloadedColors = context.knobs.int.slider(
    label: 'Seed entries',
    initialValue: 12,
    min: 0,
    max: 50,
  );

  return _InteractiveHost(preloadedColors: preloadedColors);
}

class _InteractiveHost extends StatefulWidget {
  const _InteractiveHost({required this.preloadedColors});

  final int preloadedColors;

  @override
  State<_InteractiveHost> createState() => _InteractiveHostState();
}

class _InteractiveHostState extends State<_InteractiveHost> {
  RecordTagDefinition? _lastTapped;
  int _refreshKey = 0;

  void _refresh() => setState(() => _refreshKey++);

  @override
  Widget build(BuildContext context) {
    final reader = _SeededReader(preloadedColors: widget.preloadedColors);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TagGlossaryReadView(
                reader: reader,
                refreshKey: _refreshKey,
                onTap: (record) => setState(() => _lastTapped = record),
              ),
            ),
          ),
          const Divider(height: 1),
          _TapStatusPanel(lastTapped: _lastTapped, onRefresh: _refresh),
        ],
      ),
    );
  }
}

class _TapStatusPanel extends StatelessWidget {
  const _TapStatusPanel({required this.lastTapped, required this.onRefresh});

  final RecordTagDefinition? lastTapped;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final tapped = lastTapped;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tapped == null
                  ? 'No chip tapped yet'
                  : 'Tapped: "${tapped.tagName}" (id=${tapped.id})',
              style: DefaultTextStyle.of(context).style,
            ),
          ),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

// ─── Loaded variant ──────────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Loaded', type: TagGlossaryReadView)
Widget tagGlossaryReadViewLoadedUseCase(BuildContext context) {
  final entries = context.knobs.int.slider(
    label: 'Entries',
    initialValue: 20,
    min: 1,
    max: 50,
  );

  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: TagGlossaryReadView(
        reader: _SeededReader(preloadedColors: entries),
      ),
    ),
  );
}

// ─── Loading variant ─────────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Loading', type: TagGlossaryReadView)
Widget tagGlossaryReadViewLoadingUseCase(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: TagGlossaryReadView(reader: _NeverResolvingReader()),
    ),
  );
}

// ─── Empty variant ───────────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Empty', type: TagGlossaryReadView)
Widget tagGlossaryReadViewEmptyUseCase(BuildContext context) {
  return const Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: TagGlossaryReadView(reader: _SeededReader(preloadedColors: 0)),
    ),
  );
}

// ─── Error variant ───────────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Error', type: TagGlossaryReadView)
Widget tagGlossaryReadViewErrorUseCase(BuildContext context) {
  return const Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: TagGlossaryReadView(reader: _FailingReader()),
    ),
  );
}

// ─── Fake readers ────────────────────────────────────────────────────────────

class _SeededReader implements GlossaryReader {
  const _SeededReader({required this.preloadedColors});

  final int preloadedColors;

  @override
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
  fetchAllTagDefinitions() async => Right(_buildSeed());

  List<RecordTagDefinition> _buildSeed() {
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

class _NeverResolvingReader implements GlossaryReader {
  _NeverResolvingReader();

  @override
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
  fetchAllTagDefinitions() =>
      Completer<Either<SinceWhenFailure, List<RecordTagDefinition>>>().future;
}

class _FailingReader implements GlossaryReader {
  const _FailingReader();

  @override
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
  fetchAllTagDefinitions() async => Left(
    SinceWhenFailure(
      DatabaseOpenFailure(Exception('simulated fetch failure')),
    ),
  );
}

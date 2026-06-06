// lib/packages/app_preferences/src/mock/mock_preferences.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface, MockPreferences;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: MockPreferencesShowcase)
Widget mockPreferencesPlayground(BuildContext context) {
  final seeded = context.knobs.boolean(
    label: 'Seed with sample data',
    initialValue: true,
  );
  return MockPreferencesShowcase(seeded: seeded);
}

@widgetbook.UseCase(name: 'Test helpers', type: MockPreferencesShowcase)
Widget mockPreferencesTestHelpers(BuildContext context) {
  return const MockPreferencesShowcase(seeded: true, showTestHelpers: true);
}

/// Showcase for [MockPreferences]. Drives a live in-memory store through
/// every method on [AbstractPreferencesInterface] and displays the result.
/// The "Test helpers" use case additionally exposes `reset`, `snapshot`,
/// and `peek` — the `@visibleForTesting` API.
class MockPreferencesShowcase extends StatefulWidget {
  const MockPreferencesShowcase({
    required this.seeded,
    this.showTestHelpers = false,
    super.key,
  });

  final bool seeded;
  final bool showTestHelpers;

  @override
  State<MockPreferencesShowcase> createState() =>
      _MockPreferencesShowcaseState();
}

class _MockPreferencesShowcaseState extends State<MockPreferencesShowcase> {
  late MockPreferences _prefs;
  String _lastOpLine = '— no operation yet —';

  @override
  void initState() {
    super.initState();
    _prefs = _build(widget.seeded);
  }

  @override
  void didUpdateWidget(covariant MockPreferencesShowcase old) {
    super.didUpdateWidget(old);
    if (old.seeded != widget.seeded) {
      setState(() {
        _prefs = _build(widget.seeded);
        _lastOpLine = 'rebuilt (seeded = ${widget.seeded})';
      });
    }
  }

  MockPreferences _build(bool seeded) => MockPreferences(
        initialValues: seeded
            ? <String, Object?>{
                'theme': 'dark',
                'fontSize': 14,
                'opacity': 0.85,
                'analytics': true,
                'recents': <String>['inbox', 'archive', 'spam'],
              }
            : null,
      );

  Future<void> _run(
    String label,
    Future<Object?> Function(AbstractPreferencesInterface p) op,
  ) async {
    final result = await op(_prefs);
    if (!mounted) return;
    setState(() {
      _lastOpLine = '$label → $result';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OperationsCard(
                onRun: _run,
                showTestHelpers: widget.showTestHelpers,
                prefs: _prefs,
                onReset: () => setState(() {
                  _prefs.reset();
                  _lastOpLine = 'reset()';
                }),
                onSnapshot: () => setState(() {
                  _lastOpLine = 'snapshot() → ${_prefs.snapshot()}';
                }),
                onPeek: () => setState(() {
                  _lastOpLine = 'peek("fontSize") → ${_prefs.peek('fontSize')}';
                }),
              ),
              const SizedBox(height: 12),
              _LastOpCard(line: _lastOpLine),
              const SizedBox(height: 12),
              Expanded(child: _StorePanel(prefs: _prefs)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── UI bits ────────────────────────────────────────────────────────────────

class _OperationsCard extends StatelessWidget {
  const _OperationsCard({
    required this.onRun,
    required this.showTestHelpers,
    required this.prefs,
    required this.onReset,
    required this.onSnapshot,
    required this.onPeek,
  });

  final Future<void> Function(
    String label,
    Future<Object?> Function(AbstractPreferencesInterface),
  ) onRun;
  final bool showTestHelpers;
  final MockPreferences prefs;
  final VoidCallback onReset;
  final VoidCallback onSnapshot;
  final VoidCallback onPeek;

  @override
  Widget build(BuildContext context) {
    final reads = <(String, Future<Object?> Function(AbstractPreferencesInterface))>[
      ('getString("theme")', (p) => p.getString('theme')),
      ('getInt("fontSize")', (p) => p.getInt('fontSize')),
      ('getDouble("opacity")', (p) => p.getDouble('opacity')),
      ('getBool("analytics")', (p) => p.getBool('analytics')),
      ('getStringList("recents")', (p) => p.getStringList('recents')),
    ];
    final writes = <(String, Future<Object?> Function(AbstractPreferencesInterface))>[
      ('setString("theme","light")', (p) async {
        await p.setString('theme', 'light');
        return 'ok';
      }),
      ('setInt("fontSize",18)', (p) async {
        await p.setInt('fontSize', 18);
        return 'ok';
      }),
      ('setDouble("opacity",1.0)', (p) async {
        await p.setDouble('opacity', 1);
        return 'ok';
      }),
      ('setBool("analytics",false)', (p) async {
        await p.setBool('analytics', false);
        return 'ok';
      }),
      ('setStringList("recents",[…])', (p) async {
        await p.setStringList('recents', const ['drafts', 'starred']);
        return 'ok';
      }),
    ];
    final structural =
        <(String, Future<Object?> Function(AbstractPreferencesInterface))>[
      ('contains("theme")', (p) => p.contains('theme')),
      ('remove("opacity")', (p) async {
        await p.remove('opacity');
        return 'ok';
      }),
      ('clear()', (p) async {
        await p.clear();
        return 'ok';
      }),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Group(title: 'Reads', items: reads, onRun: onRun),
            const SizedBox(height: 8),
            _Group(title: 'Writes', items: writes, onRun: onRun),
            const SizedBox(height: 8),
            _Group(title: 'Structural', items: structural, onRun: onRun),
            if (showTestHelpers) ...[
              const SizedBox(height: 8),
              Text(
                'Test helpers',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: onReset, child: const Text('reset()')),
                  OutlinedButton(
                    onPressed: onSnapshot,
                    child: const Text('snapshot()'),
                  ),
                  OutlinedButton(
                    onPressed: onPeek,
                    child: const Text('peek("fontSize")'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.items,
    required this.onRun,
  });

  final String title;
  final List<(String, Future<Object?> Function(AbstractPreferencesInterface))>
      items;
  final Future<void> Function(
    String,
    Future<Object?> Function(AbstractPreferencesInterface),
  ) onRun;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (label, op) in items)
              FilledButton.tonal(
                onPressed: () => onRun(label, op),
                child: Text(label),
              ),
          ],
        ),
      ],
    );
  }
}

class _LastOpCard extends StatelessWidget {
  const _LastOpCard({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.arrow_right_alt, color: Colors.indigo),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                line,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorePanel extends StatelessWidget {
  const _StorePanel({required this.prefs});

  final MockPreferences prefs;

  @override
  Widget build(BuildContext context) {
    // The MockPreferences store changes synchronously and we call setState
    // after every op, so a direct read is sufficient — no FutureBuilder.
    final snapshot = prefs.snapshot();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live store (${snapshot.length} keys)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: snapshot.isEmpty
                  ? const Center(child: Text('— empty —'))
                  : ListView(
                      children: [
                        for (final entry in snapshot.entries)
                          ListTile(
                            dense: true,
                            title: Text(
                              entry.key,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${entry.value.runtimeType}  =  ${entry.value}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

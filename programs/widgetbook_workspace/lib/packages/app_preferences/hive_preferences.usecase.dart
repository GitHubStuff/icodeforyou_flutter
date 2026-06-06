// lib/packages/app_preferences/src/hive/hive_preferences.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface, HiveInitMode, HivePreferences;
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: HivePreferencesShowcase)
Widget hivePreferencesPlayground(BuildContext context) {
  return const HivePreferencesShowcase();
}

/// Showcase for [HivePreferences]. Initializes Hive once into the system
/// temp directory via [HiveInitMode.test], opens a unique box per mount,
/// and exposes the same CRUD button grid as the Mock playground.
///
/// **Caveats.** Hive needs file I/O — on Flutter web, [HiveInitMode.test]
/// is unsupported and this case will render an error. The box is opened
/// once per `initState`; if the use case rebuilds because of a knob
/// change, the same instance is reused for that mount, then disposed.
class HivePreferencesShowcase extends StatefulWidget {
  const HivePreferencesShowcase({super.key});

  @override
  State<HivePreferencesShowcase> createState() =>
      _HivePreferencesShowcaseState();
}

class _HivePreferencesShowcaseState extends State<HivePreferencesShowcase> {
  late final Future<HivePreferences> _prefsFuture;
  HivePreferences? _prefs;

  // Snapshot rebuilt after every op via FutureBuilder; we cache the
  // snapshot key list so a rebuild does not re-query Hive needlessly.
  Map<String, Object?> _snapshot = const {};
  String _lastOpLine = '— no operation yet —';

  @override
  void initState() {
    super.initState();
    _prefsFuture = _open();
  }

  Future<HivePreferences> _open() async {
    await _ensureInitialized();
    // Unique box name per mount so successive renders don't share state.
    final boxName =
        'wb_hive_playground_${DateTime.now().microsecondsSinceEpoch}';
    final prefs = await HivePreferences.create(boxName: boxName);
    // Seed.
    await prefs.setString('theme', 'dark');
    await prefs.setInt('fontSize', 14);
    await prefs.setDouble('opacity', 0.85);
    await prefs.setBool('analytics', true);
    await prefs.setStringList('recents', const ['inbox', 'archive', 'spam']);
    _prefs = prefs;
    await _refreshSnapshot();
    return prefs;
  }

  Future<void> _ensureInitialized() async {
    if (_hiveInitialized) return;
    _hiveInitialized = true;
    await HivePreferences.init(mode: HiveInitMode.test);
  }

  Future<void> _refreshSnapshot() async {
    final prefs = _prefs;
    if (prefs == null) return;
    // The interface has no listKeys() so we probe the known keys we seed
    // plus any the user has set through the buttons below.
    final keys = {..._knownKeys, ..._snapshot.keys};
    final next = <String, Object?>{};
    for (final k in keys) {
      if (!await prefs.contains(k)) continue;
      // Try each type until one returns non-null.
      next[k] = await _firstNonNullRead(prefs, k);
    }
    if (!mounted) return;
    setState(() => _snapshot = next);
  }

  Future<Object?> _firstNonNullRead(
    AbstractPreferencesInterface p,
    String key,
  ) async {
    final s = await p.getString(key);
    if (s != null) return s;
    final i = await p.getInt(key);
    if (i != null) return i;
    final d = await p.getDouble(key);
    if (d != null) return d;
    final b = await p.getBool(key);
    if (b != null) return b;
    return await p.getStringList(key);
  }

  Future<void> _run(
    String label,
    Future<Object?> Function(AbstractPreferencesInterface p) op,
  ) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final result = await op(prefs);
    await _refreshSnapshot();
    if (!mounted) return;
    setState(() => _lastOpLine = '$label → $result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<HivePreferences>(
            future: _prefsFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return _ErrorPanel(error: snap.error!);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OperationsCard(onRun: _run),
                  const SizedBox(height: 12),
                  _LastOpCard(line: _lastOpLine),
                  const SizedBox(height: 12),
                  Expanded(child: _StorePanel(snapshot: _snapshot)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Hive can only be init'd once per process; share across rebuilds.
bool _hiveInitialized = false;

const _knownKeys = {'theme', 'fontSize', 'opacity', 'analytics', 'recents'};

// ─── UI bits ────────────────────────────────────────────────────────────────

class _OperationsCard extends StatelessWidget {
  const _OperationsCard({required this.onRun});

  final Future<void> Function(
    String,
    Future<Object?> Function(AbstractPreferencesInterface),
  ) onRun;

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
  const _StorePanel({required this.snapshot});

  final Map<String, Object?> snapshot;

  @override
  Widget build(BuildContext context) {
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

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HivePreferences failed to initialize',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hive needs file I/O. This use case will not work on Flutter '
              'web. On desktop/mobile it writes to a fresh temp directory '
              'via HiveInitMode.test.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/packages/app_preferences/src/abstract_preferences_interface.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface, MockPreferences;
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(
  name: 'Contract — type filtering',
  type: AbstractPreferencesInterfaceShowcase,
)
Widget abstractPreferencesContractTyping(BuildContext context) {
  return const AbstractPreferencesInterfaceShowcase(
    mode: _Mode.typeFiltering,
  );
}

@widgetbook.UseCase(
  name: 'Contract — absent keys',
  type: AbstractPreferencesInterfaceShowcase,
)
Widget abstractPreferencesContractAbsent(BuildContext context) {
  return const AbstractPreferencesInterfaceShowcase(mode: _Mode.absentKeys);
}

@widgetbook.UseCase(
  name: 'Contract — structural ops',
  type: AbstractPreferencesInterfaceShowcase,
)
Widget abstractPreferencesContractStructural(BuildContext context) {
  return const AbstractPreferencesInterfaceShowcase(mode: _Mode.structural);
}

/// Showcase for the [AbstractPreferencesInterface] contract. Asserts the
/// invariants that every implementation must satisfy by running a small
/// scripted scenario against a [MockPreferences] instance and rendering a
/// pass/fail list. Backed by Mock here for portability; the same harness
/// could drive `HivePreferences` or `PlatformPreferences`.
class AbstractPreferencesInterfaceShowcase extends StatefulWidget {
  const AbstractPreferencesInterfaceShowcase({required this.mode, super.key});

  final _Mode mode;

  @override
  State<AbstractPreferencesInterfaceShowcase> createState() =>
      _AbstractPreferencesInterfaceShowcaseState();
}

enum _Mode { typeFiltering, absentKeys, structural }

class _Check {
  _Check(this.label, this.pass, this.detail);
  final String label;
  final bool pass;
  final String detail;
}

class _AbstractPreferencesInterfaceShowcaseState
    extends State<AbstractPreferencesInterfaceShowcase> {
  late Future<List<_Check>> _checks;

  @override
  void initState() {
    super.initState();
    _checks = _run();
  }

  @override
  void didUpdateWidget(covariant AbstractPreferencesInterfaceShowcase old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode) {
      _checks = _run();
    }
  }

  Future<List<_Check>> _run() async {
    final AbstractPreferencesInterface p = MockPreferences();
    switch (widget.mode) {
      case _Mode.typeFiltering:
        return _runTypeFiltering(p);
      case _Mode.absentKeys:
        return _runAbsentKeys(p);
      case _Mode.structural:
        return _runStructural(p);
    }
  }

  Future<List<_Check>> _runTypeFiltering(
    AbstractPreferencesInterface p,
  ) async {
    await p.setInt('count', 42);
    final asInt = await p.getInt('count');
    final asString = await p.getString('count');
    final asDouble = await p.getDouble('count');
    final asBool = await p.getBool('count');
    final asList = await p.getStringList('count');
    return [
      _Check('getInt returns the stored int', asInt == 42, 'got: $asInt'),
      _Check(
        'getString on an int returns null',
        asString == null,
        'got: $asString',
      ),
      _Check(
        'getDouble on an int returns null',
        asDouble == null,
        'got: $asDouble',
      ),
      _Check(
        'getBool on an int returns null',
        asBool == null,
        'got: $asBool',
      ),
      _Check(
        'getStringList on an int returns null',
        asList == null,
        'got: $asList',
      ),
    ];
  }

  Future<List<_Check>> _runAbsentKeys(
    AbstractPreferencesInterface p,
  ) async {
    final s = await p.getString('missing');
    final i = await p.getInt('missing');
    final d = await p.getDouble('missing');
    final b = await p.getBool('missing');
    final l = await p.getStringList('missing');
    final has = await p.contains('missing');
    return [
      _Check('getString on absent key → null', s == null, 'got: $s'),
      _Check('getInt on absent key → null', i == null, 'got: $i'),
      _Check('getDouble on absent key → null', d == null, 'got: $d'),
      _Check('getBool on absent key → null', b == null, 'got: $b'),
      _Check('getStringList on absent key → null', l == null, 'got: $l'),
      _Check('contains absent key → false', has == false, 'got: $has'),
    ];
  }

  Future<List<_Check>> _runStructural(
    AbstractPreferencesInterface p,
  ) async {
    await p.setString('a', 'A');
    await p.setString('b', 'B');
    final hasA = await p.contains('a');
    await p.remove('a');
    final hasAStill = await p.contains('a');
    final hasB = await p.contains('b');
    await p.clear();
    final hasAFinal = await p.contains('a');
    final hasBFinal = await p.contains('b');
    return [
      _Check('contains after set → true', hasA, 'got: $hasA'),
      _Check('contains after remove → false', !hasAStill, 'got: $hasAStill'),
      _Check(
        'remove leaves other keys intact',
        hasB,
        'got: $hasB',
      ),
      _Check(
        'clear removes everything (a)',
        !hasAFinal,
        'got: $hasAFinal',
      ),
      _Check(
        'clear removes everything (b)',
        !hasBFinal,
        'got: $hasBFinal',
      ),
    ];
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
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contract checks: ${_titleFor(widget.mode)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'These invariants must hold for any '
                        'AbstractPreferencesInterface implementation. The '
                        'harness here runs them against MockPreferences.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<_Check>>(
                  future: _checks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final checks = snapshot.data!;
                    return ListView.separated(
                      itemCount: checks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => _CheckTile(check: checks[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleFor(_Mode mode) => switch (mode) {
        _Mode.typeFiltering => 'type filtering',
        _Mode.absentKeys => 'absent keys',
        _Mode.structural => 'structural ops',
      };
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({required this.check});

  final _Check check;

  @override
  Widget build(BuildContext context) {
    final color = check.pass ? Colors.green : Colors.red;
    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(check.pass ? Icons.check_circle : Icons.cancel, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    check.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    check.detail,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
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

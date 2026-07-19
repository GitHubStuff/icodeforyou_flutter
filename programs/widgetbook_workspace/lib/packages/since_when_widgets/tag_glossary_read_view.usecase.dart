// lib/packages/since_when_widgets/lib/src/tag_glossary_read/tag_glossary_read_view.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:gap/gap.dart';
import 'package:ice_chips/ice_chips.dart';
import 'package:since_when_framework/database.dart';
import 'package:since_when_widgets/since_when_widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: TagGlossaryReadView)
Widget tagGlossaryReadViewUseCase(BuildContext context) {
  final scenario = context.knobs.object.dropdown<_Scenario>(
    label: 'scenario',
    options: _Scenario.values,
    initialOption: _Scenario.loaded,
    labelBuilder: (s) => s.label,
  );

  return _ReadShowcase(scenario: scenario);
}

enum _Scenario {
  loaded('Loaded (8 tags)'),
  empty('Empty'),
  error('Error');

  const _Scenario(this.label);

  final String label;
}

class _ReadShowcase extends StatefulWidget {
  const _ReadShowcase({required this.scenario});

  final _Scenario scenario;

  @override
  State<_ReadShowcase> createState() => _ReadShowcaseState();
}

class _ReadShowcaseState extends State<_ReadShowcase> {
  RecordTagDefinition? _lastTapped;

  GlossaryReader _readerFor(_Scenario s) => switch (s) {
    _Scenario.loaded => _InMemoryReader(_sampleTags()),
    _Scenario.empty => const _InMemoryReader([]),
    _Scenario.error => const _FailingReader(),
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: TagGlossaryReadView(
                // Force a fresh provider + load when the scenario changes.
                key: ValueKey(widget.scenario),
                reader: _readerFor(widget.scenario),
                onTap: (record) => setState(() => _lastTapped = record),
              ),
            ),
            const Gap(16),
            Text(
              _lastTapped == null
                  ? 'tap a chip…'
                  : 'last tapped: ${_lastTapped!.tagName}',
            ),
          ],
        ),
      ),
    );
  }
}

List<RecordTagDefinition> _sampleTags() {
  final now = DateTime.now().millisecondsSinceEpoch;
  const names = [
    ('work', 0xFF4A90E2),
    ('home', 0xFFE94B3C),
    ('urgent', 0xFFF5A623),
    ('reading', 0xFF7ED321),
    ('meeting', 0xFF9013FE),
    ('side-project', 0xFF50E3C2),
    ('chore', 0xFFBD10E0),
    ('wellness', 0xFF417505),
  ];
  return [
    for (var i = 0; i < names.length; i++)
      RecordTagDefinition(
        id: i + 1,
        createdTimeStamp: now - (names.length - i) * 1000,
        tagName: names[i].$1,
        color: names[i].$2,
      ),
  ];
}

class _InMemoryReader implements GlossaryReader {
  const _InMemoryReader(this._tags);

  final List<RecordTagDefinition> _tags;

  @override
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
  fetchAllTagDefinitions() async => Right(_tags);
}

class _FailingReader implements GlossaryReader {
  const _FailingReader();

  @override
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
  fetchAllTagDefinitions() async => Left(
    const SinceWhenFailure(DatabaseOpenFailure('simulated failure for showcase')),
  );
}

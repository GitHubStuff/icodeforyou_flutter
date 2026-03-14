// lib/packages/tag_chip/tag_chip.usecase.dart

import 'package:flutter/material.dart';
import 'package:tag_chip/tag_chip.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// States — all three states side by side
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'States', type: TagChip)
Widget tagChipStates(BuildContext context) {
  final color = context.knobs.color(
    label: 'Background',
    initialValue: Colors.blue,
  );
  final fontSize = context.knobs.double.slider(
    label: 'Font Size',
    initialValue: 16,
    min: 10,
    max: 28,
  );

  return Center(
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: TagChipState.values.map((state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TagChip(
              text: state.name,
              backgroundColor: color,
              state: state,
              fontSize: fontSize,
            ),
            const SizedBox(height: 4),
            Text(
              state.name,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Interactive — tapping toggles enabled/disabled
// ---------------------------------------------------------------------------

class _TagChipGroup extends StatefulWidget {
  const _TagChipGroup({required this.tags, required this.color});

  final List<String> tags;
  final Color color;

  @override
  State<_TagChipGroup> createState() => _TagChipGroupState();
}

class _TagChipGroupState extends State<_TagChipGroup> {
  late final Map<String, TagChipState> _states;

  @override
  void initState() {
    super.initState();
    _states = {for (final t in widget.tags) t: TagChipState.none};
  }

  void _onPressed(String tag, TagChipState current) {
    setState(() {
      _states[tag] = current == TagChipState.enabled
          ? TagChipState.disabled
          : TagChipState.enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.tags.map((tag) {
            final state = _states[tag]!;
            return TagChip(
              text: tag,
              backgroundColor: widget.color,
              state: state,
              onPressed: (s) => _onPressed(tag, s),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(
            () => _states.updateAll((_, _) => TagChipState.none),
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Interactive', type: TagChip)
Widget tagChipInteractive(BuildContext context) {
  final color = context.knobs.color(
    label: 'Background',
    initialValue: Colors.teal,
  );

  const tags = [
    'Flutter',
    'Dart',
    'iOS',
    'Android',
    'macOS',
    'Web',
    'Linux',
    'Windows',
  ];

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: _TagChipGroup(tags: tags, color: color),
    ),
  );
}

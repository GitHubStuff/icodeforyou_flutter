// lib/packages/animated_widgets/lib/src/crossfade_widgets/crossfade_widgets.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: CrossFadeWidgets)
Widget crossFadeWidgetsUseCase(BuildContext context) {
  final direction = context.knobs.object.dropdown<CrossFadeAxis>(
    label: 'direction',
    options: CrossFadeAxis.values,
    initialOption: CrossFadeAxis.left,
    labelBuilder: (a) => a.name,
  );

  final childCount = context.knobs.int.slider(
    label: 'child count',
    initialValue: 4,
    min: 1,
    max: 8,
  );

  final useCustomDuration = context.knobs.boolean(
    label: 'override duration',
    initialValue: false,
  );

  final durationMs = context.knobs.int.slider(
    label: 'duration (ms)',
    initialValue: 700,
    min: 100,
    max: 3000,
  );

  return _CrossFadeShowcase(
    direction: direction,
    childCount: childCount,
    duration: useCustomDuration
        ? Duration(milliseconds: durationMs)
        : null,
  );
}

class _CrossFadeShowcase extends StatefulWidget {
  const _CrossFadeShowcase({
    required this.direction,
    required this.childCount,
    required this.duration,
  });

  final CrossFadeAxis direction;
  final int childCount;
  final Duration? duration;

  @override
  State<_CrossFadeShowcase> createState() => _CrossFadeShowcaseState();
}

class _CrossFadeShowcaseState extends State<_CrossFadeShowcase> {
  int _lastIndex = 0;

  static const List<Color> _palette = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final children = List<Widget>.generate(widget.childCount, (i) {
      final color = _palette[i % _palette.length];
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'page ${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CrossFadeWidgets(
            // Force rebuild when knob count changes.
            key: ValueKey('count:${widget.childCount}-dir:${widget.direction}'),
            direction: widget.direction,
            duration: widget.duration,
            onIndexChanged: (i) => setState(() => _lastIndex = i),
            children: children,
          ),
          const Gap(16),
          Text('active index: $_lastIndex'),
        ],
      ),
    );
  }
}

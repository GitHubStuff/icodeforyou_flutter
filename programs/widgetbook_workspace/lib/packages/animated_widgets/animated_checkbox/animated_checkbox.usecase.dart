// lib/packages/animated_widgets/lib/src/animated_checkbox/animated_checkbox.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AnimatedCheckbox)
Widget animatedCheckboxUseCase(BuildContext context) {
  final width = context.knobs.double.slider(
    label: 'width',
    initialValue: 140,
    min: 40,
    max: 240,
  );

  final durationMs = context.knobs.int.slider(
    label: 'duration (ms)',
    initialValue: 850,
    min: 200,
    max: 2500,
  );

  final stroke = context.knobs.color(
    label: 'stroke color',
    initialValue: Colors.purple,
  );

  return _CheckboxShowcase(
    width: width,
    duration: Duration(milliseconds: durationMs),
    strokeColor: stroke,
  );
}

class _CheckboxShowcase extends StatefulWidget {
  const _CheckboxShowcase({
    required this.width,
    required this.duration,
    required this.strokeColor,
  });

  final double width;
  final Duration duration;
  final Color strokeColor;

  @override
  State<_CheckboxShowcase> createState() => _CheckboxShowcaseState();
}

class _CheckboxShowcaseState extends State<_CheckboxShowcase> {
  bool _draw = true;
  String _status = 'idle';

  void _toggle() => setState(() {
    _draw = !_draw;
    _status = _draw ? 'drawing…' : 'dissolving…';
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedCheckbox(
            draw: _draw,
            width: widget.width,
            duration: widget.duration,
            strokeColor: widget.strokeColor,
            onAnimationComplete: (finalDraw) =>
                setState(() => _status = finalDraw ? 'drawn ✓' : 'dissolved'),
          ),
          const Gap(24),
          Text(_status),
          const Gap(8),
          FilledButton(
            onPressed: _toggle,
            child: Text(_draw ? 'Dissolve' : 'Draw'),
          ),
        ],
      ),
    );
  }
}

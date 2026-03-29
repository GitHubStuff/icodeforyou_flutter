// lib/packages/animated_widgets/animated_checkbox.usecase.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class _CheckboxHost extends StatefulWidget {
  const _CheckboxHost({
    required this.strokeColor,
    required this.width,
    required this.duration,
    required this.curve,
  });

  final Color strokeColor;
  final double width;
  final Duration duration;
  final Curve curve;

  @override
  State<_CheckboxHost> createState() => _CheckboxHostState();
}

class _CheckboxHostState extends State<_CheckboxHost> {
  bool _draw = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedCheckbox(
          draw: _draw,
          width: widget.width,
          strokeColor: widget.strokeColor,
          duration: widget.duration,
          curve: widget.curve,
          onAnimationComplete: (_) {},
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _draw = !_draw),
          child: Text(_draw ? 'Dissolve' : 'Draw'),
        ),
      ],
    );
  }
}

const Map<String, Curve> _curves = {
  'easeInOutQuart': Curves.easeInOutQuart,
  'easeOut': Curves.easeOut,
  'easeIn': Curves.easeIn,
  'bounceOut': Curves.bounceOut,
  'elasticOut': Curves.elasticOut,
  'linear': Curves.linear,
};

@widgetbook.UseCase(name: 'Default', type: AnimatedCheckbox)
Widget animatedCheckboxDefault(BuildContext context) {
  final width = context.knobs.double.slider(
    label: 'Width',
    initialValue: 100,
    min: 5,
    max: 300,
  );

  final strokeColor = context.knobs.color(
    label: 'Stroke Color',
    initialValue: Colors.purple,
  );

  final ms = context.knobs.double.slider(
    label: 'Duration (ms)',
    initialValue: 850,
    min: 100,
    max: 3000,
  );

  final curveName = context.knobs.object.dropdown<String>(
    label: 'Curve',
    options: _curves.keys.toList(),
    initialOption: 'easeInOutQuart',
  );

  return Center(
    child: _CheckboxHost(
      strokeColor: strokeColor,
      width: width,
      duration: Duration(milliseconds: ms.toInt()),
      curve: _curves[curveName]!,
    ),
  );
}

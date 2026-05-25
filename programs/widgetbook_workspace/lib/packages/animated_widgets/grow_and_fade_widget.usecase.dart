// lib/packages/animated_widgets/grow_and_fade_widget.usecase.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class _GrowAndFadeHost extends StatefulWidget {
  const _GrowAndFadeHost({
    required this.duration,
    required this.curve,
  });

  final Duration duration;
  final Curve curve;

  @override
  State<_GrowAndFadeHost> createState() => _GrowAndFadeHostState();
}

class _GrowAndFadeHostState extends State<_GrowAndFadeHost> {
  int _key = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: GrowAndFadeWidgetView(
            key: ValueKey(_key),
            duration: widget.duration,
            curve: widget.curve,
            onComplete: () {},
            child: const FlutterLogo(size: 80),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _key++),
          child: const Text('Replay'),
        ),
      ],
    );
  }
}

const Map<String, Curve> _curves = {
  'easeOut': Curves.easeOut,
  'easeIn': Curves.easeIn,
  'easeInOut': Curves.easeInOut,
  'bounceOut': Curves.bounceOut,
  'elasticOut': Curves.elasticOut,
  'linear': Curves.linear,
};

@widgetbook.UseCase(name: 'Default', type: GrowAndFadeWidgetView)
Widget growAndFadeWidgetDefault(BuildContext context) {
  final ms = context.knobs.double.slider(
    label: 'Duration (ms)',
    initialValue: 600,
    min: 100,
    max: 2000,
  );

  final curveName = context.knobs.object.dropdown<String>(
    label: 'Curve',
    options: _curves.keys.toList(),
    initialOption: 'easeOut',
  );

  return Center(
    child: _GrowAndFadeHost(
      duration: Duration(milliseconds: ms.toInt()),
      curve: _curves[curveName]!,
    ),
  );
}

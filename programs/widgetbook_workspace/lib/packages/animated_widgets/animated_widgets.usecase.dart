// lib/packages/animated_widgets/animated_widgets.usecase.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// AnimatedCheckbox — interactive toggle
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// GrowWidgetView — replay host
// ---------------------------------------------------------------------------

class _GrowHost extends StatefulWidget {
  const _GrowHost({required this.duration});

  final Duration duration;

  @override
  State<_GrowHost> createState() => _GrowHostState();
}

class _GrowHostState extends State<_GrowHost> {
  int _key = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: GrowWidgetView(
            key: ValueKey(_key),
            duration: widget.duration,
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

@widgetbook.UseCase(name: 'Default', type: GrowWidgetView)
Widget growWidgetDefault(BuildContext context) {
  final ms = context.knobs.double.slider(
    label: 'Duration (ms)',
    initialValue: 600,
    min: 100,
    max: 2000,
  );

  return Center(
    child: _GrowHost(duration: Duration(milliseconds: ms.toInt())),
  );
}

// ---------------------------------------------------------------------------
// GrowAndFadeWidgetView — replay host
// ---------------------------------------------------------------------------

class _GrowAndFadeHost extends StatefulWidget {
  const _GrowAndFadeHost({required this.duration});

  final Duration duration;

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

@widgetbook.UseCase(name: 'Default', type: GrowAndFadeWidgetView)
Widget growAndFadeWidgetDefault(BuildContext context) {
  final ms = context.knobs.double.slider(
    label: 'Duration (ms)',
    initialValue: 600,
    min: 100,
    max: 2000,
  );

  return Center(
    child: _GrowAndFadeHost(duration: Duration(milliseconds: ms.toInt())),
  );
}

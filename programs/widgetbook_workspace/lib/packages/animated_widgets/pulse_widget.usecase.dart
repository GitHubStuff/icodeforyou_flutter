// lib/packages/animated_widgets/pulse_widget.usecase.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class _PulseHost extends StatefulWidget {
  const _PulseHost({required this.duration});

  final Duration duration;

  @override
  State<_PulseHost> createState() => _PulseHostState();
}

class _PulseHostState extends State<_PulseHost> {
  bool _trigger = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseWidget(
          trigger: _trigger,
          duration: widget.duration,
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.favorite, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _trigger = !_trigger),
          child: const Text('Pulse'),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Default', type: PulseWidget)
Widget pulseWidgetDefault(BuildContext context) {
  final ms = context.knobs.double.slider(
    label: 'Duration (ms)',
    initialValue: 200,
    min: 50,
    max: 1000,
  );

  return Center(
    child: _PulseHost(duration: Duration(milliseconds: ms.toInt())),
  );
}

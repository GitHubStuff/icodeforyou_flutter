// programs/widgetbook_workspace/lib/packages/counter_ring/counter_ring.usecase.dart
import 'dart:async';

import 'package:counter_ring/counter_ring.dart'
    show CounterRing, CounterRingCubit;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

enum _Direction { countUp, countDown }

@widgetbook.UseCase(name: 'Interactive', type: CounterRing)
Widget buildCounterRingInteractiveUseCase(BuildContext context) {
  // Ring 1 — fully knob-driven.
  final direction = context.knobs.object.dropdown<_Direction>(
    label: 'Ring 1: Direction',
    options: _Direction.values,
    initialOption: _Direction.countUp,
    labelBuilder: (d) => switch (d) {
      _Direction.countUp => 'Count up',
      _Direction.countDown => 'Count down',
    },
  );
  final range = context.knobs.double.slider(
    label: 'Ring 1: Range',
    initialValue: 100,
    min: 10,
    max: 1000,
    divisions: 99,
  );
  final step = context.knobs.double.slider(
    label: 'Ring 1: Step',
    initialValue: 10,
    min: 1,
    max: 100,
    divisions: 99,
  );
  final intervalMs = context.knobs.double.slider(
    label: 'Ring 1: Interval (ms)',
    initialValue: 500,
    min: 50,
    max: 2000,
    divisions: 39,
  );
  final size = context.knobs.double.slider(
    label: 'Ring 1: Size',
    initialValue: 160,
    min: 60,
    max: 320,
    divisions: 26,
  );
  final strokeWidth = context.knobs.double.slider(
    label: 'Ring 1: Stroke width',
    initialValue: 10,
    min: 2,
    max: 32,
    divisions: 30,
  );
  final color = context.knobs.color(
    label: 'Ring 1: Color',
    initialValue: Colors.teal,
  );
  final backgroundColor = context.knobs.color(
    label: 'Ring 1: Background color',
    initialValue: Colors.teal.shade100,
  );

  // Ring 3 — activity-ring sized, no centre content.
  final smallDiameter = context.knobs.double.slider(
    label: 'Ring 3: Diameter',
    initialValue: 40,
    min: 10,
    max: 75,
    divisions: 65,
  );
  final smallColor = context.knobs.color(
    label: 'Ring 3: Color',
    initialValue: Colors.pinkAccent,
  );

  final (start, finish) = switch (direction) {
    _Direction.countUp => (0.0, range),
    _Direction.countDown => (range, 0.0),
  };

  return Center(
    child: Wrap(
      spacing: 48,
      runSpacing: 48,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ControlledCounterRing(
          // Remount with a fresh controller whenever a timing knob changes.
          key: ValueKey((start, finish, step, intervalMs)),
          label: 'Ring 1: knob-driven',
          start: start,
          finish: finish,
          step: step,
          interval: Duration(milliseconds: intervalMs.round()),
          size: size,
          strokeWidth: strokeWidth,
          color: color,
          backgroundColor: backgroundColor,
        ),
        const _ControlledCounterRing(
          label: 'Ring 2: 10 → 0 in 1s',
          start: 10,
          finish: 0,
          step: 1,
          interval: Duration(milliseconds: 100),
          size: 120,
          strokeWidth: 10,
          color: Colors.red,
        ),
        _ControlledCounterRing(
          label: 'Ring 3: activity ring',
          start: 0,
          finish: 100,
          step: 5,
          interval: const Duration(milliseconds: 150),
          size: smallDiameter,
          strokeWidth: (smallDiameter * 0.18).clamp(2.0, 14.0),
          color: smallColor,
          backgroundColor: smallColor.withValues(alpha: 0.2),
          showCenter: false,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Preset Gallery', type: CounterRing)
Widget buildCounterRingPresetGalleryUseCase(BuildContext context) {
  return const Center(
    child: Wrap(
      spacing: 48,
      runSpacing: 48,
      alignment: WrapAlignment.center,
      children: [
        _ControlledCounterRing(
          label: 'Count up 0 → 100',
          start: 0,
          finish: 100,
          step: 10,
          interval: Duration(milliseconds: 500),
          color: Colors.green,
        ),
        _ControlledCounterRing(
          label: '60s countdown',
          start: 60,
          finish: 0,
          step: 1,
          interval: Duration(seconds: 1),
          color: Colors.red,
          size: 160,
          strokeWidth: 12,
        ),
        _ControlledCounterRing(
          label: 'Non-divisible 0 → 100 by 30',
          start: 0,
          finish: 100,
          step: 30,
          interval: Duration(milliseconds: 750),
          color: Colors.orange,
        ),
        _ControlledCounterRing(
          label: 'Fractional 1.0 → 0.0 by 0.1',
          start: 1,
          finish: 0,
          step: 0.1,
          interval: Duration(milliseconds: 300),
          color: Colors.indigo,
        ),
      ],
    ),
  );
}

/// Hosts a [CounterRing] with a controller it owns, plus Start/Stop/Cancel
/// buttons and a readout of the last callback values.
class _ControlledCounterRing extends StatefulWidget {
  const _ControlledCounterRing({
    required this.start,
    required this.finish,
    required this.step,
    required this.interval,
    this.label,
    this.size = 120,
    this.strokeWidth = 8,
    this.color,
    this.backgroundColor,
    this.showCenter = true,
    super.key,
  });

  final double start;
  final double finish;
  final double step;
  final Duration interval;
  final String? label;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;

  /// When false, the ring is drawn with nothing in its centre.
  final bool showCenter;

  @override
  State<_ControlledCounterRing> createState() => _ControlledCounterRingState();
}

class _ControlledCounterRingState extends State<_ControlledCounterRing> {
  late final CounterRingCubit _controller;
  double? _lastValue;
  double? _finishedAt;

  @override
  void initState() {
    super.initState();
    _controller = CounterRingCubit(
      start: widget.start,
      finish: widget.finish,
      step: widget.step,
      interval: widget.interval,
    );
  }

  @override
  void dispose() {
    unawaited(_controller.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label case final label?) ...[
          Text(label, style: textTheme.titleMedium),
          const SizedBox(height: 16),
        ],
        CounterRing(
          ringCubit: _controller,
          size: widget.size,
          strokeWidth: widget.strokeWidth,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
          centerBuilder: widget.showCenter
              ? null
              : (_, _) => const SizedBox.shrink(),
          onValueChanged: (v) => setState(() => _lastValue = v),
          onFinish: (f) => setState(() => _finishedAt = f),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: _controller.start,
              child: const Text('Start'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _controller.stop,
              child: const Text('Stop'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                _controller.cancel();
                setState(() => _finishedAt = null);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'onValueChanged: ${_lastValue ?? '—'}   onFinish: ${_finishedAt ?? '—'}',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

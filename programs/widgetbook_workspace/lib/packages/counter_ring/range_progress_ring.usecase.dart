// programs/widgetbook_workspace/lib/packages/counter_ring/range_progress_ring.usecase.dart
import 'package:counter_ring/counter_ring.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

enum _Direction { countUp, countDown }

@widgetbook.UseCase(name: 'Interactive', type: RangeProgressRing)
Widget buildRangeProgressRingInteractiveUseCase(BuildContext context) {
  final direction = context.knobs.object.dropdown<_Direction>(
    label: 'Direction',
    options: _Direction.values,
    initialOption: _Direction.countUp,
    labelBuilder: (d) => switch (d) {
      _Direction.countUp => 'Count up (0 → range)',
      _Direction.countDown => 'Count down (range → 0)',
    },
  );
  final range = context.knobs.double.slider(
    label: 'Range',
    initialValue: 100,
    min: 10,
    max: 1000,
    divisions: 99,
  );
  final currentValue = context.knobs.double.slider(
    label: 'Current value',
    initialValue: 40,
    min: -100,
    max: 1100,
    divisions: 120,
  );
  final size = context.knobs.double.slider(
    label: 'Size',
    initialValue: 160,
    min: 10,
    max: 320,
    divisions: 31,
  );
  final strokeWidth = context.knobs.double.slider(
    label: 'Stroke width',
    initialValue: 10,
    min: 1,
    max: 40,
    divisions: 39,
  );
  final color = context.knobs.color(
    label: 'Color',
    initialValue: Colors.teal,
  );
  final backgroundColor = context.knobs.color(
    label: 'Background color',
    initialValue: Colors.teal.shade100,
  );
  final showChild = context.knobs.boolean(
    label: 'Show centre child',
    initialValue: true,
  );

  final (startValue, finishValue) = switch (direction) {
    _Direction.countUp => (0.0, range),
    _Direction.countDown => (range, 0.0),
  };

  final ring = RangeProgressRing(
    startValue: startValue,
    finishValue: finishValue,
    currentValue: currentValue,
    size: size,
    strokeWidth: strokeWidth,
    color: color,
    backgroundColor: backgroundColor,
    child: showChild
        ? Text(
            currentValue.toStringAsFixed(0),
            style: Theme.of(context).textTheme.headlineMedium,
          )
        : null,
  );

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ring,
        const SizedBox(height: 16),
        Text(
          'progress: ${ring.progress.toStringAsFixed(2)}   '
          'arc: ${ring.arcFraction.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Preset Gallery', type: RangeProgressRing)
Widget buildRangeProgressRingPresetGalleryUseCase(BuildContext context) {
  return const Center(
    child: Wrap(
      spacing: 40,
      runSpacing: 40,
      alignment: WrapAlignment.center,
      children: [
        _LabelledRing(
          label: 'Count up: empty (0 of 100)',
          ring: RangeProgressRing(
            startValue: 0,
            finishValue: 100,
            currentValue: 0,
            color: Colors.green,
            child: Text('0'),
          ),
        ),
        _LabelledRing(
          label: 'Count up: half (50 of 100)',
          ring: RangeProgressRing(
            startValue: 0,
            finishValue: 100,
            currentValue: 50,
            color: Colors.green,
            child: Text('50'),
          ),
        ),
        _LabelledRing(
          label: 'Count up: full (100 of 100)',
          ring: RangeProgressRing(
            startValue: 0,
            finishValue: 100,
            currentValue: 100,
            color: Colors.green,
            child: Text('100'),
          ),
        ),
        _LabelledRing(
          label: 'Countdown 60 → 0: at 60 (full)',
          ring: RangeProgressRing(
            startValue: 60,
            finishValue: 0,
            currentValue: 60,
            color: Colors.red,
            child: Text('60s'),
          ),
        ),
        _LabelledRing(
          label: 'Countdown 60 → 0: at 45',
          ring: RangeProgressRing(
            startValue: 60,
            finishValue: 0,
            currentValue: 45,
            color: Colors.red,
            child: Text('45s'),
          ),
        ),
        _LabelledRing(
          label: 'Countdown 60 → 0: at 15',
          ring: RangeProgressRing(
            startValue: 60,
            finishValue: 0,
            currentValue: 15,
            color: Colors.red,
            child: Text('15s'),
          ),
        ),
        _LabelledRing(
          label: 'Countdown 60 → 0: at 0 (empty)',
          ring: RangeProgressRing(
            startValue: 60,
            finishValue: 0,
            currentValue: 0,
            color: Colors.red,
            child: Text('0s'),
          ),
        ),
        _LabelledRing(
          label: 'Overshoot clamped (150 of 100)',
          ring: RangeProgressRing(
            startValue: 0,
            finishValue: 100,
            currentValue: 150,
            color: Colors.orange,
            child: Text('150'),
          ),
        ),
        _LabelledRing(
          label: 'Before start clamped (-20 of 100)',
          ring: RangeProgressRing(
            startValue: 0,
            finishValue: 100,
            currentValue: -20,
            color: Colors.orange,
            child: Text('-20'),
          ),
        ),
        _LabelledRing(
          label: 'Thick stroke, large',
          ring: RangeProgressRing(
            startValue: 0,
            finishValue: 1,
            currentValue: 0.75,
            size: 180,
            strokeWidth: 20,
            color: Colors.indigo,
            backgroundColor: Colors.indigoAccent,
            child: Text('75%'),
          ),
        ),
        _LabelledRing(
          label: 'Activity ring, no child',
          ring: RangeProgressRing(
            startValue: 0,
            finishValue: 100,
            currentValue: 30,
            size: 40,
            strokeWidth: 7,
            color: Colors.pinkAccent,
            backgroundColor: Color(0x33FF4081),
          ),
        ),
      ],
    ),
  );
}

class _LabelledRing extends StatelessWidget {
  const _LabelledRing({required this.label, required this.ring});

  final String label;
  final RangeProgressRing ring;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ring,
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

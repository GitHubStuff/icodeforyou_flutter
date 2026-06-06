// lib/packages/animated_widgets/lib/src/fader_widget/src/fader_widget.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: FaderWidget)
Widget faderWidgetUseCase(BuildContext context) {
  final durationMs = context.knobs.int.slider(
    label: 'fade duration (ms)',
    initialValue: 1500,
    min: 300,
    max: 4000,
  );

  return _FaderShowcase(duration: Duration(milliseconds: durationMs));
}

class _FaderShowcase extends StatefulWidget {
  const _FaderShowcase({required this.duration});

  final Duration duration;

  @override
  State<_FaderShowcase> createState() => _FaderShowcaseState();
}

class _FaderShowcaseState extends State<_FaderShowcase> {
  late final FaderCubit _cubit;
  int _pushCount = 0;

  static const List<String> _quips = [
    'Hello.',
    'Crossfading.',
    'Queues up if busy.',
    'FIFO, every time.',
    'Try mashing the button.',
    'Idle now? Push fires immediately.',
  ];

  @override
  void initState() {
    super.initState();
    _cubit = FaderCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _push() {
    final text = _quips[_pushCount % _quips.length];
    _pushCount++;
    _cubit.push(text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 360,
            height: 80,
            child: Center(
              child: FaderWidget(cubit: _cubit, duration: widget.duration),
            ),
          ),
          const Gap(16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(onPressed: _push, child: const Text('Push next')),
              const Gap(12),
              TextButton(
                onPressed: () {
                  _cubit.clear();
                  setState(() {});
                },
                child: const Text('Clear queue'),
              ),
            ],
          ),
          const Gap(8),
          Text('queue depth: ${_cubit.state.queue.length}'),
        ],
      ),
    );
  }
}

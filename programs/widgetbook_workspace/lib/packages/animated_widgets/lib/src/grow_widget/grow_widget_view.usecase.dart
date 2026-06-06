// lib/packages/animated_widgets/lib/src/grow_widget/grow_widget_view.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: GrowWidgetView)
Widget growWidgetViewUseCase(BuildContext context) {
  final durationMs = context.knobs.int.slider(
    label: 'duration (ms)',
    initialValue: 700,
    min: 100,
    max: 3000,
  );

  final curve = context.knobs.object.dropdown<Curve>(
    label: 'curve',
    options: const [
      Curves.easeOut,
      Curves.easeIn,
      Curves.easeInOut,
      Curves.bounceOut,
      Curves.elasticOut,
      Curves.linear,
    ],
    initialOption: Curves.easeOut,
    labelBuilder: _curveLabel,
  );

  return _GrowShowcase(
    duration: Duration(milliseconds: durationMs),
    curve: curve,
  );
}

String _curveLabel(Curve curve) {
  if (curve == Curves.easeOut) return 'easeOut';
  if (curve == Curves.easeIn) return 'easeIn';
  if (curve == Curves.easeInOut) return 'easeInOut';
  if (curve == Curves.bounceOut) return 'bounceOut';
  if (curve == Curves.elasticOut) return 'elasticOut';
  if (curve == Curves.linear) return 'linear';
  return curve.toString();
}

class _GrowShowcase extends StatefulWidget {
  const _GrowShowcase({required this.duration, required this.curve});

  final Duration duration;
  final Curve curve;

  @override
  State<_GrowShowcase> createState() => _GrowShowcaseState();
}

class _GrowShowcaseState extends State<_GrowShowcase> {
  Key _key = UniqueKey();
  bool _done = false;

  void _restart() => setState(() {
    _key = UniqueKey();
    _done = false;
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: GrowWidgetView(
              key: _key,
              duration: widget.duration,
              curve: widget.curve,
              onComplete: () => setState(() => _done = true),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
          const Gap(16),
          Text(_done ? 'complete ✓' : 'growing…'),
          const Gap(8),
          FilledButton.tonal(onPressed: _restart, child: const Text('Restart')),
        ],
      ),
    );
  }
}

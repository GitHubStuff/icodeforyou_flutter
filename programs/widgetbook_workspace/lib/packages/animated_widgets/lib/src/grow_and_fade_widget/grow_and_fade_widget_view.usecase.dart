// lib/packages/animated_widgets/lib/src/grow_and_fade_widget/grow_and_fade_widget_view.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: GrowAndFadeWidgetView)
Widget growAndFadeWidgetViewUseCase(BuildContext context) {
  final durationMs = context.knobs.int.slider(
    label: 'duration (ms)',
    initialValue: 900,
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

  return _GrowAndFadeShowcase(
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

class _GrowAndFadeShowcase extends StatefulWidget {
  const _GrowAndFadeShowcase({required this.duration, required this.curve});

  final Duration duration;
  final Curve curve;

  @override
  State<_GrowAndFadeShowcase> createState() => _GrowAndFadeShowcaseState();
}

class _GrowAndFadeShowcaseState extends State<_GrowAndFadeShowcase> {
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
            width: 240,
            height: 240,
            child: GrowAndFadeWidgetView(
              key: _key,
              duration: widget.duration,
              curve: widget.curve,
              onComplete: () => setState(() => _done = true),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),
          const Gap(16),
          Text(_done ? 'complete ✓' : 'animating…'),
          const Gap(8),
          FilledButton.tonal(onPressed: _restart, child: const Text('Restart')),
        ],
      ),
    );
  }
}

// lib/packages/animated_widgets/lib/src/fade_in_out_view/fade_in_out_view.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: FadeInOutView)
Widget fadeInOutViewUseCase(BuildContext context) {
  final fadeIn = context.knobs.boolean(
    label: 'fade in (0 → 1)',
    initialValue: true,
  );

  final duration = Duration(
    milliseconds: context.knobs.int.slider(
      label: 'duration (ms)',
      initialValue: 1200,
      min: 200,
      max: 5000,
    ),
  );

  return _FadeShowcase(fadeIn: fadeIn, duration: duration);
}

class _FadeShowcase extends StatefulWidget {
  const _FadeShowcase({required this.fadeIn, required this.duration});

  final bool fadeIn;
  final Duration duration;

  @override
  State<_FadeShowcase> createState() => _FadeShowcaseState();
}

class _FadeShowcaseState extends State<_FadeShowcase> {
  Key _key = UniqueKey();
  bool _complete = false;

  void _restart() {
    setState(() {
      _key = UniqueKey();
      _complete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: FadeInOutView(
              key: _key,
              duration: widget.duration,
              startOpacity: widget.fadeIn ? 0.0 : 1.0,
              endOpacity: widget.fadeIn ? 1.0 : 0.0,
              onComplete: () => setState(() => _complete = true),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'fade me',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              ),
            ),
          ),
          const Gap(16),
          Text(_complete ? 'complete ✓' : 'animating…'),
          const Gap(8),
          FilledButton.tonal(onPressed: _restart, child: const Text('Restart')),
        ],
      ),
    );
  }
}

// widgetbook/lib/animated_widgets/fade_in_out_view/fade_in_out_view.usecase.dart

// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart' show FadeInOutView;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: FadeInOutView)
Widget fadeInOutViewUseCase(BuildContext context) {
  final durationMs = context.knobs.int.slider(
    label: 'Duration (ms)',
    initialValue: 1000,
    min: 50,
    max: 5000,
  );

  final startOpacity = context.knobs.double.slider(
    label: 'Start opacity',
    initialValue: 1,
    min: 0,
    max: 1,
  );

  final endOpacity = context.knobs.double.slider(
    label: 'End opacity',
    initialValue: 0,
    min: 0,
    max: 1,
  );

  final curve = context.knobs.list<Curve>(
    label: 'Curve',
    options: [
      Curves.linear,
      Curves.easeIn,
      Curves.easeOut,
      Curves.easeInOut,
      Curves.easeInQuart,
      Curves.easeOutQuart,
      Curves.bounceOut,
      Curves.elasticOut,
    ],
    initialOption: Curves.easeInOut,
    labelBuilder: _curveName,
  );

  final label = context.knobs.string(
    label: 'Child label',
    initialValue: 'Fading',
  );

  return _FadeInOutViewUseCaseBody(
    durationMs: durationMs,
    startOpacity: startOpacity,
    endOpacity: endOpacity,
    curve: curve,
    label: label,
  );
}

String _curveName(Curve curve) {
  if (curve == Curves.linear) return 'linear';
  if (curve == Curves.easeIn) return 'easeIn';
  if (curve == Curves.easeOut) return 'easeOut';
  if (curve == Curves.easeInOut) return 'easeInOut';
  if (curve == Curves.easeInQuart) return 'easeInQuart';
  if (curve == Curves.easeOutQuart) return 'easeOutQuart';
  if (curve == Curves.bounceOut) return 'bounceOut';
  if (curve == Curves.elasticOut) return 'elasticOut';
  return curve.toString();
}

class _FadeInOutViewUseCaseBody extends StatefulWidget {
  const _FadeInOutViewUseCaseBody({
    required this.durationMs,
    required this.startOpacity,
    required this.endOpacity,
    required this.curve,
    required this.label,
  });

  final int durationMs;
  final double startOpacity;
  final double endOpacity;
  final Curve curve;
  final String label;

  @override
  State<_FadeInOutViewUseCaseBody> createState() =>
      _FadeInOutViewUseCaseBodyState();
}

class _FadeInOutViewUseCaseBodyState extends State<_FadeInOutViewUseCaseBody> {
  // Bumped on every Replay tap so the FadeInOutView gets a fresh key and
  // restarts. FadeInOutView animates once on init; without a key change it
  // won't replay.
  int _replay = 0;
  bool _completed = false;

  void _restart() {
    setState(() {
      _replay++;
      _completed = false;
    });
  }

  @override
  void didUpdateWidget(covariant _FadeInOutViewUseCaseBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Any knob change should restart the animation so the user sees the new
    // settings take effect.
    if (oldWidget.durationMs != widget.durationMs ||
        oldWidget.startOpacity != widget.startOpacity ||
        oldWidget.endOpacity != widget.endOpacity ||
        oldWidget.curve != widget.curve ||
        oldWidget.label != widget.label) {
      _replay++;
      _completed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      body: Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FadeInOutView(
                key: ValueKey(_replay),
                duration: Duration(milliseconds: widget.durationMs),
                startOpacity: widget.startOpacity,
                endOpacity: widget.endOpacity,
                curve: widget.curve,
                onComplete: () {
                  if (mounted) setState(() => _completed = true);
                },
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _completed ? 'onComplete fired' : 'animating…',
                  style: TextStyle(
                    color: _completed ? Colors.green.shade800 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.refresh),
                  label: const Text('REPLAY'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

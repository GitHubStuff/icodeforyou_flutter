// packages/demo/lib/sequenced_animations_demo/sequenced_animations_demo.dart

import 'package:flutter/material.dart';
import 'package:sequenced_animations/sequenced_animations.dart'
    show
        AnimationRange,
        RangeSequenceWidget,
        SequencedGrow,
        SequencedOpacity,
        SequencedRotation;

/// Fade, rotation and grow sequences driven by one shared controller,
/// with Play / Rewind / Pause / Loop transport buttons.
class SequencedAnimationsDemo extends StatefulWidget {
  const SequencedAnimationsDemo({super.key});

  @override
  State<SequencedAnimationsDemo> createState() =>
      _SequencedAnimationsDemoState();
}

class _SequencedAnimationsDemoState extends State<SequencedAnimationsDemo>
    with SingleTickerProviderStateMixin {
  static const _fadeRanges = <AnimationRange>[
    AnimationRange(0, 1, duration: Duration(seconds: 1)),
    AnimationRange(1, 0.3, duration: Duration(seconds: 1)),
    AnimationRange(0.3, 1, duration: Duration(seconds: 1)),
  ];

  static const _rotateRanges = <AnimationRange>[
    AnimationRange(0, 0.5, duration: Duration(seconds: 2)),
    AnimationRange(0.5, 1, duration: Duration(seconds: 1)),
  ];

  static const _growRanges = <AnimationRange>[
    AnimationRange(
      0.25,
      1.5,
      duration: Duration(seconds: 2),
      curve: Curves.easeOut,
    ),
    AnimationRange(
      1.5,
      1,
      duration: Duration(seconds: 1),
      curve: Curves.easeIn,
    ),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: RangeSequenceWidget.totalDuration(_fadeRanges),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() => _controller.forward(from: 0);

  void _rewind() => _controller.reverse();

  void _pause() => _controller.stop();

  void _loop() => _controller.repeat(reverse: true);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(child: Center(child: _animations())),
      Padding(
        padding: const EdgeInsets.all(16),
        child: _transport(),
      ),
    ],
  );

  Widget _animations() => SequencedOpacity(
    controller: _controller,
    ranges: _fadeRanges,
    child: SequencedRotation(
      controller: _controller,
      ranges: _rotateRanges,
      child: SequencedGrow(
        controller: _controller,
        ranges: _growRanges,
        child: const FlutterLogo(size: 120),
      ),
    ),
  );

  Widget _transport() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          _TransportButton(label: 'Play', onPressed: _play),
          const SizedBox(width: 8),
          _TransportButton(label: 'Rewind', onPressed: _rewind),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          _TransportButton(label: 'Pause', onPressed: _pause),
          const SizedBox(width: 8),
          _TransportButton(label: 'Loop', onPressed: _loop),
        ],
      ),
    ],
  );
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Expanded(
    child: FilledButton(onPressed: onPressed, child: Text(label)),
  );
}

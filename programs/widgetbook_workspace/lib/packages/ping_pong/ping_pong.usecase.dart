// programs/widgetbook_workspace/lib/packages/ping_pong/ping_pong.usecase.dart
import 'dart:async' show unawaited;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:ping_pong/ping_pong.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Smallest ball radius in the demo, in logical pixels.
const double minRadius = 20;

/// Largest ball radius in the demo, in logical pixels.
const double maxRadius = 100;

/// Asset path, relative to `assets/`, of the clip played on eviction.
const String evictionSound = 'sounds/evict.wav';

/// Interactive use case: ball-count slider, recycle toggle, and
/// start / pause / reset.
@widgetbook.UseCase(name: 'Interactive', type: PingPong)
Widget interactivePingPong(BuildContext context) {
  final ballCount = context.knobs.int.slider(
    label: 'Ball count',
    initialValue: 10,
    min: 0,
    max: 100,
  );
  final recycle = context.knobs.boolean(
    label: 'Recycle',
    initialValue: true,
  );
  return PingPongDemo(ballCount: ballCount, recycle: recycle);
}

/// Owns a [PingPongController] and an [AudioPlayer], and drives a
/// [PingPong] with buttons. Plays [evictionSound] whenever a ball is
/// evicted to make room for another.
class PingPongDemo extends StatefulWidget {
  /// Creates a demo arena holding [ballCount] balls.
  const PingPongDemo({
    required this.ballCount,
    required this.recycle,
    super.key,
  });

  /// How many balls to feed into the arena.
  final int ballCount;

  /// Whether balls that cannot spawn evict the oldest on screen.
  final bool recycle;

  @override
  State<PingPongDemo> createState() => _PingPongDemoState();
}

class _PingPongDemoState extends State<PingPongDemo> {
  final _controller = PingPongController();
  final _player = AudioPlayer();

  @override
  void dispose() {
    _controller.dispose();
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        // The Builder gives the balls a context *inside* the Scaffold,
        // so ScaffoldMessenger.of resolves to the messenger above it.
        body: Builder(builder: _buildBody),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        _Controls(controller: _controller),
        Expanded(
          child: PingPong(
            controller: _controller,
            recycle: widget.recycle,
            onEvicted: _playEvictionSound,
            pingpongBall: [
              for (var index = 0; index < widget.ballCount; index++)
                _ball(context, index + 1, borderColor),
            ],
          ),
        ),
        _Status(controller: _controller),
      ],
    );
  }

  void _playEvictionSound(int index) =>
      unawaited(_player.play(AssetSource(evictionSound)));

  PingPongBall _ball(BuildContext context, int index, Color borderColor) {
    final color = Colors.primaries[index % Colors.primaries.length];
    return PingPongBall(
      radius: _radiusFor(index),
      border: borderColor,
      onTap: () => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Ball $index tapped'))),
      child: ColoredBox(
        color: color,
        child: Center(
          child: Text(
            'Ball $index',
            style: TextStyle(
              color:
                  ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Spreads radii evenly from [minRadius] to [maxRadius] across the
  /// list, so every size in the range is represented.
  double _radiusFor(int index) {
    final count = widget.ballCount;
    if (count <= 1) return minRadius;
    return minRadius + (maxRadius - minRadius) * index / (count - 1);
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller});

  final PingPongController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: controller.isRunning ? null : controller.start,
              child: const Text('Start'),
            ),
            FilledButton(
              onPressed: controller.isRunning ? controller.pause : null,
              child: const Text('Pause'),
            ),
            OutlinedButton(
              onPressed: controller.reset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.controller});

  final PingPongController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.isRunning ? 'Running' : 'Paused';
        final shown = controller.displayedCount;
        final queued = controller.queuedCount;
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text('$state · $shown on screen · $queued queued'),
        );
      },
    );
  }
}

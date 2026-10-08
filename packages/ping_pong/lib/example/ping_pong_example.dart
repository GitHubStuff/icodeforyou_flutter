// packages/ping_pong/lib/example/ping_pong_example.dart

import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:ping_pong/ping_pong.dart' show PingPong;
import 'package:ping_pong/src/ping_pong_ball.dart' show PingPongBall;
import 'package:ping_pong/src/ping_pong_controller.dart'
    show PingPongController;
import 'package:ping_pong/src/title_subtitle_text.dart' show TitleSubtitleText;

final Random _random = Random();

// Inclusive on both ends: 65 <= result <= 120.
int _randomBetween(Random random, {required int min, required int max}) =>
    min + random.nextInt(max - min + 1);

/// Smallest ball radius in the demo, in logical pixels.
///
/// Used for the first ball (index 0) and for every ball when the demo
/// contains a single ball.
const double _minRadius = 65;

/// Largest ball radius in the demo, in logical pixels.
///
/// Used for the last ball; intermediate balls are interpolated linearly
/// between [_minRadius] and [_maxRadius].
const double _maxRadius = 200;

/// Standalone example showcasing [PingPong] with dynamic ball counts,
/// recycling toggle, start/pause/reset controls, and eviction sound effects.
///
/// The example is self-contained: it owns its [PingPongController] and
/// [AudioPlayer], hosts its own [ScaffoldMessenger] so tap feedback does
/// not leak into an enclosing app, and exposes the same knobs a Widgetbook
/// use-case would (ball count and recycling) as in-widget controls.
///
/// Layout, top to bottom:
///
/// * `_KnobsBar` — ball-count slider and recycle switch.
/// * `_Controls` — start, pause and reset buttons.
/// * [PingPong] — the animated arena, filling the remaining space.
/// * `_Status` — running state plus on-screen and queued counts.
class PingPongExample extends StatefulWidget {
  /// Creates the ping-pong demo screen.
  const PingPongExample({super.key});

  @override
  State<PingPongExample> createState() => _PingPongExampleState();
}

/// State for [PingPongExample].
///
/// Owns the [PingPongController] and [AudioPlayer] for the lifetime of the
/// widget and disposes both when the widget is removed from the tree.
class _PingPongExampleState extends State<PingPongExample> {
  /// Drives the [PingPong] animation and exposes its counts.
  final _controller = PingPongController();

  /// Number of balls currently supplied to [PingPong].
  int _ballCount = 75;

  /// Whether evicted balls are re-queued rather than discarded.
  bool _recycle = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Plays [evictionSound] in response to [PingPong] evicting ball [index].
  ///
  /// The index is accepted to match the `onEvicted` signature but is not
  /// otherwise used; every eviction plays the same clip.
  void _playEvictionSound(int index) => debugPrint('Evicted $index');

  /// Returns the radius for the ball at zero-based [index].
  ///
  /// Interpolates linearly from [_minRadius] at index 0 to [_maxRadius] at
  /// index `_ballCount - 1`. When there is at most one ball the result is
  /// always [_minRadius], which also avoids a division by zero.
  double _radiusFor(int index) {
    if (_ballCount <= 1) return _minRadius;
    return _minRadius + (_maxRadius - _minRadius) * index / (_ballCount - 1);
  }

  /// Builds the [PingPongBall] shown at [index].
  ///
  /// The fill colour cycles through [Colors.primaries]; the label colour is
  /// chosen for contrast against that fill. [borderColor] is applied to the
  /// ball's outline. Tapping a ball shows a [SnackBar] via the
  /// [ScaffoldMessenger] found in [context], replacing any snack bar that
  /// is already visible.
  PingPongBall _ball(BuildContext context, int index, Color borderColor) {
    final color = Colors.primaries[index % Colors.primaries.length];
    final radius = _randomBetween(_random, min: 87, max: 89).toDouble();

    final title = index.toString().padLeft(8, '_');
    final rad = radius.toInt().toString().padLeft(5, '_');
    return PingPongBall(
      radius: radius,
      border: borderColor,
      onTap: () => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Ball $index tapped'))),
      child: ColoredBox(
        color: color,
        child: Center(
          child: Center(
            child: TitleSubtitleText(
              title: title,
              caption: rad,
              backgroundColor: color,
              radius: radius,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ping Pong Demo'),
        ),
        body: Builder(
          builder: (context) {
            final borderColor = Theme.of(context).colorScheme.onSurface;

            return Column(
              children: [
                // Settings replacing Widgetbook knobs
                _KnobsBar(
                  ballCount: _ballCount,
                  recycle: _recycle,
                  onBallCountChanged: (val) => setState(() => _ballCount = val),
                  onRecycleChanged: (val) => setState(() => _recycle = val),
                ),
                _Controls(controller: _controller),
                Expanded(
                  child: PingPong(
                    controller: _controller,
                    recycle: _recycle,
                    onEvicted: _playEvictionSound,
                    speed: 30.1,
                    retryCap: 150,
                    pingpongBall: [
                      for (var index = 0; index < _ballCount; index++)
                        _ball(context, index + 1, borderColor),
                    ],
                  ),
                ),
                _Status(controller: _controller),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Settings strip standing in for Widgetbook knobs.
///
/// Presents a slider for the ball count (0–100) and a switch for recycling.
/// This widget is stateless; the owning widget holds the values and
/// receives changes through [onBallCountChanged] and [onRecycleChanged].
class _KnobsBar extends StatelessWidget {
  /// Creates the knobs bar.
  const _KnobsBar({
    required this.ballCount,
    required this.recycle,
    required this.onBallCountChanged,
    required this.onRecycleChanged,
  });

  /// Current ball count shown by the slider and its label.
  final int ballCount;

  /// Current recycle setting shown by the switch.
  final bool recycle;

  /// Called with the new integer ball count whenever the slider moves.
  final ValueChanged<int> onBallCountChanged;

  /// Called with the new value whenever the recycle switch is toggled.
  final ValueChanged<bool> onRecycleChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text('Balls: $ballCount'),
            Expanded(
              child: Slider(
                value: ballCount.toDouble(),
                min: 0,
                max: 400,
                divisions: 100,
                label: '$ballCount',
                onChanged: (val) => onBallCountChanged(val.round()),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Recycle'),
            Switch(
              value: recycle,
              onChanged: onRecycleChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// Start / pause / reset buttons bound to a [PingPongController].
///
/// Rebuilds whenever [controller] notifies, so **Start** is disabled while
/// running and **Pause** is disabled while paused. **Reset** is always
/// enabled.
class _Controls extends StatelessWidget {
  /// Creates the control bar for [controller].
  const _Controls({required this.controller});

  /// Controller whose [PingPongController.start], [PingPongController.pause]
  /// and [PingPongController.reset] the buttons invoke.
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

/// One-line status read-out for a [PingPongController].
///
/// Shows whether the animation is running, how many balls are currently on
/// screen ([PingPongController.displayedCount]) and how many are waiting to
/// enter ([PingPongController.queuedCount]). Rebuilds on every controller
/// notification.
class _Status extends StatelessWidget {
  /// Creates the status line for [controller].
  const _Status({required this.controller});

  /// Controller whose state and counts are displayed.
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

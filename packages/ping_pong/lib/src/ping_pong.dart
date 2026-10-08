// packages/ping_pong/lib/src/ping_pong.dart
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/widgets.dart';
import 'package:ping_pong/src/arena_config.dart' show ArenaConfig;
import 'package:ping_pong/src/ball_spec.dart' show BallSpec;
import 'package:ping_pong/src/ball_state.dart' show BallState;
import 'package:ping_pong/src/ping_pong_ball.dart' show PingPongBall;
import 'ping_pong_controller.dart' show PingPongController;

/// Bounces a list of [PingPongBall]s around its own bounds.
///
/// Balls appear one at a time, in list order, [spawnInterval] apart,
/// each at a random non-overlapping position. They reflect off the
/// edges of this widget and off each other. Nothing happens until
/// [PingPongController.start] is called.
///
/// With [recycle] on, a ball that cannot find room evicts the oldest
/// ball on screen, which goes to the back of the spawn queue, so every
/// ball in the list is eventually shown even when they cannot all fit
/// at once. An evicted ball leaves the simulation at once and shrinks
/// away over its [PingPongBall.exitDuration]; [onSpawned] and
/// [onEvicted] report both events, the latter as the shrink begins,
/// and [haptic] fires at the same moment.
///
/// If [spawnInterval] is shorter than a ball's exit duration, that
/// ball can reappear at a new spot while its old self is still
/// shrinking. This is allowed; with realistic sizes it does not occur.
///
/// A resize or rotation, a change to the ball list, or a change to the
/// platform's reduced-motion setting clears the arena and restarts the
/// spawn sequence. When reduced motion is on, every ball that fits is
/// placed at once, nothing moves, and nothing is recycled.
class PingPong extends StatefulWidget {
  /// Creates the arena. [controller] is owned by the caller.
  const PingPong({
    required this.controller,
    required this.pingpongBall,
    this.speed = defaultSpeed,
    this.spawnInterval = defaultSpawnInterval,
    this.retryCap = defaultRetryCap,
    this.haptic = HapticIntensity.light,
    this.emptyMessage = defaultEmptyMessage,
    this.recycle = true,
    this.onSpawned,
    this.onEvicted,
    super.key,
  }) : assert(speed >= 0, 'speed must not be negative'),
       assert(retryCap > 0, 'retryCap must be at least 1');

  /// Default global speed in logical pixels per second.
  static const double defaultSpeed = 120;

  /// Default time between one ball appearing and the next.
  static const Duration defaultSpawnInterval = Duration(seconds: 1);

  /// Default number of spawn positions tried per interval.
  static const int defaultRetryCap = 25;

  /// Default text shown when [pingpongBall] is empty.
  static const String defaultEmptyMessage = 'No Ping Pong balls';

  /// Drives the simulation. Call `start()` on it to begin.
  final PingPongController controller;

  /// The balls, in spawn order. Never mutated by this widget.
  final List<PingPongBall> pingpongBall;

  /// Speed for every ball that does not set its own
  /// [PingPongBall.speed], in logical pixels per second.
  final double speed;

  /// Time between one ball appearing and the next.
  final Duration spawnInterval;

  /// Random positions to try before giving up on a spawn for the
  /// current interval; the ball is retried at the next interval.
  final int retryCap;

  /// Haptic fired as each ball is evicted to make room for another.
  final HapticIntensity haptic;

  /// Text shown when [pingpongBall] is empty.
  final String emptyMessage;

  /// Whether a ball that cannot spawn evicts the oldest ball on screen.
  final bool recycle;

  /// Called with the list index of each ball as it appears.
  final ValueChanged<int>? onSpawned;

  /// Called with the list index of each ball as its eviction begins.
  final ValueChanged<int>? onEvicted;

  @override
  State<PingPong> createState() => _PingPongState();
}

class _PingPongState extends State<PingPong>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  ArenaConfig? _config;
  final List<_Exit> _exits = [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _attach(widget.controller);
  }

  @override
  void didUpdateWidget(PingPong oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    _detach(oldWidget.controller);
    _config = null;
    _attach(widget.controller);
  }

  @override
  void dispose() {
    _detach(widget.controller);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pingpongBall.isEmpty) {
      return Center(child: Text(widget.emptyMessage));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        _configureIfChanged(context, constraints.biggest);
        return ListenableBuilder(
          listenable: widget.controller,
          builder: (_, __) => _buildArena(),
        );
      },
    );
  }

  Widget _buildArena() {
    return Stack(
      children: [
        for (final ball in widget.controller.balls)
          Positioned(
            key: ValueKey(ball.index),
            left: ball.center.dx - ball.radius,
            top: ball.center.dy - ball.radius,
            child: widget.pingpongBall[ball.index],
          ),
        for (final exit in _exits)
          _ExitingBall(
            key: ObjectKey(exit),
            exit: exit,
            onEnd: () => _removeExit(exit),
          ),
      ],
    );
  }

  void _configureIfChanged(BuildContext context, Size bounds) {
    final config = ArenaConfig(
      bounds: bounds,
      specs: [
        for (final ball in widget.pingpongBall)
          BallSpec(radius: ball.radius, speed: ball.speed ?? widget.speed),
      ],
      spawnInterval: widget.spawnInterval,
      retryCap: widget.retryCap,
      motionless: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
      recycle: widget.recycle,
    );
    if (config == _config) return;
    _config = config;
    // The arena restarts, so any ball still shrinking away is dropped.
    _exits.clear();
    // Configuring notifies listeners, which is illegal mid-build.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.controller.configure(config),
    );
  }

  void _attach(PingPongController controller) {
    controller
      ..onSpawned = _onSpawned
      ..onEvicted = _onEvicted
      ..addListener(_syncTicker);
    _syncTicker();
  }

  void _detach(PingPongController controller) {
    controller
      ..onSpawned = null
      ..onEvicted = null
      ..removeListener(_syncTicker);
  }

  void _syncTicker() {
    final shouldRun = widget.controller.isRunning;
    if (shouldRun && !_ticker.isActive) {
      _lastElapsed = Duration.zero;
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    widget.controller.advance(delta);
  }

  void _onSpawned(int index) => widget.onSpawned?.call(index);

  void _onEvicted(BallState state) {
    final ball = widget.pingpongBall[state.index];
    if (ball.exitDuration > Duration.zero) {
      setState(() => _exits.add(_Exit(state: state, ball: ball)));
    }
    widget.haptic.trigger();
    widget.onEvicted?.call(state.index);
  }

  void _removeExit(_Exit exit) => setState(() => _exits.remove(exit));
}

/// A snapshot of an evicted ball, captured so the exit animation keeps
/// drawing the right widget at the right place even if the list or
/// the simulation moves on underneath it.
class _Exit {
  const _Exit({required this.state, required this.ball});

  final BallState state;
  final PingPongBall ball;
}

/// Draws an evicted ball at its final position and shrinks it to
/// nothing about its centre. Ignores pointers: a ball that is leaving
/// should not take taps.
class _ExitingBall extends StatelessWidget {
  const _ExitingBall({required this.exit, required this.onEnd, super.key});

  final _Exit exit;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final state = exit.state;
    final ball = exit.ball;
    return Positioned(
      left: state.center.dx - state.radius,
      top: state.center.dy - state.radius,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: 0),
          duration: ball.exitDuration,
          curve: ball.evictionCurve,
          onEnd: onEnd,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: ball,
        ),
      ),
    );
  }
}

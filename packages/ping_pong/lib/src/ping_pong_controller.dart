// packages/ping_pong/lib/src/ping_pong_controller.dart
import 'dart:collection' show UnmodifiableListView;
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:ping_pong/src/arena_config.dart' show ArenaConfig;
import 'package:ping_pong/src/ball_state.dart' show BallState;
import 'package:ping_pong/src/ball_too_large_error.dart' show BallTooLargeError;
import 'package:ping_pong/src/ping_physics.dart' show PingPhysics;

/// Drives the ping-pong simulation: spawning, movement, collisions and
/// recycling.
///
/// The public surface for callers is [start], [pause], [reset],
/// [isRunning], [allSpawned], [displayedCount] and [queuedCount]. The
/// remaining members are the seam the `PingPong` widget uses to feed
/// layout and time into the simulation and are marked `@internal`.
///
/// Balls wait in a spawn queue in list order. When [ArenaConfig.recycle]
/// is on and a ball cannot find room, the oldest ball on screen is
/// evicted and sent to the back of the queue, so the whole list is
/// eventually shown even when it cannot all fit at once. The caller's
/// list is never touched: the queue holds indices into it.
///
/// The controller owns no time source. The widget feeds it elapsed
/// time through [advance] on every frame, which keeps the whole
/// simulation deterministic and testable without a ticker.
///
/// The caller owns the controller's lifecycle and must call [dispose].
class PingPongController extends ChangeNotifier {
  /// Creates a controller.
  ///
  /// Pass a seeded [random] for deterministic tests. [physics] can be
  /// replaced to test the controller in isolation.
  PingPongController({
    Random? random,
    PingPhysics physics = const PingPhysics(),
  }) : _random = random ?? Random(),
       _physics = physics;

  final Random _random;
  final PingPhysics _physics;

  final List<BallState> _balls = [];
  final List<int> _queue = [];
  ArenaConfig? _config;
  Duration _sinceSpawn = Duration.zero;
  bool _isRunning = false;

  /// Called with the list index of each ball as it appears.
  @internal
  ValueChanged<int>? onSpawned;

  /// Called with the final state of each ball as it is evicted to make
  /// room for one that could not spawn. The ball has already left the
  /// simulation; the state is a snapshot for the exit animation.
  @internal
  ValueChanged<BallState>? onEvicted;

  /// Whether [advance] currently moves the simulation forward.
  bool get isRunning => _isRunning;

  /// Whether [configure] has been called.
  @internal
  bool get isConfigured => _config != null;

  /// Whether every ball in the list is currently on screen.
  bool get allSpawned => _config != null && _queue.isEmpty;

  /// How many balls are currently on screen.
  int get displayedCount => _balls.length;

  /// How many balls are waiting to spawn.
  int get queuedCount => _queue.length;

  /// The balls currently in the arena, in spawn order.
  @internal
  List<BallState> get balls => UnmodifiableListView(_balls);

  /// Replaces the arena and clears every ball.
  ///
  /// Spawning starts over from the first spec on the next [advance]
  /// if the controller is running. The running state is unchanged.
  ///
  /// Throws a [BallTooLargeError] if any ball could never fit inside
  /// the arena; the previous configuration, if any, is kept.
  @internal
  void configure(ArenaConfig config) {
    _throwIfAnyBallTooLarge(config);
    _config = config;
    _clear();
    notifyListeners();
  }

  /// Starts the simulation. No-op if already running.
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    notifyListeners();
  }

  /// Pauses the simulation. No-op if already paused.
  void pause() {
    if (!_isRunning) return;
    _isRunning = false;
    notifyListeners();
  }

  /// Clears every ball and restarts spawning from the first spec.
  ///
  /// The running state is unchanged.
  void reset() {
    _clear();
    notifyListeners();
  }

  /// Moves the simulation forward by [delta].
  ///
  /// Does nothing unless the controller is running and configured.
  @internal
  void advance(Duration delta) {
    final config = _config;
    if (!_isRunning || config == null) return;

    if (config.motionless) {
      _advanceMotionless(config);
    } else {
      _advanceMoving(config, delta);
    }
  }

  void _throwIfAnyBallTooLarge(ArenaConfig config) {
    for (var index = 0; index < config.specs.length; index++) {
      final radius = config.specs[index].radius;
      final diameter = radius * 2;
      if (diameter > config.bounds.width || diameter > config.bounds.height) {
        throw BallTooLargeError(
          index: index,
          radius: radius,
          bounds: config.bounds,
        );
      }
    }
  }

  void _advanceMotionless(ArenaConfig config) {
    final before = _balls.length;
    while (!allSpawned && _trySpawn(config, motionless: true)) {}
    if (_balls.length != before) notifyListeners();
  }

  void _advanceMoving(ArenaConfig config, Duration delta) {
    _spawnIfDue(config, delta);
    _moveAndBounce(config, delta);
    _collideBalls();
    notifyListeners();
  }

  void _spawnIfDue(ArenaConfig config, Duration delta) {
    if (allSpawned) return;
    _sinceSpawn += delta;
    if (_sinceSpawn < config.spawnInterval) return;
    _sinceSpawn = Duration.zero;

    final spawned = _trySpawn(config, motionless: false);
    if (!spawned && config.recycle) _evictOldest();
  }

  /// Spawns the ball at the head of the queue. Returns `false` when no
  /// room was found; the ball stays at the head for the next attempt.
  bool _trySpawn(ArenaConfig config, {required bool motionless}) {
    final index = _queue.first;
    final ball = _physics.spawn(
      index: index,
      spec: config.specs[index],
      bounds: config.bounds,
      others: _balls,
      random: _random,
      retryCap: config.retryCap,
      motionless: motionless,
    );
    if (ball == null) return false;
    _queue.removeAt(0);
    _balls.add(ball);
    onSpawned?.call(index);
    return true;
  }

  /// Removes the oldest ball on screen and sends it to the back of the
  /// queue. Only reached after a failed spawn, which — because
  /// [configure] rejects balls that cannot fit — means the arena is
  /// not empty.
  void _evictOldest() {
    final evicted = _balls.removeAt(0);
    _queue.add(evicted.index);
    onEvicted?.call(evicted);
  }

  void _clear() {
    _balls.clear();
    _queue
      ..clear()
      ..addAll(List.generate(_config?.specs.length ?? 0, (index) => index));
    // Start the clock already "due" so the first ball appears as soon
    // as the simulation runs; the interval applies between balls.
    _sinceSpawn = _config?.spawnInterval ?? Duration.zero;
  }

  void _moveAndBounce(ArenaConfig config, Duration delta) {
    for (var i = 0; i < _balls.length; i++) {
      final moved = _physics.move(_balls[i], delta);
      _balls[i] = _physics.reflectOffWalls(moved, config.bounds).ball;
    }
  }

  void _collideBalls() {
    for (var i = 0; i < _balls.length; i++) {
      for (var j = i + 1; j < _balls.length; j++) {
        final result = _physics.resolveCollision(_balls[i], _balls[j]);
        if (!result.collided) continue;
        _balls[i] = result.first;
        _balls[j] = result.second;
      }
    }
  }
}

// packages/sized_spinner/lib/src/spinner_controller.dart

import 'package:flutter/foundation.dart';
import 'package:sized_spinner/src/spin_widget/constants.dart' show degreesPerTurn;

/// Controls a [SpinWidget].
///
/// Angles are expressed in degrees at the public boundary and in turns
/// (`0.0 ..< 1.0`) internally. [rpm] is signed: a positive value spins
/// clockwise, a negative value spins counter-clockwise. Zero is not a valid
/// speed; use [stop] to stop.
///
/// The owner that creates a [SpinController] is responsible for disposing it,
/// exactly as with a [TextEditingController].
class SpinController extends ChangeNotifier {
  /// Creates a controller with an initial signed [rpm].
  SpinController({double rpm = 1})
    : assert(rpm != 0, 'rpm must be non-zero; use stop() to stop.'),
      _rpm = rpm;

  double _rpm;
  double _baseTurns = 0;
  double _startTurns = 0;
  bool _isSpinning = false;
  bool _hasStarted = false;
  int _epoch = 0;
  ValueGetter<double>? _elapsedTurns;

  /// Revolutions per minute. Positive is clockwise, negative is
  /// counter-clockwise. Changing it while spinning takes effect immediately
  /// without a visible jump.
  double get rpm => _rpm;

  set rpm(double value) {
    assert(value != 0, 'rpm must be non-zero; use stop() to stop.');
    if (value == _rpm) {
      return;
    }
    _rebase();
    _rpm = value;
    notifyListeners();
  }

  /// Whether the spin direction is clockwise.
  bool get isClockwise => _rpm > 0;

  /// Whether the child is currently rotating.
  bool get isSpinning => _isSpinning;

  /// The angle passed to the most recent [start], in degrees.
  double get startAngle => _startTurns * degreesPerTurn;

  /// The current angle in degrees, `0.0 ..< 360.0`. Live while spinning.
  double get angle => turns * degreesPerTurn;

  /// The current angle in turns, `0.0 ..< 1.0`. Live while spinning.
  double get turns {
    if (!_isSpinning) {
      return _baseTurns;
    }
    final elapsed = _elapsedTurns?.call() ?? 0;
    final signed = isClockwise ? elapsed : -elapsed;
    return (_baseTurns + signed) % 1;
  }

  /// Duration of one full revolution at the current [rpm].
  Duration get period => Duration(
    microseconds: (Duration.microsecondsPerMinute / _rpm.abs()).round(),
  );

  /// Monotonic counter that increments every time the animation must be
  /// (re)started from [turns]. Consumed by [SpinWidget].
  int get epoch => _epoch;

  /// Begins spinning from [angle] degrees. [angle] is normalised modulo 360
  /// and remembered as [startAngle] for [reset].
  void start({double angle = 0}) {
    _startTurns = _toTurns(angle);
    _baseTurns = _startTurns;
    _hasStarted = true;
    _isSpinning = true;
    _epoch++;
    notifyListeners();
  }

  /// Continues spinning from the current [angle]. If [start] has never been
  /// called this behaves as `start()`.
  void resume() {
    if (!_hasStarted) {
      start();
      return;
    }
    if (_isSpinning) {
      return;
    }
    _isSpinning = true;
    _epoch++;
    notifyListeners();
  }

  /// Stops in place and returns the [angle] at the moment of the call.
  double stop() {
    if (_isSpinning) {
      _baseTurns = turns;
      _isSpinning = false;
      notifyListeners();
    }
    return angle;
  }

  /// Stops and sets the angle to [angle] degrees, or to [startAngle] when
  /// [angle] is omitted.
  void reset({double? angle}) {
    _isSpinning = false;
    _baseTurns = angle == null ? _startTurns : _toTurns(angle);
    notifyListeners();
  }

  /// Registers the widget that reports elapsed turns since the last [epoch].
  /// Exactly one [SpinWidget] may be attached at a time.
  void attach(ValueGetter<double> elapsedTurns) {
    assert(
      _elapsedTurns == null,
      'A SpinController may only be attached to one SpinWidget at a time.',
    );
    _elapsedTurns = elapsedTurns;
  }

  /// Unregisters the widget previously passed to [attach].
  void detach() {
    _rebase();
    _elapsedTurns = null;
  }

  /// Captures the live position as the new base so a subsequent speed or
  /// direction change continues from where the child currently is.
  void _rebase() {
    if (!_isSpinning) {
      return;
    }
    _baseTurns = turns;
    _epoch++;
  }

  static double _toTurns(double degrees) => (degrees / degreesPerTurn) % 1;
}

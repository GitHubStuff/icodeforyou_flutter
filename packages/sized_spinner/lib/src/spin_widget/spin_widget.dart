// packages/sized_spinner/lib/src/spin_widget.dart

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:sized_spinner/sized_spinner.dart' show SpinController;
import 'package:sized_spinner/src/spin_widget/constants.dart'
    show degreesPerTurn;

/// Radians in one full revolution.
const double _radiansPerTurn = 2 * math.pi;

/// Degrees advanced per frame above which motion reads as a strobe.
const double _smoothDegreesPerFrame = 15;

/// Degrees advanced per frame at which rotation direction becomes
/// undefined (Nyquist limit — the "wagon-wheel" effect).
const double _aliasingDegreesPerFrame = 180;

/// Spins [child] continuously at a signed revolutions-per-minute rate.
///
/// Provide a [SpinController] to drive it; when omitted the widget owns a
/// private controller seeded from [rpm] and [autoStart]. After construction
/// the controller is the single source of truth — [rpm] and [autoStart] are
/// initial values only.
class SpinWidget extends StatefulWidget {
  /// Creates a spinning wrapper around [child].
  const SpinWidget({
    required this.child,
    super.key,
    this.controller,
    this.rpm = 1,
    this.autoStart = false,
    this.alignment = Alignment.center,
    this.filterQuality,
  }) : assert(rpm != 0, 'rpm must be non-zero.');

  /// The widget to rotate.
  final Widget child;

  /// External controller. When null the widget creates and disposes its own.
  final SpinController? controller;

  /// Initial signed revolutions per minute, used only when [controller] is
  /// null. Positive is clockwise, negative is counter-clockwise.
  final double rpm;

  /// Whether to call [SpinController.start] on first build. Used only when
  /// [controller] is null.
  final bool autoStart;

  /// The pivot point of the rotation, relative to the child's bounds.
  final Alignment alignment;

  /// Sampling quality applied while rotating; see [Transform.filterQuality].
  final FilterQuality? filterQuality;

  @override
  State<SpinWidget> createState() => _SpinWidgetState();
}

class _SpinWidgetState extends State<SpinWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  SpinController? _ownedController;
  late SpinController _controller;
  int _appliedEpoch = -1;
  bool _wasSpinning = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this);
    _controller = _resolveController();
    _attach(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SpinWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    _detach(_controller);
    _disposeOwnedController();
    _controller = _resolveController();
    _attach(_controller);
    _appliedEpoch = -1;
    _sync();
  }

  @override
  void dispose() {
    _detach(_controller);
    _disposeOwnedController();
    _animation.dispose();
    super.dispose();
  }

  SpinController _resolveController() {
    final external = widget.controller;
    if (external != null) return external;

    final owned = SpinController(rpm: widget.rpm);

    if (widget.autoStart) owned.start();

    _ownedController = owned;
    return owned;
  }

  void _disposeOwnedController() {
    _ownedController?.dispose();
    _ownedController = null;
  }

  void _attach(SpinController controller) {
    controller
      ..attach(() => _animation.value)
      ..addListener(_sync);
  }

  void _detach(SpinController controller) {
    controller
      ..removeListener(_sync)
      ..detach();
  }

  void _sync() {
    final controller = _controller;
    if (!controller.isSpinning) {
      if (_wasSpinning) {
        _animation
          ..stop()
          ..value = 0;
        _wasSpinning = false;
      }
      // A reset while stopped changes the angle with no animation tick, so
      // force a frame.
      setState(() {});
      return;
    }
    if (_appliedEpoch == controller.epoch) {
      return;
    }
    assert(
      _debugCheckRpmAgainstRefreshRate(controller.rpm),
      'Unreachable: the refresh-rate check always returns true.',
    );
    _appliedEpoch = controller.epoch;
    _wasSpinning = true;
    _animation
      ..stop()
      ..value = 0
      ..repeat(period: controller.period);
  }

  bool _debugCheckRpmAgainstRefreshRate(double rpm) {
    final refreshRate = View.of(context).display.refreshRate;
    final degreesPerFrame =
        rpm.abs() * degreesPerTurn / Duration.secondsPerMinute / refreshRate;
    if (degreesPerFrame > _smoothDegreesPerFrame) {
      final smoothLimit =
          _smoothDegreesPerFrame *
          Duration.secondsPerMinute *
          refreshRate /
          degreesPerTurn;
      debugPrint(
        'SpinWidget: ${rpm.abs()} rpm advances '
        '${degreesPerFrame.toStringAsFixed(1)}° per frame at $refreshRate Hz '
        'and will look like a strobe. Keep |rpm| <= '
        '${smoothLimit.toStringAsFixed(0)} for smooth motion.',
      );
    }
    final aliasingLimit =
        _aliasingDegreesPerFrame *
        Duration.secondsPerMinute *
        refreshRate /
        degreesPerTurn;
    assert(
      degreesPerFrame <= _aliasingDegreesPerFrame,
      'SpinWidget: ${rpm.abs()} rpm exceeds the aliasing limit of '
      '${aliasingLimit.toStringAsFixed(0)} rpm at $refreshRate Hz; '
      'direction of rotation is undefined.',
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: RepaintBoundary(child: widget.child),
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.turns * _radiansPerTurn,
          alignment: widget.alignment,
          filterQuality: widget.filterQuality,
          child: child,
        );
      },
    );
  }
}

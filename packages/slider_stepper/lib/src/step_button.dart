// packages/slider_stepper/lib/src/step_button.dart
// ignore_for_file: comment_references

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:widget_themes/widget_themes.dart' show CrossFadeTheme;

/// A circular icon button that fires [onPressed] once on tap and
/// auto-repeats while the pointer remains pressed (long-press).
///
/// Tap → 1 step. Hold → initial delay, then repeat at [repeatInterval]
/// until release. Used by [SliderStepper] for the `(−)` / `(+)` controls,
/// but exposed publicly so callers can compose their own steppers.
class StepButton extends StatefulWidget {
  /// Creates a [StepButton].
  const StepButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.buttonSize,
    this.color,
    this.iconColor,
    this.initialDelay = const Duration(milliseconds: 350),
    this.repeatInterval = const Duration(milliseconds: 60),
    this.tooltip,
  });

  /// Icon shown at the centre of the button.
  final IconData icon;

  /// Fired on tap, and repeatedly while held.
  /// Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Diameter of the circular button. Defaults to 36 logical pixels.
  final double? buttonSize;

  /// Background colour. Defaults to the theme's primary container colour.
  final Color? color;

  /// Icon foreground colour. Defaults to the theme's on-primary-container.
  final Color? iconColor;

  /// Delay between the press starting and the first repeat firing.
  final Duration initialDelay;

  /// Cadence of subsequent repeats after [initialDelay] elapses.
  final Duration repeatInterval;

  /// Optional accessibility tooltip.
  final String? tooltip;

  @override
  State<StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<StepButton> {
  Timer? _initialDelayTimer;
  Timer? _repeatTimer;

  bool get _isEnabled => widget.onPressed != null;

  void _fire() => widget.onPressed?.call();

  /// Fires once for the press itself, then arms the hold-to-repeat timers.
  /// The single press fire lives here — there is no separate [onTap]
  /// handler — so one tap produces exactly one [_fire].
  void _startRepeat() {
    // Defensive: only ever invoked from an enabled onTapDown, so this never
    // fires through the widget — kept as a precondition for direct callers.
    if (!_isEnabled) return; // coverage:ignore-line
    _fire();
    _initialDelayTimer = Timer(widget.initialDelay, () {
      _repeatTimer = Timer.periodic(widget.repeatInterval, (_) => _fire());
    });
  }

  void _stopRepeat() {
    _initialDelayTimer?.cancel();
    _initialDelayTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = widget.color ?? scheme.primaryContainer;
    final fg = widget.iconColor ?? scheme.onPrimaryContainer;

    final Widget child = SizedBox(
      width: widget.buttonSize,
      height: widget.buttonSize,
      child: Material(
        color: _isEnabled ? bg : bg.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTapDown: _isEnabled ? (_) => _startRepeat() : null,
          onTapUp: _isEnabled ? (_) => _stopRepeat() : null,
          onTapCancel: _isEnabled ? _stopRepeat : null,
          child: Center(
            child: Icon(
              widget.icon,
              size:
                  (widget.buttonSize ?? CrossFadeTheme.of(context).buttonSize) *
                  0.55,
              color: _isEnabled ? fg : fg.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );

    final tooltip = widget.tooltip;
    if (tooltip == null) return child;
    return Tooltip(message: tooltip, child: child);
  }
}

// packages/slider_directional/lib/src/directional.dart
// ignore_for_file: always_use_package_imports, comment_references

import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';

import 'directional_controller.dart';
import 'slider_direction.dart';
import 'step_grid.dart';

/// A horizontal or vertical slider that snaps to a step grid, with optional
/// haptic feedback when the value crosses into a new step bucket during drag.
///
/// State is held externally in a [DirectionalController]. Writes to the
/// controller rebuild only the slider's subtree — the parent widget does not
/// rebuild.
///
/// ### Direction
///
/// The [direction] parameter controls both axis and origin:
///
/// - [SliderDirection.left]   — horizontal, min on the left, max on the right.
/// - [SliderDirection.right]  — horizontal, min on the right, max on the left.
/// - [SliderDirection.top]    — vertical,   min at the top, max at the bottom.
/// - [SliderDirection.bottom] — vertical,   min at the bottom, max at the top.
///
/// The filled portion of the track always grows from the minimum side toward
/// the thumb, regardless of direction.
///
/// ### Grid invariants
///
/// In debug builds, the [StepGrid] constructor asserts that `(max - min) /
/// step` is a whole number (within scaled-integer tolerance). The minimum
/// supported step is `0.001`; finer grids are rejected.
///
/// ### onChanged semantics
///
/// [onChanged] fires only in response to user interaction with the slider —
/// not for programmatic writes to the controller. To observe all value
/// changes, listen to the [controller] directly.
///
/// ### Vertical orientation caveat
///
/// Vertical layout rotates the [Slider] a quarter turn. The Material thumb
/// label bubble renders in the rotated coordinate space and may appear
/// sideways; supply a custom [label] or wrap in a [SliderTheme] to suppress
/// it if this matters for your use case.
class Directional extends StatelessWidget {
  /// Creates a [Directional] slider.
  Directional({
    required this.controller,
    required this.direction,
    required double min,
    required double max,
    required double step,
    super.key,
    this.label,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.enableHapticFeedback = false,
    this.hapticIntensity = HapticIntensity.light,
  }) : grid = StepGrid(min: min, max: max, step: step);

  /// External source of truth for the slider's value.
  final DirectionalController controller;

  /// Layout direction. Encodes both axis and which end holds the minimum.
  final SliderDirection direction;

  /// The step grid the slider snaps to.
  final StepGrid grid;

  /// Optional label shown above the slider thumb. Defaults to the current
  /// value formatted to the grid's implied decimal places.
  final String? label;

  /// Called only when the user interacts with the slider (tap or drag).
  /// Programmatic writes to [controller] do not fire this callback.
  final ValueChanged<double>? onChanged;

  /// Color of the active portion of the track.
  final Color? activeColor;

  /// Color of the inactive portion of the track.
  final Color? inactiveColor;

  /// Color of the slider thumb.
  final Color? thumbColor;

  /// Whether to fire haptic feedback when a drag crosses into a new step
  /// bucket. Has no effect on programmatic writes to [controller].
  final bool enableHapticFeedback;

  /// Type of haptic feedback to fire on step crossings.
  final HapticIntensity hapticIntensity;

  @override
  Widget build(BuildContext context) {
    final slider = _HapticSlider(
      controller: controller,
      grid: grid,
      label: label,
      onChanged: onChanged,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      thumbColor: thumbColor,
      enableHapticFeedback: enableHapticFeedback,
      hapticIntensity: hapticIntensity,
    );

    return _orient(slider);
  }

  /// Wraps the underlying [Slider] in the rotation / RTL flip needed to
  /// realise [direction].
  ///
  /// Implementation notes:
  ///
  /// - The underlying [Slider] is intrinsically a left-to-right horizontal
  ///   widget (min on the left, max on the right).
  /// - Horizontal reversal ([SliderDirection.right]) is achieved with a
  ///   [Directionality] of [TextDirection.rtl], which flips the slider's
  ///   painting and gesture handling along the horizontal axis without
  ///   touching layout size.
  /// - Vertical orientations rotate the slider a quarter turn:
  ///   [SliderDirection.bottom] (min at the bottom) uses `quarterTurns: 3`
  ///   (counter-clockwise); [SliderDirection.top] (min at the top) uses
  ///   `quarterTurns: 1` (clockwise).
  Widget _orient(Widget slider) {
    switch (direction) {
      case SliderDirection.left:
        return slider;
      case SliderDirection.right:
        return Directionality(
          textDirection: TextDirection.rtl,
          child: slider,
        );
      case SliderDirection.bottom:
        return RotatedBox(quarterTurns: 3, child: slider);
      case SliderDirection.top:
        return RotatedBox(quarterTurns: 1, child: slider);
    }
  }
}

/// Internal slider that owns step-crossing hysteresis for haptic feedback.
///
/// Rebuilds only on controller change via [ValueListenableBuilder] — no
/// manual `addListener` / `setState` plumbing.
class _HapticSlider extends StatefulWidget {
  const _HapticSlider({
    required this.controller,
    required this.grid,
    required this.label,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.enableHapticFeedback,
    required this.hapticIntensity,
  });

  final DirectionalController controller;
  final StepGrid grid;
  final String? label;
  final ValueChanged<double>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final bool enableHapticFeedback;
  final HapticIntensity hapticIntensity;

  @override
  State<_HapticSlider> createState() => _HapticSliderState();
}

class _HapticSliderState extends State<_HapticSlider> {
  late int _lastStepIndex = widget.grid.indexOf(widget.controller.value);

  @override
  void didUpdateWidget(_HapticSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.grid != widget.grid) {
      _lastStepIndex = widget.grid.indexOf(widget.controller.value);
    }
  }

  void _handleSliderChanged(double raw) {
    final snapped = widget.grid.snap(raw);
    final newIndex = widget.grid.indexOf(snapped);

    if (newIndex != _lastStepIndex) {
      if (widget.enableHapticFeedback) {
        widget.hapticIntensity.trigger();
      }
      _lastStepIndex = newIndex;
    }

    widget.controller.value = snapped;
    widget.onChanged?.call(snapped);
  }

  String _defaultLabel(double value) =>
      value.toStringAsFixed(widget.grid.decimalPlaces);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.controller,
      builder: (_, value, __) => Slider(
        value: value,
        onChanged: _handleSliderChanged,
        min: widget.grid.min,
        max: widget.grid.max,
        divisions: widget.grid.divisions,
        label: widget.label ?? _defaultLabel(value),
        activeColor: widget.activeColor,
        inactiveColor: widget.inactiveColor,
        thumbColor: widget.thumbColor,
      ),
    );
  }
}

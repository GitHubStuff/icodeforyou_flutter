// packages/custom_widgets/lib/src/directional_slider/src/slider/directional.dart
// ignore_for_file: always_use_package_imports, comment_references

import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:extensions/enum/src/placement.dart' show Placement;
import 'package:flutter/material.dart';

import 'directional_controller.dart';
import 'step_grid.dart';

class DirectionalSlider extends StatelessWidget {
  DirectionalSlider({
    required this.controller,
    required this.rotation,
    required double min,
    required double max,
    required double step,
    super.key,
    this.minValueFirst = true,
    this.placement = .bottom,
    this.label,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.enableHapticFeedback = false,
    this.hapticIntensity = HapticIntensity.selection,
  }) : grid = StepGrid(min: min, max: max, step: step);

  final Placement placement;

  final bool minValueFirst;

  /// External source of truth for the slider's value.
  final DirectionalController controller;

  /// Layout direction. Encodes both axis and which end holds the minimum.
  final Axis rotation;

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

  Widget _orient(Widget slider) {
    switch (rotation) {
      case .horizontal:
        return slider;
      case .vertical:
        return RotatedBox(
          quarterTurns: 2,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: slider,
          ),
        );
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

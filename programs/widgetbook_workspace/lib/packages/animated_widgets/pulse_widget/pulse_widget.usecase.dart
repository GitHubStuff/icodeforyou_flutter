// widgetbook_workspace/lib/pulse_widget/pulse_widget.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart'
    show PulseConfig, PulseWidget;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// [PulseWidget] driven by a fully knob-configured [PulseConfig].
///
/// Every [PulseConfig] field is exposed: the three durations (hold, grow,
/// shrink), the three scales (start, peak, rest), and the two curves (grow,
/// shrink). The subtree is keyed on the resulting config (see [_replayable])
/// so that changing any knob both re-applies the config and replays the
/// pulse — `_PulseWidgetState` reads `config` only in `initState`, so its
/// `State` must be recreated for new values to take effect.
@widgetbook.UseCase(name: 'Default', type: PulseWidget)
Widget buildPulseWidgetUseCase(BuildContext context) {
  final config = PulseConfig(
    holdDuration: _durationKnob(
      context,
      label: 'hold duration (ms)',
      initialMs: 250,
    ),
    growDuration: _durationKnob(
      context,
      label: 'grow duration (ms)',
      initialMs: 300,
    ),
    shrinkDuration: _durationKnob(
      context,
      label: 'shrink duration (ms)',
      initialMs: 300,
    ),
    pulseStartScale: _scaleKnob(
      context,
      label: 'start scale',
      initialValue: 1,
    ),
    pulsePeakScale: _scaleKnob(
      context,
      label: 'peak scale',
      initialValue: 1.2,
    ),
    pulseRestScale: _scaleKnob(
      context,
      label: 'rest scale',
      initialValue: 1,
    ),
    growCurve: _curveKnob(
      context,
      label: 'grow curve',
      initialOption: Curves.easeOut,
    ),
    shrinkCurve: _curveKnob(
      context,
      label: 'shrink curve',
      initialOption: Curves.easeIn,
    ),
  );

  return _replayable(
    ValueKey<int>(
      Object.hash(
        config.holdDuration,
        config.growDuration,
        config.shrinkDuration,
        config.pulseStartScale,
        config.pulsePeakScale,
        config.pulseRestScale,
        config.growCurve,
        config.shrinkCurve,
      ),
    ),
    PulseWidget(
      config: config,
      child: const _DemoBox(label: 'Pulse'),
    ),
  );
}

/// Duration knob: `250ms` to `1250ms` in steps of `10ms`.
Duration _durationKnob(
  BuildContext context, {
  required String label,
  required int initialMs,
}) => Duration(
  milliseconds: context.knobs.int.slider(
    label: label,
    min: 250,
    max: 1250,
    divisions: 100,
    initialValue: initialMs,
  ),
);

/// Scale knob: `0.0` to `2.0` in steps of `0.1`.
double _scaleKnob(
  BuildContext context, {
  required String label,
  required double initialValue,
}) => context.knobs.double.slider(
  label: label,
  min: 0,
  max: 2,
  divisions: 20,
  initialValue: initialValue,
);

/// Curve knob backed by [_curveOptions].
Curve _curveKnob(
  BuildContext context, {
  required String label,
  required Curve initialOption,
}) => context.knobs.object.dropdown<Curve>(
  label: label,
  options: _curveOptions.keys.toList(),
  initialOption: initialOption,
  labelBuilder: (curve) => _curveOptions[curve] ?? '$curve',
);

/// Wraps [child] so that a change to [key] (derived from the config) tears
/// down and rebuilds the subtree, re-applying the config and replaying the
/// pulse from the start.
Widget _replayable(Key key, Widget child) => Center(
  child: KeyedSubtree(key: key, child: child),
);

/// Curve options offered by the curve knobs, paired with display labels.
const Map<Curve, String> _curveOptions = <Curve, String>{
  Curves.linear: 'linear',
  Curves.ease: 'ease',
  Curves.easeIn: 'easeIn',
  Curves.easeOut: 'easeOut',
  Curves.easeInOut: 'easeInOut',
  Curves.fastOutSlowIn: 'fastOutSlowIn',
  Curves.decelerate: 'decelerate',
  Curves.easeOutBack: 'easeOutBack',
  Curves.bounceOut: 'bounceOut',
  Curves.elasticOut: 'elasticOut',
};

/// Themed demo target. Uses [ColorScheme] roles so it renders correctly in
/// both light and dark Widgetbook themes.
class _DemoBox extends StatelessWidget {
  const _DemoBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 128,
        height: 128,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

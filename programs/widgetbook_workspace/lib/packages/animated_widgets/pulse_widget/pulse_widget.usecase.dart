// programs/widgetbook_workspace/lib/animated_widgets/pulse_widget/pulse_widget.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:animated_widgets/animated_widgets.dart' show PulseWidget;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const int _kRateMinMs = 50;
const int _kRateMaxMs = 1000;
const int _kRateInitialMs = 150;
const double _kPeakScaleMin = 1;
const double _kPeakScaleMax = 2;
const double _kPeakScaleInitial = 1.15;

@widgetbook.UseCase(name: 'Default', type: PulseWidget)
Widget buildPulseWidgetUseCase(BuildContext context) {
  final rateMs = context.knobs.int.slider(
    label: 'rate (ms per leg)',
    initialValue: _kRateInitialMs,
    min: _kRateMinMs,
    max: _kRateMaxMs,
    description:
        'Each of the three legs (grow, hold, shrink) runs this '
        'long, so the full pulse takes three times this value.',
  );
  final peakScale = context.knobs.double.slider(
    label: 'peakScale',
    initialValue: _kPeakScaleInitial,
    min: _kPeakScaleMin,
    max: _kPeakScaleMax,
    divisions: 20,
    description:
        '1.0 produces no visible pulse; 1.15 grows the child '
        'by 15% at the apex.',
  );

  return _PulseUseCaseHarness(
    rate: Duration(milliseconds: rateMs),
    peakScale: peakScale,
  );
}

/// Remount harness for [PulseWidget].
///
/// [PulseWidget] pulses once per mount, so replaying requires a fresh
/// element. The harness keys the [PulseWidget] on a generation counter
/// plus the current knob values: pressing the replay button bumps the
/// generation, and any knob change alters the key — either way the
/// widget remounts and the pulse runs again with the current values.
final class _PulseUseCaseHarness extends StatefulWidget {
  const _PulseUseCaseHarness({
    required this.rate,
    required this.peakScale,
  });

  /// Duration of each pulse leg, from the rate knob.
  final Duration rate;

  /// Apex scale multiplier, from the peakScale knob.
  final double peakScale;

  @override
  State<_PulseUseCaseHarness> createState() => _PulseUseCaseHarnessState();
}

class _PulseUseCaseHarnessState extends State<_PulseUseCaseHarness> {
  /// Incremented on each replay press to force a remount of the pulse.
  int _generation = 0;

  void _replay() => setState(() => _generation++);

  @override
  Widget build(BuildContext context) {
    final key = ValueKey(
      '$_generation|${widget.rate.inMilliseconds}|${widget.peakScale}',
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PulseWidget(
          key: key,
          rate: widget.rate,
          peakScale: widget.peakScale,
          onComplete: () => showToast('onComplete'),
          child: const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text('Pulse'),
            ),
          ),
        ),
        const SizedBox(height: 48),
        FilledButton.icon(
          onPressed: _replay,
          icon: const Icon(Icons.replay),
          label: const Text('Pulse again'),
        ),
      ],
    );
  }
}

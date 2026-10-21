// widgetbook_workspace/lib/spinners/spin_widget.usecase.dart

import 'package:flutter/material.dart';
import 'package:spinners/spinners.dart' show SpinController, SpinWidget;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// |rpm| ceiling that stays under the 15°-per-frame strobe limit at 60 Hz.
const double _kMaxRpm = 150;
const double _kInitialRpm = 30;
const double _kFallbackRpm = 1;
const double _kChildSize = 96;
const double _kControlSpacing = 12;

const Map<String, Alignment> _kAlignments = {
  'center': Alignment.center,
  'topLeft': Alignment.topLeft,
  'topCenter': Alignment.topCenter,
  'topRight': Alignment.topRight,
  'centerLeft': Alignment.centerLeft,
  'centerRight': Alignment.centerRight,
  'bottomLeft': Alignment.bottomLeft,
  'bottomCenter': Alignment.bottomCenter,
  'bottomRight': Alignment.bottomRight,
};

/// The slider can land on exactly zero, which [SpinWidget] rejects.
double _nonZero(double rpm) => rpm == 0 ? _kFallbackRpm : rpm;

Widget _sampleChild() => const FlutterLogo(size: _kChildSize);

@UseCase(name: 'Interactive', type: SpinWidget)
Widget buildSpinWidgetInteractive(BuildContext context) {
  final rpm = _nonZero(
    context.knobs.double.slider(
      label: 'rpm',
      description: 'Positive is clockwise, negative is counter-clockwise.',
      initialValue: _kInitialRpm,
      min: -_kMaxRpm,
      max: _kMaxRpm,
    ),
  );

  final autoStart = context.knobs.boolean(
    label: 'autoStart',
    initialValue: true,
  );

  final alignment = context.knobs.object.dropdown<Alignment>(
    label: 'alignment',
    options: _kAlignments.values.toList(),
    initialOption: Alignment.center,
    labelBuilder: (alignment) => _kAlignments.entries
        .firstWhere((entry) => entry.value == alignment)
        .key,
  );

  final filterQuality = context.knobs.objectOrNull.dropdown<FilterQuality>(
    label: 'filterQuality',
    options: FilterQuality.values,
    labelBuilder: (quality) => quality.name,
  );

  // rpm and autoStart seed the owned controller once, so a knob change must
  // recreate the widget for it to take effect.
  return Center(
    child: SpinWidget(
      key: ValueKey((rpm, autoStart)),
      rpm: rpm,
      autoStart: autoStart,
      alignment: alignment,
      filterQuality: filterQuality,
      child: _sampleChild(),
    ),
  );
}

@UseCase(name: 'Controlled', type: SpinWidget)
Widget buildSpinWidgetControlled(BuildContext context) {
  final rpm = _nonZero(
    context.knobs.double.slider(
      label: 'rpm',
      description: 'Applied live through SpinController.rpm.',
      initialValue: _kInitialRpm,
      min: -_kMaxRpm,
      max: _kMaxRpm,
    ),
  );

  final startAngle = context.knobs.double.slider(
    label: 'start angle (°)',
    initialValue: 0,
    max: 360,
  );

  return _ControlledSpinDemo(rpm: rpm, startAngle: startAngle);
}

/// Owns a [SpinController] and exposes its full API through buttons.
class _ControlledSpinDemo extends StatefulWidget {
  const _ControlledSpinDemo({required this.rpm, required this.startAngle});

  final double rpm;
  final double startAngle;

  @override
  State<_ControlledSpinDemo> createState() => _ControlledSpinDemoState();
}

class _ControlledSpinDemoState extends State<_ControlledSpinDemo> {
  late final SpinController _controller;
  double? _stoppedAt;

  @override
  void initState() {
    super.initState();
    _controller = SpinController(rpm: widget.rpm);
  }

  @override
  void didUpdateWidget(_ControlledSpinDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rpm != widget.rpm) {
      _controller.rpm = widget.rpm;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => _stoppedAt = null);
    _controller.start(angle: widget.startAngle);
  }

  void _resume() {
    setState(() => _stoppedAt = null);
    _controller.resume();
  }

  void _stop() => setState(() => _stoppedAt = _controller.stop());

  void _reset() {
    setState(() => _stoppedAt = null);
    _controller.reset();
  }

  String _status() {
    if (!_controller.isSpinning) {
      final angle = (_stoppedAt ?? _controller.angle).toStringAsFixed(0);
      return 'Stopped at $angle°';
    }
    final direction = _controller.isClockwise
        ? 'clockwise'
        : 'counter-clockwise';
    final rpm = _controller.rpm.abs().toStringAsFixed(0);
    return 'Spinning $direction at $rpm rpm';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinWidget(controller: _controller, child: _sampleChild()),
          const SizedBox(height: _kControlSpacing * 2),
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) =>
                Text(_status(), style: textTheme.bodyMedium),
          ),
          const SizedBox(height: _kControlSpacing),
          Wrap(
            spacing: _kControlSpacing,
            runSpacing: _kControlSpacing,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(onPressed: _start, child: const Text('Start')),
              FilledButton.tonal(
                onPressed: _resume,
                child: const Text('Resume'),
              ),
              FilledButton.tonal(onPressed: _stop, child: const Text('Stop')),
              OutlinedButton(onPressed: _reset, child: const Text('Reset')),
            ],
          ),
        ],
      ),
    );
  }
}

// Page hosting the controlled and uncontrolled spinner demos.
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sized_spinner/sized_spinner.dart'
    show PlatformSpinner, SpinController, SpinWidget;

/// Demos the SpinWidget (and controller)
class SpinWidgetDemo extends StatefulWidget {
  /// Creates the example page.
  const SpinWidgetDemo({super.key});

  @override
  State<SpinWidgetDemo> createState() => _SpinWidgetDemo();
}

class _SpinWidgetDemo extends State<SpinWidgetDemo> {
  final SpinController _controller = SpinController(rpm: 10);
  double _lastStopAngle = 0;

  @override
  void initState() {
    super.initState();
    // Rebuild the readout whenever the controller changes state.
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Gap(28),
        const Text('My Sized Spinner'),
        const Gap(2),
        const Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            PlatformSpinner(size: 48, osPlatform: .android),
            PlatformSpinner(size: 48, osPlatform: .iOS),
            PlatformSpinner(size: 48, osPlatform: .linux),
            PlatformSpinner(size: 48, osPlatform: .windows),
          ],
        ),
        const Gap(8),
        Text('Controlled', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Center(
          child: SpinWidget(
            controller: _controller,
            child: const Icon(Icons.settings, size: 65),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _controller.isSpinning
              ? 'Spinning at ${_controller.rpm.toStringAsFixed(1)} rpm'
              : 'Stopped at ${_controller.angle.toStringAsFixed(1)}°',
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          'Last stop() returned ${_lastStopAngle.toStringAsFixed(1)}°',
          style: textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: _controller.start,
              child: const Text('start()'),
            ),
            FilledButton(
              onPressed: () => _controller.start(angle: 90),
              child: const Text('start(angle: 90)'),
            ),
            FilledButton.tonal(
              onPressed: _controller.resume,
              child: const Text('resume()'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  setState(() => _lastStopAngle = _controller.stop()),
              child: const Text('stop()'),
            ),
            OutlinedButton(
              onPressed: _controller.reset,
              child: const Text('reset()'),
            ),
            OutlinedButton(
              onPressed: () => _controller.reset(angle: 180),
              child: const Text('reset(angle: 180)'),
            ),
            OutlinedButton(
              onPressed: () => _controller.rpm = -_controller.rpm,
              child: const Text('reverse direction'),
            ),
          ],
        ),
        const Gap(65),
        Text(
          'rpm: ${_controller.rpm.toStringAsFixed(1)} '
          '(${_controller.isClockwise ? 'clockwise' : 'counter-clockwise'})',
          style: textTheme.bodyMedium,
        ),
        Slider(
          value: _controller.rpm.abs(),
          min: 1,
          max: 120,
          divisions: 119,
          label: _controller.rpm.abs().toStringAsFixed(0),
          onChanged: (value) =>
              _controller.rpm = _controller.isClockwise ? value : -value,
        ),
        const Divider(height: 24),
        Text('Uncontrolled', style: textTheme.titleLarge),
        const Gap(8),
        Text(
          'No controller: the widget owns one, seeded by rpm and autoStart.',
          style: textTheme.bodyMedium,
        ),
        const Gap(16),
        const Center(
          child: SpinWidget(
            rpm: -6,
            autoStart: true,
            child: Icon(Icons.refresh, size: 40),
          ),
        ),
      ],
    );
  }
}
